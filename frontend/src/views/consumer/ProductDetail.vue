<template>
  <div v-loading="loading" class="product-detail">
    <el-card v-if="product">
      <el-row :gutter="40">
        <!-- 商品图片 -->
        <el-col :span="10">
          <el-image :src="product.imageUrl" style="width:100%;border-radius:8px" fit="contain" />
        </el-col>

        <!-- 商品信息 -->
        <el-col :span="14">
          <h1 class="product-name">{{ product.name }}</h1>
          <div class="product-price-area">
            <span class="price">¥{{ product.price }}</span>
            <span v-if="product.originalPrice" class="original-price">¥{{ product.originalPrice }}</span>
            <el-tag type="danger" size="small" v-if="product.originalPrice">
              省¥{{ (product.originalPrice - product.price).toFixed(2) }}
            </el-tag>
          </div>
          <el-divider />

          <el-descriptions :column="1" label-width="80px" size="small">
            <el-descriptions-item label="分类">{{ product.categoryName }}</el-descriptions-item>
            <el-descriptions-item label="库存">
              <el-tag :type="product.stock > 0 ? 'success' : 'danger'" size="small">
                {{ product.stock > 0 ? `有货（剩余${product.stock}件）` : '已售罄' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="累计销量">{{ product.salesCount }} 件</el-descriptions-item>
          </el-descriptions>

          <el-divider />

          <!-- 数量选择 -->
          <div class="quantity-area">
            <span style="color:#606266;font-size:14px">购买数量</span>
            <el-input-number v-model="quantity" :min="1" :max="product.stock" style="margin-left:12px" />
          </div>

          <div class="action-area">
            <el-button type="warning" size="large" icon="ShoppingCart" :disabled="product.stock === 0"
              @click="addToCart">加入购物车</el-button>
            <el-button type="primary" size="large" :disabled="product.stock === 0"
              @click="buyNow">立即购买</el-button>
          </div>
        </el-col>
      </el-row>

      <!-- 商品描述 -->
      <el-divider>商品详情</el-divider>
      <div class="product-desc">{{ product.description || '暂无详情介绍' }}</div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, inject, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { productApi, cartApi } from '@/api'
import { useUserStore } from '@/store/user'

const refreshCart = inject('refreshCart', () => {})

const route     = useRoute()
const router    = useRouter()
const userStore = useUserStore()

const loading  = ref(false)
const product  = ref(null)
const quantity = ref(1)

onMounted(async () => {
  loading.value = true
  try {
    const res = await productApi.detail(route.params.id)
    product.value = res.data
  } finally {
    loading.value = false
  }
})

async function addToCart() {
  if (!userStore.token) { router.push('/login'); return }
  await cartApi.add({ productId: product.value.id, quantity: quantity.value })
  ElMessage.success('已加入购物车')
  refreshCart()
}

async function buyNow() {
  if (!userStore.token) { router.push('/login'); return }
  await cartApi.add({ productId: product.value.id, quantity: quantity.value })
  router.push('/cart')
}
</script>

<style scoped>
.product-detail :deep(.el-card) { border-radius: var(--radius-lg) !important; padding: 8px; }
.product-name {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 16px;
  line-height: 1.4;
}
.product-price-area {
  display: flex;
  align-items: baseline;
  gap: 14px;
  margin-bottom: 16px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #fef2f2 0%, #fff1f2 100%);
  border-radius: var(--radius-md);
}
.price { color: #e53e3e; font-size: 36px; font-weight: 700; letter-spacing: -1px; }
.original-price { color: var(--text-muted); font-size: 16px; text-decoration: line-through; }
.quantity-area { display: flex; align-items: center; margin-bottom: 28px; gap: 12px; }
.action-area { display: flex; gap: 16px; }
.action-area :deep(.el-button) { height: 44px; padding: 0 28px; border-radius: 10px; font-size: 15px; }
.product-desc {
  line-height: 2;
  color: var(--text-secondary);
  white-space: pre-wrap;
  font-size: 15px;
}
</style>
