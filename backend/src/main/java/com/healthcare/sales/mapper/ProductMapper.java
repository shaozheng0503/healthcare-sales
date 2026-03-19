package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {

    /** 扣减库存（乐观锁防超卖） */
    @Update("UPDATE product SET stock = stock - #{quantity}, sales_count = sales_count + #{quantity} " +
            "WHERE id = #{productId} AND stock >= #{quantity}")
    int deductStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    /** 回滚库存 */
    @Update("UPDATE product SET stock = stock + #{quantity}, sales_count = sales_count - #{quantity} " +
            "WHERE id = #{productId}")
    int rollbackStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    /** 带分类名称的分页查询（支持排序、库存预警筛选） */
    IPage<Map<String, Object>> selectPageWithCategory(Page<Map<String, Object>> page,
                                                       @Param("name") String name,
                                                       @Param("categoryId") Long categoryId,
                                                       @Param("status") Integer status,
                                                       @Param("orderBy") String orderBy,
                                                       @Param("orderDir") String orderDir,
                                                       @Param("stockWarnOnly") Boolean stockWarnOnly);

    /** 热销商品 Top N */
    List<Map<String, Object>> selectHotProducts(@Param("limit") int limit);
}
