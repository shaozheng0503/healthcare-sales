package com.healthcare.sales.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("stock_log")
public class StockLog {
    @TableId(type = IdType.AUTO)
    private Long          id;
    private Long          productId;
    private String        productName;
    private Integer       type;           // 1入库 2出库 3手动调整 4取消回滚
    private Integer       changeQuantity;
    private Integer       beforeStock;
    private Integer       afterStock;
    private String        orderNo;
    private Long          operatorId;
    private String        remark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
