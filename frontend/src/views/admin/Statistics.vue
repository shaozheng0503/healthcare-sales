<template>
  <div>
    <el-row :gutter="20">
      <!-- 销售趋势 -->
      <el-col :span="24" style="margin-bottom:20px">
        <el-card>
          <template #header>
            <div style="display:flex;justify-content:space-between;align-items:center">
              <span style="font-weight:600">销售趋势分析</span>
              <el-date-picker v-model="dateRange" type="daterange" range-separator="至"
                start-placeholder="开始日期" end-placeholder="结束日期"
                value-format="YYYY-MM-DD" style="width:280px" @change="loadTrend" />
            </div>
          </template>
          <div ref="trendRef" style="height:320px"></div>
        </el-card>
      </el-col>

      <!-- 分类销售占比 -->
      <el-col :span="10" style="margin-bottom:20px">
        <el-card>
          <template #header><span style="font-weight:600">各分类销售占比</span></template>
          <div ref="categoryRef" style="height:300px"></div>
        </el-card>
      </el-col>

      <!-- 热销商品 Top10 -->
      <el-col :span="14" style="margin-bottom:20px">
        <el-card>
          <template #header><span style="font-weight:600">热销商品 Top 10</span></template>
          <div ref="hotRef" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { statisticsApi } from '@/api'

const trendRef    = ref()
const categoryRef = ref()
const hotRef      = ref()
const dateRange   = ref(null)

let trendChart, categoryChart, hotChart

onMounted(async () => {
  trendChart    = echarts.init(trendRef.value)
  categoryChart = echarts.init(categoryRef.value)
  hotChart      = echarts.init(hotRef.value)
  await Promise.all([loadTrend(), loadCategoryRatio(), loadHotProducts()])
})

async function loadTrend() {
  try {
    const params = {}
    if (dateRange.value) {
      params.startDate = dateRange.value[0]
      params.endDate   = dateRange.value[1]
    } else {
      params.days = 30
    }
    const res = await statisticsApi.salesTrend(params)
    const d   = res.data
    trendChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'cross' } },
      legend: { data: ['销售额(元)', '订单数'] },
      grid: { left: 60, right: 60, bottom: 40 },
      xAxis: { type: 'category', data: d.dates, axisLabel: { rotate: 30 } },
      yAxis: [
        { type: 'value', name: '销售额(元)', splitLine: { lineStyle: { type: 'dashed' } } },
        { type: 'value', name: '订单数' }
      ],
      series: [
        {
          name: '销售额(元)', type: 'line', smooth: true, data: d.sales,
          areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [{ offset: 0, color: 'rgba(103,194,58,0.3)' }, { offset: 1, color: 'rgba(103,194,58,0)' }] } },
          lineStyle: { color: '#67c23a', width: 2 }, itemStyle: { color: '#67c23a' }
        },
        {
          name: '订单数', type: 'bar', yAxisIndex: 1, data: d.orders,
          itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] }
        }
      ]
    })
  } catch {}
}

async function loadCategoryRatio() {
  try {
    const res = await statisticsApi.categoryRatio()
    categoryChart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}<br/>销售额：¥{c}<br/>占比：{d}%' },
      legend: { type: 'scroll', bottom: 0 },
      series: [{
        type: 'pie',
        radius: ['35%', '65%'],
        center: ['50%', '44%'],
        data: res.data || [],
        label: { formatter: '{b}\n{d}%' },
        emphasis: { itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.5)' } }
      }]
    })
  } catch {}
}

async function loadHotProducts() {
  try {
    const res  = await statisticsApi.hotProducts()
    const data = (res.data || []).slice(0, 10)
    hotChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 140, right: 40, bottom: 20, top: 20 },
      xAxis: { type: 'value' },
      yAxis: {
        type: 'category',
        data: data.map(d => d.name).reverse(),
        axisLabel: { width: 120, overflow: 'truncate' }
      },
      series: [{
        type: 'bar',
        data: data.map(d => d.salesCount).reverse(),
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0,
            [{ offset: 0, color: '#67c23a' }, { offset: 1, color: '#409eff' }]),
          borderRadius: [0, 4, 4, 0]
        },
        label: { show: true, position: 'right' }
      }]
    })
  } catch {}
}
</script>
