package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.healthcare.sales.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {

    @Select("SELECT * FROM category WHERE status = 1 ORDER BY sort ASC")
    List<Category> selectAllEnabled();
}
