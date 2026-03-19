package com.healthcare.sales.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.healthcare.sales.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    /** 根据用户名查询（包含密码字段） */
    @Select("SELECT * FROM user WHERE username = #{username}")
    User selectByUsernameWithPwd(@Param("username") String username);
}
