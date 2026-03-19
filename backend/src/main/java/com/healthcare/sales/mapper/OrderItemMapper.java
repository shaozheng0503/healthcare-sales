package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.healthcare.sales.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    @Select("SELECT * FROM order_item WHERE order_no = #{orderNo}")
    List<OrderItem> selectByOrderNo(@Param("orderNo") String orderNo);
}
