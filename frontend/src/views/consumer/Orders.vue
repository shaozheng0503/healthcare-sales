<template>
  <div>
    <h2 class="page-title">我的订单</h2>

    <el-card class="orders-card">
      <el-tabs v-model="activeStatus" class="status-tabs">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="待支付" name="0" />
        <el-tab-pane label="待发货" name="1" />
        <el-tab-pane label="已发货" name="2" />
        <el-tab-pane label="已完成" name="3" />
        <el-tab-pane label="已取消" name="4" />
      </el-tabs>

      <div v-loading="loading">
        <!-- 空状态 -->
        <div v-if="!loading && list.length === 0" class="empty-state">
          <el-icon size="56" color="#cbd5e1"><List /></el-icon>
          <p>暂无相关订单</p>
        </div>

        <!-- 订单卡片列表 -->
        <transition-group name="list" tag="div">
          <div v-for="order in list" :key="order.orderNo" class="order-card">
            <div class="order-header">
              <div class="order-meta">
                <span class="order-no">{{ order.orderNo }}</span>
                <span class="order-time">{{ order.createdAt }}</span>
              </div>
              <el-tag :type="statusMap[order.status]?.type" size="small" effect="plain" round>
                {{ statusMap[order.status]?.label }}
              </el-tag>
            </div>

            <div class="order-items">
              <div v-for="item in order.items" :key="item.id" class="order-item"
                @click="$router.push(`/product/${item.productId}`)">
                <el-image :src="item.productImage" class="item-thumb" fit="cover">
                  <template #error><div class="item-thumb-fallback"><el-icon><Picture /></el-icon></div></template>
                </el-image>
                <div class="item-body">
                  <div class="item-name">{{ item.productName }}</div>
                  <div class="item-detail">
                    <span class="item-price">¥{{ item.price }}</span>
                    <span class="item-qty">x{{ item.quantity }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="order-footer">
              <span class="order-total">
                共 {{ order.items?.length || 0 }} 件商品，实付
                <strong>¥{{ order.payAmount }}</strong>
              </span>
              <div class="order-actions">
                <el-button v-if="order.status === 0" type="primary" size="small" round @click="pay(order)">
                  立即支付
                </el-button>
                <el-button v-if="order.status === 0" size="small" round @click="cancel(order)">
                  取消订单
                </el-button>
                <el-button v-if="order.status === 2" type="success" size="small" round @click="complete(order)">
                  确认收货
                </el-button>
              </div>
            </div>
          </div>
        </transition-group>
      </div>

      <el-pagination style="margin-top:20px;justify-content:center;display:flex"
        v-model:current-page="query.page" :total="total"
        layout="prev, pager, next" @change="loadList" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api'

const loading      = ref(false)
const list         = ref([])
const total        = ref(0)
const activeStatus = ref('')
const query        = reactive({ page: 1, size: 5, status: null })

const statusMap = {
  0: { label: '待支付', type: 'info' },
  1: { label: '待发货', type: 'warning' },
  2: { label: '已发货', type: 'primary' },
  3: { label: '已完成', type: 'success' },
  4: { label: '已取消', type: 'danger' }
}

watch(activeStatus, val => {
  query.status = val === '' ? null : Number(val)
  query.page = 1
  loadList()
})

onMounted(loadList)

async function loadList() {
  loading.value = true
  try {
    const res = await orderApi.myList(query)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

async function pay(order) {
  await orderApi.pay(order.orderNo)
  ElMessage.success('支付成功')
  loadList()
}

async function cancel(order) {
  await ElMessageBox.confirm('确定取消此订单？', '提示', { type: 'warning' })
  await orderApi.cancel(order.orderNo)
  ElMessage.success('已取消')
  loadList()
}

async function complete(order) {
  await ElMessageBox.confirm('确认已收到商品？', '提示')
  await orderApi.complete(order.orderNo)
  ElMessage.success('确认收货成功')
  loadList()
}
</script>

<style scoped>
.page-title { font-size: 22px; font-weight: 700; margin-bottom: 24px; color: var(--text-primary); }
.orders-card { border-radius: var(--radius-lg) !important; }

.status-tabs :deep(.el-tabs__item) { font-size: 15px; }
.status-tabs :deep(.el-tabs__active-bar) { background: var(--primary-gradient); height: 3px; border-radius: 2px; }

.empty-state {
  text-align: center; padding: 60px 0; color: var(--text-muted);
}
.empty-state p { margin-top: 12px; font-size: 15px; }

.order-card {
  border: 1px solid var(--border-light);
  border-radius: var(--radius-md);
  margin-bottom: 16px;
  overflow: hidden;
  transition: box-shadow 0.2s;
}
.order-card:hover { box-shadow: var(--shadow-md); }

.order-header {
  background: #f8fafc;
  padding: 14px 20px;
  display: flex; justify-content: space-between; align-items: center;
}
.order-meta { display: flex; align-items: center; gap: 16px; }
.order-no { font-family: 'SF Mono', 'Consolas', monospace; font-size: 13px; color: var(--text-secondary); }
.order-time { color: var(--text-muted); font-size: 13px; }

.order-items { padding: 4px 0; }
.order-item {
  display: flex; gap: 14px; padding: 14px 20px; cursor: pointer;
  border-top: 1px solid #f1f5f9;
  transition: background 0.15s;
}
.order-item:hover { background: #fafafa; }

.item-thumb { width: 64px; height: 64px; border-radius: 8px; flex-shrink: 0; }
.item-thumb-fallback {
  width: 64px; height: 64px; border-radius: 8px; background: #f1f5f9;
  display: flex; align-items: center; justify-content: center; color: #cbd5e1; font-size: 20px;
}
.item-body { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.item-name { font-size: 14px; color: var(--text-primary); line-height: 1.5; }
.item-detail { margin-top: 4px; display: flex; gap: 10px; }
.item-price { font-size: 14px; color: #e53e3e; font-weight: 500; }
.item-qty { font-size: 13px; color: var(--text-muted); }

.order-footer {
  padding: 14px 20px;
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid var(--border-light);
  background: #fafafa;
}
.order-total { font-size: 14px; color: var(--text-secondary); }
.order-total strong { color: #e53e3e; font-size: 18px; }
.order-actions { display: flex; gap: 8px; }

/* 列表动画 */
.list-enter-active, .list-leave-active { transition: all 0.3s ease; }
.list-enter-from { opacity: 0; transform: translateY(12px); }
.list-leave-to { opacity: 0; transform: translateX(-20px); }
</style>
