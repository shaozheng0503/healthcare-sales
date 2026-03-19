package com.healthcare.sales.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long          id;
    private String        username;
    @TableField(select = false)   // 查询时默认不返回密码字段
    private String        password;
    private String        realName;
    private String        phone;
    private String        email;
    private String        avatar;
    private Integer       role;      // 0管理员 1商家 2消费者
    private Integer       status;    // 0禁用 1正常

    @TableField(exist = false)   // 非数据库字段，仅用于修改密码时传递旧密码
    private String        oldPassword;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
