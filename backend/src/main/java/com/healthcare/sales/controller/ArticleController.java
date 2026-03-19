package com.healthcare.sales.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.Article;
import com.healthcare.sales.mapper.ArticleMapper;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/article")
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleMapper articleMapper;

    /** 分页列表（公开，支持按浏览量排序） */
    @GetMapping("/page")
    public Result<?> page(@RequestParam(defaultValue = "1") Integer page,
                          @RequestParam(defaultValue = "9") Integer size,
                          @RequestParam(required = false) String title,
                          @RequestParam(required = false) Integer status,
                          @RequestParam(required = false) String orderBy) {
        Page<Article> p = new Page<>(page, size);
        LambdaQueryWrapper<Article> w = new LambdaQueryWrapper<Article>()
                .like(title != null && !title.isEmpty(), Article::getTitle, title)
                .eq(status != null, Article::getStatus, status);
        // 支持按浏览量排序（热门文章）
        if ("view_count".equals(orderBy)) {
            w.orderByDesc(Article::getViewCount);
        } else {
            w.orderByDesc(Article::getCreatedAt);
        }
        return Result.success(articleMapper.selectPage(p, w));
    }

    /** 详情（公开，浏览量+1） */
    @GetMapping("/{id}")
    public Result<Article> detail(@PathVariable Long id) {
        Article article = articleMapper.selectById(id);
        if (article == null) {
            throw BusinessException.of("文章不存在");
        }
        articleMapper.incrementViewCount(id);  // 原子更新浏览量
        article.setViewCount(article.getViewCount() + 1);  // 返回给前端的数值 +1
        return Result.success(article);
    }

    /** 新增（商家/管理员） */
    @PostMapping
    public Result<Void> add(@RequestBody Article article) {
        checkBackend();
        article.setAuthorId(UserContext.getUserId());
        article.setViewCount(0);
        articleMapper.insert(article);
        return Result.success();
    }

    /** 编辑（商家/管理员） */
    @PutMapping
    public Result<Void> update(@RequestBody Article article) {
        checkBackend();
        articleMapper.updateById(article);
        return Result.success();
    }

    /** 删除（商家/管理员） */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        checkBackend();
        articleMapper.deleteById(id);
        return Result.success();
    }

    /** 发布（商家/管理员） */
    @PutMapping("/{id}/publish")
    public Result<Void> publish(@PathVariable Long id) {
        checkBackend();
        articleMapper.update(null, new LambdaUpdateWrapper<Article>()
                .eq(Article::getId, id).set(Article::getStatus, 1));
        return Result.success();
    }

    private void checkBackend() {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
