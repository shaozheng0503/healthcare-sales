package com.healthcare.sales.service.impl;

import com.healthcare.sales.entity.Category;
import com.healthcare.sales.mapper.CategoryMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl {

    private final CategoryMapper categoryMapper;

    /** 获取分类树（带children） */
    public List<Map<String, Object>> tree() {
        List<Category> all = categoryMapper.selectAllEnabled();

        // 转为 Map，方便扩展（如加 children 字段）
        Map<Long, Map<String, Object>> idMap = all.stream().collect(
                Collectors.toMap(Category::getId, c -> {
                    java.util.LinkedHashMap<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",       c.getId());
                    m.put("name",     c.getName());
                    m.put("parentId", c.getParentId());
                    m.put("sort",     c.getSort());
                    m.put("status",   c.getStatus());
                    m.put("children", new ArrayList<>());
                    return m;
                }));

        List<Map<String, Object>> roots = new ArrayList<>();
        for (Category c : all) {
            Map<String, Object> node = idMap.get(c.getId());
            if (c.getParentId().equals(0L)) {
                roots.add(node);
            } else {
                Map<String, Object> parent = idMap.get(c.getParentId());
                if (parent != null) {
                    ((List<Map<String, Object>>) parent.get("children")).add(node);
                }
            }
        }
        return roots;
    }

    public void add(Category category) {
        categoryMapper.insert(category);
    }

    public void update(Category category) {
        categoryMapper.updateById(category);
    }

    public void delete(Long id) {
        categoryMapper.deleteById(id);
    }
}
