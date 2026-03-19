package com.healthcare.sales.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.Orders;
import com.healthcare.sales.entity.Product;
import com.healthcare.sales.entity.User;
import com.healthcare.sales.mapper.*;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/statistics")
@RequiredArgsConstructor
public class StatisticsController {

    private final OrdersMapper  ordersMapper;
    private final ProductMapper productMapper;
    private final UserMapper    userMapper;

    /** 概览数据（今日订单、销售额、商品总数、用户总数、低库存列表） */
    @GetMapping("/overview")
    public Result<Map<String, Object>> overview() {
        checkBackend();
        Map<String, Object> data = new HashMap<>();

        // 今日订单数
        long todayOrders = ordersMapper.selectCount(new LambdaQueryWrapper<Orders>()
                .apply("DATE(created_at) = CURDATE()"));
        data.put("todayOrders", todayOrders);

        // 今日销售额
        List<Orders> todayPaid = ordersMapper.selectList(new LambdaQueryWrapper<Orders>()
                .apply("DATE(created_at) = CURDATE()").in(Orders::getStatus, 1, 2, 3));
        BigDecimal todaySales = todayPaid.stream()
                .map(Orders::getPayAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("todaySales", todaySales);

        // 商品总数
        data.put("totalProducts", productMapper.selectCount(null));

        // 用户总数
        data.put("totalUsers", userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getRole, 2)));

        // 低库存预警列表
        List<Product> lowStock = productMapper.selectList(new LambdaQueryWrapper<Product>()
                .apply("stock <= stock_warning").eq(Product::getStatus, 1).last("LIMIT 10"));
        data.put("lowStockList", lowStock);

        return Result.success(data);
    }

    /** 销售趋势（商家/管理员） */
    @GetMapping("/sales-trend")
    public Result<Map<String, Object>> salesTrend(
            @RequestParam(required = false) Integer days,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        checkBackend();
        List<Map<String, Object>> trend = ordersMapper.selectSalesTrend(days, startDate, endDate);

        List<String>     dates  = new ArrayList<>();
        List<BigDecimal> sales  = new ArrayList<>();
        List<Long>       orders = new ArrayList<>();

        // 如果无数据，生成近N天空数据填充
        if (trend.isEmpty() && days != null) {
            for (int i = days - 1; i >= 0; i--) {
                dates.add(LocalDate.now().minusDays(i).toString());
                sales.add(BigDecimal.ZERO);
                orders.add(0L);
            }
        } else {
            for (Map<String, Object> row : trend) {
                dates.add(row.get("date").toString());
                sales.add(new BigDecimal(row.get("sales").toString()));
                orders.add(Long.valueOf(row.get("orders").toString()));
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("dates",  dates);
        data.put("sales",  sales);
        data.put("orders", orders);
        return Result.success(data);
    }

    /** 热销商品 */
    @GetMapping("/hot-products")
    public Result<List<Map<String, Object>>> hotProducts() {
        checkBackend();
        return Result.success(productMapper.selectHotProducts(10));
    }

    /** 订单状态分布 */
    @GetMapping("/order-status")
    public Result<List<Map<String, Object>>> orderStatus() {
        checkBackend();
        return Result.success(ordersMapper.selectOrderStatusDist());
    }

    /** 各分类销售占比 */
    @GetMapping("/category-ratio")
    public Result<List<Map<String, Object>>> categoryRatio() {
        checkBackend();
        return Result.success(ordersMapper.selectCategoryRatio());
    }

    private void checkBackend() {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
