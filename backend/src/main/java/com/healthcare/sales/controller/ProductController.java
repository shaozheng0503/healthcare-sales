package com.healthcare.sales.controller;

import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.Product;
import com.healthcare.sales.service.impl.ProductServiceImpl;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductServiceImpl productService;

    /** 商品分页列表（前台消费者 + 后台管理均使用） */
    @GetMapping("/page")
    public Result<?> page(@RequestParam(defaultValue = "1") Integer page,
                          @RequestParam(defaultValue = "12") Integer size,
                          @RequestParam(required = false) String name,
                          @RequestParam(required = false) Long categoryId,
                          @RequestParam(required = false) Integer status,
                          @RequestParam(required = false) String orderBy,
                          @RequestParam(required = false) String orderDir,
                          @RequestParam(required = false) Boolean stockWarnOnly) {
        return Result.success(productService.page(page, size, name, categoryId, status, orderBy, orderDir, stockWarnOnly));
    }

    /** 商品详情 */
    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(productService.detail(id));
    }

    /** 新增商品（商家/管理员） */
    @PostMapping
    public Result<Void> add(@RequestBody Product product) {
        checkBackend();
        productService.add(product);
        return Result.success();
    }

    /** 编辑商品 */
    @PutMapping
    public Result<Void> update(@RequestBody Product product) {
        checkBackend();
        productService.update(product);
        return Result.success();
    }

    /** 删除商品 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        checkBackend();
        productService.delete(id);
        return Result.success();
    }

    /** 上下架 */
    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id,
                                     @RequestBody Map<String, Integer> body) {
        checkBackend();
        productService.updateStatus(id, body.get("status"));
        return Result.success();
    }

    /** 库存调整（入库/手动调整） */
    @PostMapping("/stock/adjust")
    public Result<Void> adjustStock(@RequestBody Map<String, Object> body) {
        checkBackend();
        Long    productId = Long.valueOf(body.get("productId").toString());
        Integer type      = Integer.valueOf(body.get("type").toString());
        Integer changeQty = Integer.valueOf(body.get("changeQuantity").toString());
        String  remark    = (String)  body.getOrDefault("remark", "");
        productService.adjustStock(productId, type, changeQty, remark);
        return Result.success();
    }

    /** 库存变动日志 */
    @GetMapping("/stock/log")
    public Result<?> stockLog(@RequestParam(defaultValue = "1") Integer page,
                               @RequestParam(defaultValue = "15") Integer size,
                               @RequestParam(required = false) Integer type,
                               @RequestParam(required = false) String name) {
        checkBackend();
        return Result.success(productService.stockLog(page, size, type, name));
    }

    private void checkBackend() {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
