package com.healthcare.sales.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product")
public class Product {
    @TableId(type = IdType.AUTO)
    private Long          id;
    private Long          categoryId;
    private String        name;
    private String        description;
    private BigDecimal    price;
    private BigDecimal    originalPrice;
    private Integer       stock;
    private Integer       stockWarning;
    private String        imageUrl;
    private String        images;
    private Integer       salesCount;
    private Integer       status;         // 0下架 1上架
    private Long          createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
