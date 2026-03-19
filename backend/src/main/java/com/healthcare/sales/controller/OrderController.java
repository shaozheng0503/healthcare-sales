package com.healthcare.sales.controller;

import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.service.impl.OrderServiceImpl;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderServiceImpl orderService;

    /** 创建订单 */
    @PostMapping("/create")
    public Result<Map<String, String>> create(@RequestBody Map<String, Object> body) {
        String orderNo = orderService.createOrder(body);
        Map<String, String> data = new HashMap<>();
        data.put("orderNo", orderNo);
        return Result.success(data);
    }

    /** 我的订单列表（含明细） */
    @GetMapping("/my")
    public Result<java.util.Map<String, Object>> myOrders(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "5") Integer size,
            @RequestParam(required = false) Integer status) {
        return Result.success(orderService.myOrders(page, size, status));
    }

    /** 后台订单列表（商家/管理员） */
    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") Integer page,
                          @RequestParam(defaultValue = "10") Integer size,
                          @RequestParam(required = false) String orderNo,
                          @RequestParam(required = false) Integer status,
                          @RequestParam(required = false) String startDate,
                          @RequestParam(required = false) String endDate) {
        checkBackend();
        return Result.success(orderService.adminOrders(page, size, orderNo, status, startDate, endDate));
    }

    /** 订单详情 */
    @GetMapping("/{orderNo}")
    public Result<Map<String, Object>> detail(@PathVariable String orderNo) {
        Map<String, Object> detail = orderService.detail(orderNo);
        // 非后台用户只能查看自己的订单
        if (!UserContext.isBackend()) {
            orderService.checkOrderOwner(orderNo);
        }
        return Result.success(detail);
    }

    /** 支付（模拟） */
    @PostMapping("/{orderNo}/pay")
    public Result<Void> pay(@PathVariable String orderNo) {
        orderService.checkOrderOwner(orderNo);
        orderService.pay(orderNo);
        return Result.success();
    }

    /** 发货（商家/管理员） */
    @PostMapping("/{orderNo}/ship")
    public Result<Void> ship(@PathVariable String orderNo) {
        checkBackend();
        orderService.ship(orderNo);
        return Result.success();
    }

    /** 确认收货 */
    @PostMapping("/{orderNo}/complete")
    public Result<Void> complete(@PathVariable String orderNo) {
        orderService.checkOrderOwner(orderNo);
        orderService.complete(orderNo);
        return Result.success();
    }

    /** 取消订单 */
    @PostMapping("/{orderNo}/cancel")
    public Result<Void> cancel(@PathVariable String orderNo) {
        // 消费者只能取消自己的订单，后台可取消任意订单
        if (!UserContext.isBackend()) {
            orderService.checkOrderOwner(orderNo);
        }
        orderService.cancel(orderNo);
        return Result.success();
    }

    private void checkBackend() {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
