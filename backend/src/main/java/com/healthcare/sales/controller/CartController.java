package com.healthcare.sales.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.Cart;
import com.healthcare.sales.mapper.CartMapper;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartMapper cartMapper;

    /** 购物车列表（关联商品信息） */
    @GetMapping("/list")
    public Result<List<Map<String, Object>>> list() {
        return Result.success(cartMapper.selectCartDetail(UserContext.getUserId()));
    }

    /** 加入购物车 */
    @PostMapping("/add")
    public Result<Void> add(@RequestBody Map<String, Object> body) {
        Long    userId    = UserContext.getUserId();
        Long    productId = Long.valueOf(body.get("productId").toString());
        Integer quantity  = Integer.valueOf(body.get("quantity").toString());

        // 若已在购物车，增加数量
        Cart existing = cartMapper.selectOne(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId).eq(Cart::getProductId, productId));
        if (existing != null) {
            existing.setQuantity(existing.getQuantity() + quantity);
            cartMapper.updateById(existing);
        } else {
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setProductId(productId);
            cart.setQuantity(quantity);
            cartMapper.insert(cart);
        }
        return Result.success();
    }

    /** 更新数量 */
    @PutMapping("/update")
    public Result<Void> update(@RequestBody Cart cart) {
        if (cart.getQuantity() < 1) throw BusinessException.of("数量不能小于1");
        // 只允许修改自己的购物车
        Cart existing = cartMapper.selectById(cart.getId());
        if (existing == null || !existing.getUserId().equals(UserContext.getUserId())) {
            throw BusinessException.of("购物车记录不存在");
        }
        existing.setQuantity(cart.getQuantity());
        cartMapper.updateById(existing);
        return Result.success();
    }

    /** 删除单项 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Cart existing = cartMapper.selectById(id);
        if (existing == null || !existing.getUserId().equals(UserContext.getUserId())) {
            throw BusinessException.of("购物车记录不存在");
        }
        cartMapper.deleteById(id);
        return Result.success();
    }

    /** 清空购物车 */
    @DeleteMapping("/clear")
    public Result<Void> clear() {
        cartMapper.delete(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, UserContext.getUserId()));
        return Result.success();
    }
}
