<template>
  <div>
    <!-- 库存预警卡片 -->
    <el-alert v-if="warnCount > 0" type="warning" :closable="false" style="margin-bottom:16px">
      <template #title>
        <el-icon><Warning /></el-icon>
        当前有 <strong>{{ warnCount }}</strong> 个商品库存低于预警值，请及时补货！
      </template>
    </el-alert>

    <!-- tabs：库存列表 / 变动日志 -->
    <el-tabs v-model="activeTab">
      <el-tab-pane label="库存列表" name="list">
        <el-card>
          <el-form :model="query" inline style="margin-bottom:8px">
            <el-form-item label="商品名称">
              <el-input v-model="query.name" placeholder="搜索商品" clearable style="width:200px" />
            </el-form-item>
            <el-form-item>
              <el-checkbox v-model="query.warnOnly">仅显示预警商品</el-checkbox>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadStock">搜索</el-button>
            </el-form-item>
          </el-form>

          <el-table :data="stockList" v-loading="loading" border stripe>
            <el-table-column label="商品名称" prop="name" min-width="160" show-overflow-tooltip />
            <el-table-column label="分类" prop="categoryName" width="110" />
            <el-table-column label="当前库存" prop="stock" width="100">
              <template #default="{ row }">
                <el-tag :type="row.stock <= row.stockWarning ? 'danger' : 'success'" size="small">
                  {{ row.stock }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="预警值" prop="stockWarning" width="90" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <span v-if="row.stock <= row.stockWarning" style="color:#f56c6c">⚠ 库存不足</span>
                <span v-else style="color:#67c23a">正常</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button type="primary" link @click="openAdjust(row)">入库</el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
            v-model:current-page="query.page" v-model:page-size="query.size"
            :total="total" layout="total, prev, pager, next" @change="loadStock" />
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="库存变动日志" name="log">
        <el-card>
          <el-form inline style="margin-bottom:8px">
            <el-form-item label="商品名称">
              <el-input v-model="logQuery.name" placeholder="搜索" clearable style="width:180px" />
            </el-form-item>
            <el-form-item label="变动类型">
              <el-select v-model="logQuery.type" clearable style="width:130px">
                <el-option label="入库" :value="1" />
                <el-option label="出库(订单)" :value="2" />
                <el-option label="手动调整" :value="3" />
                <el-option label="取消回滚" :value="4" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadLog">搜索</el-button>
            </el-form-item>
          </el-form>

          <el-table :data="logList" v-loading="logLoading" border stripe>
            <el-table-column label="商品名称" prop="productName" min-width="140" show-overflow-tooltip />
            <el-table-column label="变动类型" width="110">
              <template #default="{ row }">
                <el-tag :type="typeMap[row.type]?.type" size="small">{{ typeMap[row.type]?.label }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="变动数量" width="100">
              <template #default="{ row }">
                <span :style="{ color: row.changeQuantity > 0 ? '#67c23a' : '#f56c6c', fontWeight: 600 }">
                  {{ row.changeQuantity > 0 ? '+' : '' }}{{ row.changeQuantity }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="变动前" prop="beforeStock" width="80" />
            <el-table-column label="变动后" prop="afterStock" width="80" />
            <el-table-column label="关联订单" prop="orderNo" width="180" show-overflow-tooltip />
            <el-table-column label="备注" prop="remark" show-overflow-tooltip />
            <el-table-column label="时间" prop="createdAt" width="160" />
          </el-table>

          <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
            v-model:current-page="logQuery.page" v-model:page-size="logQuery.size"
            :total="logTotal" layout="total, prev, pager, next" @change="loadLog" />
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>

  <!-- 入库对话框 -->
  <el-dialog v-model="adjustVisible" title="商品入库" width="420px">
    <el-descriptions :column="1" border>
      <el-descriptions-item label="商品名称">{{ adjustForm.productName }}</el-descriptions-item>
      <el-descriptions-item label="当前库存">{{ adjustForm.currentStock }}</el-descriptions-item>
    </el-descriptions>
    <el-form style="margin-top:16px" label-width="90px">
      <el-form-item label="入库数量">
        <el-input-number v-model="adjustForm.changeQuantity" :min="1" style="width:100%" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="adjustForm.remark" placeholder="可填写入库原因" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="adjustVisible = false">取消</el-button>
      <el-button type="primary" @click="submitAdjust">确认入库</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { productApi } from '@/api'

const activeTab  = ref('list')
const loading    = ref(false)
const stockList  = ref([])
const total      = ref(0)
const warnCount  = ref(0)
const query      = reactive({ page: 1, size: 15, name: '', warnOnly: false })

const logLoading = ref(false)
const logList    = ref([])
const logTotal   = ref(0)
const logQuery   = reactive({ page: 1, size: 15, name: '', type: null })

const typeMap = {
  1: { label: '入库',     type: 'success' },
  2: { label: '出库(订单)', type: 'warning' },
  3: { label: '手动调整', type: 'info' },
  4: { label: '取消回滚', type: 'primary' }
}

const adjustVisible = ref(false)
const adjustForm    = reactive({ productId: null, productName: '', currentStock: 0, changeQuantity: 1, remark: '', type: 1 })

onMounted(() => { loadStock(); loadLog() })

async function loadStock() {
  loading.value = true
  try {
    const params = {
      page: query.page,
      size: query.size,
      name: query.name || undefined,
      stockWarnOnly: query.warnOnly || undefined
    }
    const res = await productApi.page(params)
    stockList.value = res.data.records
    total.value     = res.data.total
  } finally {
    loading.value = false
  }
  // 单独查一次库存预警总数（不分页）
  try {
    const warnRes = await productApi.page({ page: 1, size: 1, stockWarnOnly: true })
    warnCount.value = warnRes.data.total
  } catch { /* ignore */ }
}

async function loadLog() {
  logLoading.value = true
  try {
    const res = await productApi.stockLog(logQuery)
    logList.value  = res.data.records
    logTotal.value = res.data.total
  } finally {
    logLoading.value = false
  }
}

function openAdjust(row) {
  Object.assign(adjustForm, { productId: row.id, productName: row.name, currentStock: row.stock, changeQuantity: 1, remark: '', type: 1 })
  adjustVisible.value = true
}

async function submitAdjust() {
  await productApi.adjustStock(adjustForm)
  ElMessage.success(`入库成功，已增加 ${adjustForm.changeQuantity} 件库存`)
  adjustVisible.value = false
  loadStock()
  loadLog()
}
</script>
