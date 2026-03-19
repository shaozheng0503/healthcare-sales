package com.healthcare.sales.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("article")
public class Article {
    @TableId(type = IdType.AUTO)
    private Long          id;
    private String        title;
    private String        summary;
    private String        content;
    private String        coverImage;
    private Long          authorId;
    private Integer       status;     // 0草稿 1已发布 2已下架
    private Integer       viewCount;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
