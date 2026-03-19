<template>
  <el-card>
    <!-- 搜索栏 -->
    <el-form :model="query" inline>
      <el-form-item label="订单编号">
        <el-input v-model="query.orderNo" placeholder="订单编号" clearable style="width:180px" />
      </el-form-item>
      <el-form-item label="订单状态">
        <el-select v-model="query.status" clearable placeholder="全部" style="width:120px">
          <el-option v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间">
        <el-date-picker v-model="query.dateRange" type="daterange" range-separator="至"
          start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadList">搜索</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column label="订单编号" prop="orderNo" width="200" />
      <el-table-column label="下单用户" prop="username" width="100" />
      <el-table-column label="收货人" prop="receiverName" width="90" />
      <el-table-column label="收货电话" prop="receiverPhone" width="120" />
      <el-table-column label="实付金额" width="110">
        <template #default="{ row }">
          <span style="color:#f56c6c;font-weight:600">¥{{ row.payAmount }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusMap[row.status]?.type" size="small">
            {{ statusMap[row.status]?.label }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" prop="createdAt" width="160" />
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewDetail(row)">详情</el-button>
          <el-button v-if="row.status === 1" type="success" link size="small" @click="ship(row)">发货</el-button>
          <el-button v-if="row.status === 0" type="warning" link size="small" @click="cancelOrder(row)">取消</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
      v-model:current-page="query.page" v-model:page-size="query.size"
      :total="total" layout="total, sizes, prev, pager, next"
      @change="loadList" />
  </el-card>

  <!-- 订单详情 -->
  <el-dialog v-model="detailVisible" title="订单详情" width="700px">
    <el-descriptions :column="2" border>
      <el-descriptions-item label="订单编号">{{ detail.orderNo }}</el-descriptions-item>
      <el-descriptions-item label="订单状态">
        <el-tag :type="statusMap[detail.status]?.type">{{ statusMap[detail.status]?.label }}</el-tag>
      </el-descriptions-item>
      <el-descriptions-item label="下单时间">{{ detail.createdAt }}</el-descriptions-item>
      <el-descriptions-item label="支付时间">{{ detail.payTime || '-' }}</el-descriptions-item>
      <el-descriptions-item label="收货人">{{ detail.receiverName }}</el-descriptions-item>
      <el-descriptions-item label="收货电话">{{ detail.receiverPhone }}</el-descriptions-item>
      <el-descriptions-item label="收货地址" :span="2">{{ detail.receiverAddress }}</el-descriptions-item>
      <el-descriptions-item label="买家备注" :span="2">{{ detail.remark || '无' }}</el-descriptions-item>
    </el-descriptions>

    <div style="margin-top:16px;font-weight:600;margin-bottom:8px">商品明细</div>
    <el-table :data="detail.items" border size="small">
      <el-table-column label="商品名称" prop="productName" />
      <el-table-column label="单价" width="90">
        <template #default="{ row }">¥{{ row.price }}</template>
      </el-table-column>
      <el-table-column label="数量" prop="quantity" width="70" />
      <el-table-column label="小计" width="100">
        <template #default="{ row }">¥{{ row.totalPrice }}</template>
      </el-table-column>
    </el-table>
    <div style="text-align:right;margin-top:12px;font-size:16px;font-weight:600">
      实付金额：<span style="color:#f56c6c">¥{{ detail.payAmount }}</span>
    </div>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api'

const loading = ref(false)
const list    = ref([])
const total   = ref(0)
const query   = reactive({ page: 1, size: 10, orderNo: '', status: null, dateRange: null })

const statusOptions = [
  { label: '待支付', value: 0 },
  { label: '已支付', value: 1 },
  { label: '已发货', value: 2 },
  { label: '已完成', value: 3 },
  { label: '已取消', value: 4 }
]
const statusMap = {
  0: { label: '待支付', type: 'info' },
  1: { label: '已支付', type: 'warning' },
  2: { label: '已发货', type: 'primary' },
  3: { label: '已完成', type: 'success' },
  4: { label: '已取消', type: 'danger' }
}

const detailVisible = ref(false)
const detail        = ref({})

onMounted(loadList)

async function loadList() {
  loading.value = true
  try {
    const params = { ...query }
    if (query.dateRange) {
      params.startDate = query.dateRange[0]
      params.endDate   = query.dateRange[1]
    }
    delete params.dateRange
    const res = await orderApi.list(params)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  Object.assign(query, { page: 1, orderNo: '', status: null, dateRange: null })
  loadList()
}

async function viewDetail(row) {
  const res = await orderApi.detail(row.orderNo)
  detail.value = res.data
  detailVisible.value = true
}

async function ship(row) {
  await ElMessageBox.confirm(`确定对订单 ${row.orderNo} 发货？`, '提示')
  await orderApi.ship(row.orderNo)
  ElMessage.success('已发货')
  loadList()
}

async function cancelOrder(row) {
  await ElMessageBox.confirm(`确定取消订单 ${row.orderNo}？`, '警告', { type: 'warning' })
  await orderApi.cancel(row.orderNo)
  ElMessage.success('已取消')
  loadList()
}
</script>
