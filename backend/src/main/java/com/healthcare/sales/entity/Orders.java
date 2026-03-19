package com.healthcare.sales.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("orders")
public class Orders {
    @TableId(type = IdType.AUTO)
    private Long          id;
    private String        orderNo;
    private Long          userId;
    private BigDecimal    totalAmount;
    private BigDecimal    payAmount;
    private Integer       status;           // 0待支付 1已支付 2已发货 3已完成 4已取消
    private Integer       payType;
    private LocalDateTime payTime;
    private String        receiverName;
    private String        receiverPhone;
    private String        receiverAddress;
    private String        remark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
