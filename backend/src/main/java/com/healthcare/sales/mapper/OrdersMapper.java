package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.entity.Orders;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface OrdersMapper extends BaseMapper<Orders> {

    /** 后台订单分页（含用户名） */
    IPage<Map<String, Object>> selectAdminPage(Page<Map<String, Object>> page,
                                                @Param("orderNo") String orderNo,
                                                @Param("status") Integer status,
                                                @Param("startDate") String startDate,
                                                @Param("endDate") String endDate);

    /** 近N天销售趋势 */
    List<Map<String, Object>> selectSalesTrend(@Param("days") Integer days,
                                                @Param("startDate") String startDate,
                                                @Param("endDate") String endDate);

    /** 各分类销售占比 */
    List<Map<String, Object>> selectCategoryRatio();

    /** 订单状态分布 */
    List<Map<String, Object>> selectOrderStatusDist();
}
