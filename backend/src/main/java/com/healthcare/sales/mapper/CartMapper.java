package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.healthcare.sales.entity.Cart;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface CartMapper extends BaseMapper<Cart> {

    /** 查询购物车（关联商品信息） */
    @Select("SELECT c.id, c.user_id AS userId, c.product_id AS productId, c.quantity, " +
            "p.name AS productName, p.price, p.image_url AS productImage, p.stock " +
            "FROM cart c LEFT JOIN product p ON c.product_id = p.id " +
            "WHERE c.user_id = #{userId}")
    List<Map<String, Object>> selectCartDetail(@Param("userId") Long userId);
}
