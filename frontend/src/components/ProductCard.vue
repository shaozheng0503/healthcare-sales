<template>
  <div class="product-card hover-lift" @click="$router.push(`/product/${product.id}`)">
    <div class="card-image">
      <el-image :src="product.imageUrl" fit="cover" class="product-img">
        <template #error>
          <div class="img-fallback">
            <el-icon size="36" color="#cbd5e1"><Picture /></el-icon>
          </div>
        </template>
      </el-image>
      <div v-if="product.originalPrice && product.originalPrice > product.price" class="discount-badge">
        省¥{{ (product.originalPrice - product.price).toFixed(0) }}
      </div>
    </div>

    <div class="card-body">
      <div class="product-name">{{ product.name }}</div>
      <div class="price-row">
        <span class="price-current">¥{{ product.price }}</span>
        <span v-if="product.originalPrice" class="price-original">¥{{ product.originalPrice }}</span>
      </div>
      <div class="card-footer">
        <span class="sales-text">已售 {{ product.salesCount || 0 }}</span>
        <button class="add-cart-btn" @click.stop="$emit('addCart', product)">
          <el-icon><ShoppingCart /></el-icon>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({ product: { type: Object, required: true } })
defineEmits(['addCart'])
</script>

<style scoped>
.product-card {
  background: var(--bg-card);
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
}

.card-image {
  position: relative;
  overflow: hidden;
  aspect-ratio: 1 / 1;
  background: #f8fafc;
}
.product-img { width: 100%; height: 100%; display: block; }
.img-fallback {
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
}

.discount-badge {
  position: absolute;
  top: 8px; right: 8px;
  background: var(--accent-gradient);
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 4px;
}

.card-body { padding: 12px 14px 14px; }

.product-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 40px;
  margin-bottom: 10px;
}

.price-row {
  display: flex;
  align-items: baseline;
  gap: 6px;
  margin-bottom: 10px;
}
.price-current {
  font-size: 20px;
  font-weight: 700;
  color: #e53e3e;
  letter-spacing: -0.5px;
}
.price-original {
  font-size: 12px;
  color: var(--text-muted);
  text-decoration: line-through;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.sales-text {
  font-size: 12px;
  color: var(--text-muted);
}

.add-cart-btn {
  width: 32px; height: 32px;
  border: none;
  border-radius: 8px;
  background: var(--primary-gradient);
  color: #fff;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: transform 0.2s, box-shadow 0.2s;
  font-size: 16px;
}
.add-cart-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(46,125,50,0.3);
}
</style>
