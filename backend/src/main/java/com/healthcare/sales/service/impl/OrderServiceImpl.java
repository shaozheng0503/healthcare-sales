package com.healthcare.sales.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.entity.*;
import com.healthcare.sales.mapper.*;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl {

    private final OrdersMapper   ordersMapper;
    private final OrderItemMapper orderItemMapper;
    private final ProductMapper  productMapper;
    private final CartMapper     cartMapper;
    private final StockLogMapper stockLogMapper;

    /** 创建订单 */
    @Transactional(rollbackFor = Exception.class)
    public String createOrder(Map<String, Object> body) {
        Long   userId  = UserContext.getUserId();
        String orderNo = generateOrderNo();

        List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
        if (items == null || items.isEmpty()) throw BusinessException.of("请选择商品");

        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();

        for (Map<String, Object> item : items) {
            Long    productId = Long.valueOf(item.get("productId").toString());
            Integer quantity  = Integer.valueOf(item.get("quantity").toString());

            Product product = productMapper.selectById(productId);
            if (product == null || product.getStatus() == 0) throw BusinessException.of("商品不存在或已下架");
            if (product.getStock() < quantity) throw BusinessException.of("商品库存不足：" + product.getName());

            // 扣减库存
            int affected = productMapper.deductStock(productId, quantity);
            if (affected == 0) throw BusinessException.of("商品库存不足（并发）：" + product.getName());

            // 记录库存日志
            StockLog log = new StockLog();
            log.setProductId(productId);
            log.setProductName(product.getName());
            log.setType(2);  // 出库
            log.setChangeQuantity(-quantity);
            log.setBeforeStock(product.getStock());
            log.setAfterStock(product.getStock() - quantity);
            log.setOrderNo(orderNo);
            log.setOperatorId(userId);
            log.setRemark("订单出库");
            stockLogMapper.insert(log);

            // 删除购物车
            Long cartId = item.containsKey("cartId") ? Long.valueOf(item.get("cartId").toString()) : null;
            if (cartId != null) cartMapper.deleteById(cartId);

            BigDecimal subTotal = product.getPrice().multiply(BigDecimal.valueOf(quantity));
            total = total.add(subTotal);

            OrderItem oi = new OrderItem();
            oi.setOrderId(0L);  // 先占位，后更新
            oi.setOrderNo(orderNo);
            oi.setProductId(productId);
            oi.setProductName(product.getName());
            oi.setProductImage(product.getImageUrl());
            oi.setPrice(product.getPrice());
            oi.setQuantity(quantity);
            oi.setTotalPrice(subTotal);
            orderItems.add(oi);
        }

        // 创建订单
        Orders orders = new Orders();
        orders.setOrderNo(orderNo);
        orders.setUserId(userId);
        orders.setTotalAmount(total);
        orders.setPayAmount(total);
        orders.setStatus(0);    // 待支付
        orders.setPayType(Integer.valueOf(body.getOrDefault("payType", 1).toString()));
        String receiverName = body.get("receiverName") != null ? body.get("receiverName").toString() : "";
        String receiverPhone = body.get("receiverPhone") != null ? body.get("receiverPhone").toString() : "";
        String receiverAddress = body.get("receiverAddress") != null ? body.get("receiverAddress").toString() : "";
        if (receiverName.isEmpty() || receiverPhone.isEmpty() || receiverAddress.isEmpty()) {
            throw BusinessException.of("收货人信息不完整");
        }
        orders.setReceiverName(receiverName);
        orders.setReceiverPhone(receiverPhone);
        orders.setReceiverAddress(receiverAddress);
        orders.setRemark(body.getOrDefault("remark", "").toString());
        ordersMapper.insert(orders);

        // 更新订单ID并插入明细
        for (OrderItem oi : orderItems) {
            oi.setOrderId(orders.getId());
            orderItemMapper.insert(oi);
        }

        return orderNo;
    }

    /** 模拟支付 */
    @Transactional(rollbackFor = Exception.class)
    public void pay(String orderNo) {
        Orders orders = getOrderByNo(orderNo);
        if (orders.getStatus() != 0) throw BusinessException.of("订单状态不允许支付");
        orders.setStatus(1);
        orders.setPayTime(LocalDateTime.now());
        ordersMapper.updateById(orders);
    }

    /** 发货（商家/管理员） */
    @Transactional(rollbackFor = Exception.class)
    public void ship(String orderNo) {
        Orders orders = getOrderByNo(orderNo);
        if (orders.getStatus() != 1) throw BusinessException.of("订单未支付，不能发货");
        orders.setStatus(2);
        ordersMapper.updateById(orders);
    }

    /** 确认收货 */
    @Transactional(rollbackFor = Exception.class)
    public void complete(String orderNo) {
        Orders orders = getOrderByNo(orderNo);
        if (orders.getStatus() != 2) throw BusinessException.of("订单未发货");
        orders.setStatus(3);
        ordersMapper.updateById(orders);
    }

    /** 取消订单（退回库存） */
    @Transactional(rollbackFor = Exception.class)
    public void cancel(String orderNo) {
        Orders orders = getOrderByNo(orderNo);
        if (orders.getStatus() != 0 && orders.getStatus() != 1) {
            throw BusinessException.of("当前状态不能取消");
        }
        orders.setStatus(4);
        ordersMapper.updateById(orders);

        // 退回库存
        List<OrderItem> items = orderItemMapper.selectByOrderNo(orderNo);
        for (OrderItem item : items) {
            Product p = productMapper.selectById(item.getProductId());
            int before = p != null ? p.getStock() : 0;
            productMapper.rollbackStock(item.getProductId(), item.getQuantity());

            StockLog log = new StockLog();
            log.setProductId(item.getProductId());
            log.setProductName(item.getProductName());
            log.setType(4);  // 取消回滚
            log.setChangeQuantity(item.getQuantity());
            log.setBeforeStock(before);
            log.setAfterStock(before + item.getQuantity());
            log.setOrderNo(orderNo);
            log.setOperatorId(UserContext.getUserId());
            log.setRemark("订单取消回滚");
            stockLogMapper.insert(log);
        }
    }

    /** 我的订单分页（返回含 items 的 Map 列表） */
    public Map<String, Object> myOrders(Integer pageNum, Integer pageSize, Integer status) {
        Page<Orders> p = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Orders> w = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getUserId, UserContext.getUserId())
                .eq(status != null, Orders::getStatus, status)
                .orderByDesc(Orders::getCreatedAt);
        Page<Orders> result = ordersMapper.selectPage(p, w);

        // 关联订单明细
        List<Map<String, Object>> records = new ArrayList<>();
        for (Orders o : result.getRecords()) {
            Map<String, Object> row = new java.util.LinkedHashMap<>();
            row.put("id",              o.getId());
            row.put("orderNo",         o.getOrderNo());
            row.put("totalAmount",     o.getTotalAmount());
            row.put("payAmount",       o.getPayAmount());
            row.put("status",          o.getStatus());
            row.put("receiverName",    o.getReceiverName());
            row.put("receiverPhone",   o.getReceiverPhone());
            row.put("receiverAddress", o.getReceiverAddress());
            row.put("createdAt",       o.getCreatedAt());
            row.put("payTime",         o.getPayTime());
            row.put("items",           orderItemMapper.selectByOrderNo(o.getOrderNo()));
            records.add(row);
        }

        Map<String, Object> page = new java.util.LinkedHashMap<>();
        page.put("records", records);
        page.put("total",   result.getTotal());
        page.put("current", result.getCurrent());
        page.put("size",    result.getSize());
        return page;
    }

    /** 后台订单分页 */
    public com.baomidou.mybatisplus.core.metadata.IPage<Map<String, Object>> adminOrders(
            Integer pageNum, Integer pageSize,
            String orderNo, Integer status, String startDate, String endDate) {
        Page<Map<String, Object>> p = new Page<>(pageNum, pageSize);
        return ordersMapper.selectAdminPage(p, orderNo, status, startDate, endDate);
    }

    /** 订单详情 */
    public Map<String, Object> detail(String orderNo) {
        Orders orders = getOrderByNo(orderNo);
        List<OrderItem> items = orderItemMapper.selectByOrderNo(orderNo);
        Map<String, Object> result = new HashMap<>();
        result.put("orderNo",         orders.getOrderNo());
        result.put("status",          orders.getStatus());
        result.put("payAmount",       orders.getPayAmount());
        result.put("receiverName",    orders.getReceiverName());
        result.put("receiverPhone",   orders.getReceiverPhone());
        result.put("receiverAddress", orders.getReceiverAddress());
        result.put("remark",          orders.getRemark());
        result.put("createdAt",       orders.getCreatedAt());
        result.put("payTime",         orders.getPayTime());
        result.put("items",           items);
        return result;
    }

    private Orders getOrderByNo(String orderNo) {
        Orders orders = ordersMapper.selectOne(
                new LambdaQueryWrapper<Orders>().eq(Orders::getOrderNo, orderNo));
        if (orders == null) throw BusinessException.of("订单不存在");
        return orders;
    }

    private String generateOrderNo() {
        String orderNo = "HC" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
        // 防碰撞：检查是否已存在，若存在则重新生成（最多重试3次）
        for (int i = 0; i < 3; i++) {
            Long count = ordersMapper.selectCount(
                    new LambdaQueryWrapper<Orders>().eq(Orders::getOrderNo, orderNo));
            if (count == 0) return orderNo;
            orderNo = "HC" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                    + String.format("%04d", new Random().nextInt(10000));
        }
        return orderNo;
    }
}
