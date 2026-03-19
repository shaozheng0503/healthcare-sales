package com.healthcare.sales.controller;

import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.Category;
import com.healthcare.sales.mapper.CategoryMapper;
import com.healthcare.sales.service.impl.CategoryServiceImpl;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/category")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryServiceImpl categoryService;
    private final CategoryMapper categoryMapper;

    /** 分类树（前台+后台公共接口，无需登录） */
    @GetMapping("/tree")
    public Result<List<Map<String, Object>>> tree() {
        return Result.success(categoryService.tree());
    }

    /** 分类平铺列表（前端级联选择器用，无需登录） */
    @GetMapping("/list")
    public Result<List<Category>> list() {
        return Result.success(categoryMapper.selectAllEnabled());
    }

    @PostMapping
    public Result<Void> add(@RequestBody Category category) {
        checkBackend();
        categoryService.add(category);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody Category category) {
        checkBackend();
        categoryService.update(category);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        checkBackend();
        categoryService.delete(id);
        return Result.success();
    }

    private void checkBackend() {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
