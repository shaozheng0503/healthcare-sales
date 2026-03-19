package com.healthcare.sales.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.entity.Product;
import com.healthcare.sales.entity.StockLog;
import com.healthcare.sales.mapper.CategoryMapper;
import com.healthcare.sales.mapper.ProductMapper;
import com.healthcare.sales.mapper.StockLogMapper;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl {

    private final ProductMapper  productMapper;
    private final StockLogMapper stockLogMapper;
    private final CategoryMapper categoryMapper;

    /** 分页查询（带分类名、支持排序、支持库存预警筛选） */
    public com.baomidou.mybatisplus.core.metadata.IPage<Map<String, Object>> page(
            Integer pageNum, Integer pageSize, String name, Long categoryId, Integer status,
            String orderBy, String orderDir, Boolean stockWarnOnly) {
        Page<Map<String, Object>> p = new Page<>(pageNum, pageSize);
        return productMapper.selectPageWithCategory(p, name, categoryId, status, orderBy, orderDir, stockWarnOnly);
    }

    /** 商品详情（含分类名） */
    public Map<String, Object> detail(Long id) {
        Product p = productMapper.selectById(id);
        if (p == null) throw BusinessException.of("商品不存在");
        Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("id",            p.getId());
        result.put("categoryId",    p.getCategoryId());
        result.put("name",          p.getName());
        result.put("description",   p.getDescription());
        result.put("price",         p.getPrice());
        result.put("originalPrice", p.getOriginalPrice());
        result.put("stock",         p.getStock());
        result.put("stockWarning",  p.getStockWarning());
        result.put("imageUrl",      p.getImageUrl());
        result.put("images",        p.getImages());
        result.put("salesCount",    p.getSalesCount());
        result.put("status",        p.getStatus());
        // 查询分类名
        if (p.getCategoryId() != null) {
            com.healthcare.sales.entity.Category cat = categoryMapper.selectById(p.getCategoryId());
            result.put("categoryName", cat != null ? cat.getName() : null);
        }
        return result;
    }

    /** 新增 */
    public void add(Product product) {
        product.setCreatedBy(UserContext.getUserId());
        productMapper.insert(product);
    }

    /** 编辑 */
    public void update(Product product) {
        productMapper.updateById(product);
    }

    /** 删除 */
    public void delete(Long id) {
        productMapper.deleteById(id);
    }

    /** 上下架 */
    public void updateStatus(Long id, Integer status) {
        Product p = new Product();
        p.setId(id);
        p.setStatus(status);
        productMapper.updateById(p);
    }

    /** 手动调整库存 */
    @Transactional(rollbackFor = Exception.class)
    public void adjustStock(Long productId, Integer type, Integer changeQty, String remark) {
        Product product = productMapper.selectById(productId);
        if (product == null) throw BusinessException.of("商品不存在");

        // 手动调整仅允许 type=1（入库）和 type=3（手动调整），type=2（出库）和 type=4（取消回滚）由系统自动处理
        if (type != 1 && type != 3) {
            throw BusinessException.of("不支持的库存调整类型");
        }

        int before    = product.getStock();
        int after;
        if (type == 1) {
            // 入库（增加）
            if (changeQty <= 0) throw BusinessException.of("入库数量必须大于0");
            after = before + changeQty;
        } else {
            // 手动调整：changeQty 可正可负（正=增加，负=减少）
            after = before + changeQty;
            if (after < 0) throw BusinessException.of("调整后库存不能小于0");
        }

        Product update = new Product();
        update.setId(productId);
        update.setStock(after);
        productMapper.updateById(update);

        // 记录日志
        StockLog log = new StockLog();
        log.setProductId(productId);
        log.setProductName(product.getName());
        log.setType(type);
        log.setChangeQuantity(type == 2 ? -changeQty : changeQty);
        log.setBeforeStock(before);
        log.setAfterStock(after);
        log.setOperatorId(UserContext.getUserId());
        log.setRemark(remark);
        stockLogMapper.insert(log);
    }

    /** 库存变动日志分页（支持按商品名搜索） */
    public Page<StockLog> stockLog(Integer pageNum, Integer pageSize, Integer type, String name) {
        Page<StockLog> p = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<StockLog> w = new LambdaQueryWrapper<StockLog>()
                .like(name != null && !name.isEmpty(), StockLog::getProductName, name)
                .eq(type != null, StockLog::getType, type)
                .orderByDesc(StockLog::getCreatedAt);
        return stockLogMapper.selectPage(p, w);
    }

    /** 热销商品 */
    public List<Map<String, Object>> hotProducts(int limit) {
        return productMapper.selectHotProducts(limit);
    }
}
