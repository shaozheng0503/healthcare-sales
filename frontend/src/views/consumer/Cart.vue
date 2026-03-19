<template>
  <div class="cart-page">
    <div class="page-header">
      <h2>我的购物车</h2>
      <span v-if="cartList.length" class="cart-count">共 {{ cartList.length }} 件商品</span>
    </div>

    <!-- 空状态 -->
    <div v-if="!loading && cartList.length === 0" class="empty-state">
      <el-icon size="72" color="#cbd5e1"><ShoppingCart /></el-icon>
      <p class="empty-text">购物车还是空的</p>
      <p class="empty-hint">快去挑选心仪的保健好物吧</p>
      <el-button type="primary" size="large" style="margin-top:20px;border-radius:10px" @click="$router.push('/products')">
        去选购
      </el-button>
    </div>

    <el-row v-else :gutter="24">
      <el-col :span="17">
        <el-card>
          <el-table :data="cartList" v-loading="loading" @selection-change="handleSelect"
            :header-cell-style="{ background: '#f8fafc', color: '#475569', fontWeight: 600 }">
            <el-table-column type="selection" width="50" />
            <el-table-column label="商品信息" min-width="260">
              <template #default="{ row }">
                <div class="product-cell" @click="$router.push(`/product/${row.productId}`)">
                  <el-image :src="row.productImage" class="product-thumb" fit="cover">
                    <template #error><div class="thumb-fallback"><el-icon><Picture /></el-icon></div></template>
                  </el-image>
                  <span class="product-name-text">{{ row.productName }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="单价" width="100" align="center">
              <template #default="{ row }">
                <span class="price-text">¥{{ row.price }}</span>
              </template>
            </el-table-column>
            <el-table-column label="数量" width="150" align="center">
              <template #default="{ row }">
                <el-input-number v-model="row.quantity" :min="1" :max="row.stock" size="small"
                  @change="updateCart(row)" />
              </template>
            </el-table-column>
            <el-table-column label="小计" width="110" align="center">
              <template #default="{ row }">
                <span class="subtotal-text">¥{{ (row.price * row.quantity).toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="70" align="center">
              <template #default="{ row }">
                <el-button type="danger" link @click="removeItem(row)">
                  <el-icon><Delete /></el-icon>
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 结算面板 -->
      <el-col :span="7">
        <div class="settle-card">
          <div class="settle-title">订单摘要</div>
          <div class="settle-row">
            <span>已选商品</span>
            <span class="settle-highlight">{{ selectedList.length }} 件</span>
          </div>
          <div class="settle-row">
            <span>商品金额</span>
            <span>¥{{ totalAmount }}</span>
          </div>
          <div class="settle-row">
            <span>运费</span>
            <span style="color:var(--primary)">免运费</span>
          </div>
          <div class="settle-divider"></div>
          <div class="settle-row settle-total">
            <span>应付总额</span>
            <span class="total-price">¥{{ totalAmount }}</span>
          </div>
          <el-button type="primary" size="large" :disabled="!selectedList.length"
            style="width:100%;height:46px;border-radius:10px;font-size:16px;margin-top:20px"
            @click="goCheckout">
            去结算（{{ selectedList.length }}）
          </el-button>
          <el-button link style="width:100%;margin-top:12px;color:var(--text-muted)" @click="clearCart">
            <el-icon><Delete /></el-icon> 清空购物车
          </el-button>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { cartApi } from '@/api'

const router      = useRouter()
const loading     = ref(false)
const cartList    = ref([])
const selectedList = ref([])

const totalAmount = computed(() => {
  return selectedList.value.reduce((sum, item) => sum + item.price * item.quantity, 0).toFixed(2)
})

onMounted(loadCart)

async function loadCart() {
  loading.value = true
  try {
    const res = await cartApi.list()
    cartList.value = res.data || []
  } finally {
    loading.value = false
  }
}

function handleSelect(selection) {
  selectedList.value = selection
}

async function updateCart(row) {
  await cartApi.update({ id: row.id, quantity: row.quantity })
}

async function removeItem(row) {
  await cartApi.delete(row.id)
  ElMessage.success('已删除')
  loadCart()
}

async function clearCart() {
  await ElMessageBox.confirm('确定清空购物车？', '提示', { type: 'warning' })
  await cartApi.clear()
  ElMessage.success('已清空')
  loadCart()
}

function goCheckout() {
  if (!selectedList.value.length) { ElMessage.warning('请选择商品'); return }
  sessionStorage.setItem('checkoutItems', JSON.stringify(selectedList.value))
  router.push('/checkout')
}
</script>

<style scoped>
.cart-page { }
.page-header {
  display: flex; align-items: baseline; gap: 12px; margin-bottom: 24px;
}
.page-header h2 { font-size: 22px; font-weight: 700; color: var(--text-primary); }
.cart-count { font-size: 14px; color: var(--text-muted); }

.empty-state {
  text-align: center; padding: 80px 0;
  background: var(--bg-card); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}
.empty-text { margin-top: 16px; font-size: 18px; font-weight: 600; color: var(--text-primary); }
.empty-hint { margin-top: 6px; font-size: 14px; color: var(--text-muted); }

.product-cell {
  display: flex; align-items: center; gap: 14px; cursor: pointer;
}
.product-thumb { width: 64px; height: 64px; border-radius: 8px; flex-shrink: 0; }
.thumb-fallback {
  width: 64px; height: 64px; border-radius: 8px; background: #f1f5f9;
  display: flex; align-items: center; justify-content: center; color: #cbd5e1; font-size: 24px;
}
.product-name-text {
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; font-size: 14px; color: var(--text-primary); line-height: 1.5;
}
.product-name-text:hover { color: var(--primary); }
.price-text { color: var(--text-secondary); }
.subtotal-text { color: #e53e3e; font-weight: 600; font-size: 15px; }

.settle-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 28px 24px;
  position: sticky; top: 100px;
}
.settle-title {
  font-size: 18px; font-weight: 700; color: var(--text-primary);
  margin-bottom: 20px; padding-bottom: 16px;
  border-bottom: 2px solid var(--border-light);
}
.settle-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 8px 0; font-size: 14px; color: var(--text-secondary);
}
.settle-highlight { font-weight: 600; color: var(--text-primary); }
.settle-divider { height: 1px; background: var(--border-light); margin: 16px 0; }
.settle-total { font-size: 15px; }
.total-price { font-size: 24px; font-weight: 700; color: #e53e3e; }
</style>
