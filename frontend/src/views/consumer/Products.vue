<template>
  <div class="products-page">
    <el-row :gutter="20">
      <!-- 左侧分类 -->
      <el-col :span="4">
        <el-card class="category-menu">
          <div class="cat-title">商品分类</div>
          <el-menu :default-active="activeCategoryId" @select="selectCategory">
            <el-menu-item index="">全部商品</el-menu-item>
            <template v-for="cat in categoryTree" :key="cat.id">
              <el-sub-menu :index="String(cat.id)">
                <template #title>{{ cat.name }}</template>
                <el-menu-item v-for="sub in cat.children" :key="sub.id" :index="String(sub.id)">
                  {{ sub.name }}
                </el-menu-item>
              </el-sub-menu>
            </template>
          </el-menu>
        </el-card>
      </el-col>

      <!-- 右侧商品列表 -->
      <el-col :span="20">
        <!-- 筛选栏 -->
        <el-card style="margin-bottom:16px">
          <div class="filter-bar">
            <el-input v-model="query.keyword" placeholder="搜索商品名称" clearable style="width:220px"
              prefix-icon="Search" @keyup.enter="loadList" @clear="loadList" />
            <el-select v-model="query.sort" style="width:140px" @change="loadList">
              <el-option label="默认排序"   value="" />
              <el-option label="价格从低到高" value="price_asc" />
              <el-option label="价格从高到低" value="price_desc" />
              <el-option label="销量最高"   value="sales_desc" />
            </el-select>
            <el-button type="primary" @click="loadList">搜索</el-button>
          </div>
        </el-card>

        <!-- 商品网格 -->
        <div v-loading="loading">
          <div v-if="list.length === 0" style="text-align:center;padding:60px;color:#909399">
            <el-icon size="60"><Box /></el-icon>
            <p style="margin-top:12px">暂无商品</p>
          </div>
          <el-row :gutter="16" v-else>
            <el-col :span="6" v-for="p in list" :key="p.id" style="margin-bottom:16px">
              <ProductCard :product="p" @add-cart="addCart" />
            </el-col>
          </el-row>
        </div>

        <el-pagination style="margin-top:16px;justify-content:center;display:flex"
          v-model:current-page="query.page" v-model:page-size="query.size"
          :total="total" :page-sizes="[12, 24, 48]"
          layout="total, sizes, prev, pager, next" @change="loadList" />
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, inject, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { productApi, categoryApi, cartApi } from '@/api'
import { useUserStore } from '@/store/user'
import ProductCard from '@/components/ProductCard.vue'

const refreshCart = inject('refreshCart', () => {})

const route     = useRoute()
const router    = useRouter()
const userStore = useUserStore()

const loading          = ref(false)
const list             = ref([])
const total            = ref(0)
const categoryTree     = ref([])
const activeCategoryId = ref('')

const query = reactive({ page: 1, size: 12, keyword: '', categoryId: null, sort: '', status: 1 })

onMounted(async () => {
  const catRes = await categoryApi.tree()
  categoryTree.value = catRes.data.filter(c => c.parentId === 0)
  if (route.query.categoryId) {
    activeCategoryId.value = String(route.query.categoryId)
    query.categoryId = Number(route.query.categoryId)
  }
  if (route.query.keyword) query.keyword = route.query.keyword
  loadList()
})

watch(() => route.query, q => {
  if (q.categoryId) {
    activeCategoryId.value = String(q.categoryId)
    query.categoryId = Number(q.categoryId)
  } else {
    activeCategoryId.value = ''
    query.categoryId = null
  }
  query.keyword = q.keyword || ''
  query.page = 1
  loadList()
})

function selectCategory(id) {
  activeCategoryId.value = id
  query.categoryId = id ? Number(id) : null
  query.page = 1
  loadList()
}

async function loadList() {
  loading.value = true
  try {
    const params = { ...query }
    // 后端接收 name 参数做模糊搜索
    params.name = params.keyword
    delete params.keyword
    // 排序映射
    if (params.sort === 'price_asc')   { params.orderBy = 'price';       params.orderDir = 'asc' }
    if (params.sort === 'price_desc')  { params.orderBy = 'price';       params.orderDir = 'desc' }
    if (params.sort === 'sales_desc')  { params.orderBy = 'sales_count'; params.orderDir = 'desc' }
    delete params.sort
    const res = await productApi.page(params)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

async function addCart(product) {
  if (!userStore.token) { router.push('/login'); return }
  await cartApi.add({ productId: product.id, quantity: 1 })
  ElMessage.success('已加入购物车')
  refreshCart()
}
</script>

<style scoped>
.products-page { }

.category-menu {
  position: sticky; top: 90px;
  border-radius: var(--radius-lg) !important;
}
.cat-title {
  font-weight: 700; font-size: 16px; padding: 10px 0; margin-bottom: 8px;
  border-bottom: 3px solid var(--primary); color: var(--text-primary);
  display: flex; align-items: center; gap: 6px;
}
.cat-title::before {
  content: ''; width: 4px; height: 16px;
  background: var(--primary-gradient); border-radius: 2px;
}

.category-menu :deep(.el-menu) { border-right: none !important; }
.category-menu :deep(.el-menu-item) {
  border-radius: 6px; margin: 2px 0;
  transition: all 0.2s;
}
.category-menu :deep(.el-menu-item.is-active) {
  background: var(--primary-lighter) !important; color: var(--primary) !important; font-weight: 500;
}

.filter-bar {
  display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
}
.filter-bar :deep(.el-input__wrapper) { border-radius: 20px !important; }
</style>
