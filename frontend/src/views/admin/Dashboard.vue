<template>
  <div class="dashboard">
    <!-- 概览卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6" v-for="(card, i) in statCards" :key="card.label">
        <div class="stat-card" :class="`stat-card-${i}`">
          <div class="stat-card-inner">
            <div>
              <div class="stat-label">{{ card.label }}</div>
              <div class="stat-value">{{ card.value }}</div>
            </div>
            <div class="stat-icon-wrap">
              <el-icon :size="28" color="#fff">
                <component :is="card.icon" />
              </el-icon>
            </div>
          </div>
          <div class="stat-footer">
            <span>较昨日</span>
            <span :style="{ color: card.trend >= 0 ? '#dcfce7' : '#fecaca' }">
              {{ card.trend >= 0 ? '+' : '' }}{{ card.trend }}%
            </span>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top:20px">
      <!-- 近7天销售趋势 -->
      <el-col :span="16">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>近7天销售趋势</span>
              <el-radio-group v-model="trendType" size="small" @change="loadTrend">
                <el-radio-button value="7">近7天</el-radio-button>
                <el-radio-button value="30">近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="trendChartRef" style="height:280px"></div>
        </el-card>
      </el-col>

      <!-- 订单状态占比 -->
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header><span>订单状态分布</span></template>
          <div ref="orderPieRef" style="height:280px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top:20px">
      <!-- 热销商品 -->
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header><span>热销商品 Top 5</span></template>
          <el-table :data="hotProducts" size="small">
            <el-table-column label="排名" width="50" type="index" />
            <el-table-column label="商品名称" prop="name" show-overflow-tooltip />
            <el-table-column label="销量" prop="salesCount" width="80" />
            <el-table-column label="销售额" width="100">
              <template #default="{ row }">¥{{ row.revenue }}</template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 库存预警 -->
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>库存预警</span>
              <el-badge :value="lowStockList.length" type="danger" />
            </div>
          </template>
          <el-table :data="lowStockList" size="small">
            <el-table-column label="商品名称" prop="name" show-overflow-tooltip />
            <el-table-column label="当前库存" prop="stock" width="80">
              <template #default="{ row }">
                <el-tag type="danger" size="small">{{ row.stock }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="预警值" prop="stockWarning" width="70" />
            <el-table-column label="操作" width="70">
              <template #default>
                <el-link type="primary" @click="$router.push('/admin/stock')">补货</el-link>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { statisticsApi } from '@/api'

const trendType      = ref('7')
const trendChartRef  = ref()
const orderPieRef    = ref()
const hotProducts    = ref([])
const lowStockList   = ref([])

const statCards = ref([
  { label: '今日订单', value: '--', icon: 'ShoppingCart', color: '#409eff', trend: 0 },
  { label: '今日销售额', value: '--', icon: 'Money',        color: '#67c23a', trend: 0 },
  { label: '商品总数',   value: '--', icon: 'Goods',        color: '#e6a23c', trend: 0 },
  { label: '用户总数',   value: '--', icon: 'User',         color: '#f56c6c', trend: 0 }
])

let trendChart, orderPie

onMounted(async () => {
  initCharts()
  await Promise.all([loadOverview(), loadTrend(), loadHotProducts(), loadOrderPie()])
})

function initCharts() {
  trendChart = echarts.init(trendChartRef.value)
  orderPie   = echarts.init(orderPieRef.value)
}

async function loadOverview() {
  try {
    const res = await statisticsApi.overview()
    const d = res.data
    statCards.value[0].value = d.todayOrders
    statCards.value[1].value = `¥${d.todaySales}`
    statCards.value[2].value = d.totalProducts
    statCards.value[3].value = d.totalUsers
    lowStockList.value = d.lowStockList || []
  } catch {}
}

async function loadTrend() {
  try {
    const res = await statisticsApi.salesTrend({ days: trendType.value })
    const d = res.data
    trendChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['销售额', '订单数'] },
      xAxis: { type: 'category', data: d.dates },
      yAxis: [
        { type: 'value', name: '销售额(元)' },
        { type: 'value', name: '订单数' }
      ],
      series: [
        { name: '销售额', type: 'line', smooth: true, data: d.sales, areaStyle: { opacity: 0.1 }, itemStyle: { color: '#67c23a' } },
        { name: '订单数', type: 'bar',  yAxisIndex: 1, data: d.orders, itemStyle: { color: '#409eff' } }
      ]
    })
  } catch {}
}

async function loadHotProducts() {
  try {
    const res = await statisticsApi.hotProducts()
    hotProducts.value = res.data || []
  } catch {}
}

async function loadOrderPie() {
  try {
    const res = await statisticsApi.orderStatus()
    orderPie.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      legend: { bottom: 0 },
      series: [{
        type: 'pie',
        radius: ['40%', '70%'],
        data: res.data || [],
        label: { show: false }
      }]
    })
  } catch {}
}
</script>

<style scoped>
.dashboard { padding: 4px; }

.stat-card {
  border-radius: var(--radius-lg);
  padding: 22px 24px;
  color: #fff;
  transition: transform 0.3s, box-shadow 0.3s;
}
.stat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 30px rgba(0,0,0,0.15); }
.stat-card-0 { background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); }
.stat-card-1 { background: linear-gradient(135deg, #22c55e 0%, #15803d 100%); }
.stat-card-2 { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); }
.stat-card-3 { background: linear-gradient(135deg, #f43f5e 0%, #be123c 100%); }

.stat-card-inner {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.stat-value { font-size: 30px; font-weight: 700; margin-top: 4px; letter-spacing: -0.5px; }
.stat-label { font-size: 14px; opacity: 0.85; }
.stat-icon-wrap {
  width: 48px; height: 48px;
  background: rgba(255,255,255,0.2);
  border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
}
.stat-footer {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid rgba(255,255,255,0.2);
  display: flex;
  gap: 8px;
  font-size: 13px;
  opacity: 0.8;
}
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
