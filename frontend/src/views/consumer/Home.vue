<template>
  <div class="home">
    <!-- Banner 轮播 -->
    <el-carousel height="360px" class="banner">
      <el-carousel-item v-for="b in banners" :key="b.id">
        <div class="banner-item" :style="{ background: b.color }">
          <div class="banner-text">
            <h2>{{ b.title }}</h2>
            <p>{{ b.desc }}</p>
            <el-button type="primary" size="large" @click="$router.push('/products')">立即选购</el-button>
          </div>
        </div>
      </el-carousel-item>
    </el-carousel>

    <!-- 分类导航 -->
    <el-card class="section-card">
      <template #header><span class="section-title">商品分类</span></template>
      <el-row :gutter="16">
        <el-col :span="4" v-for="cat in topCategories" :key="cat.id">
          <div class="category-item" @click="$router.push(`/products?categoryId=${cat.id}`)">
            <el-icon :size="40" color="#67c23a"><Leaf /></el-icon>
            <p>{{ cat.name }}</p>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- 热销商品 -->
    <el-card class="section-card">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span class="section-title">热销商品</span>
          <el-link type="primary" @click="$router.push('/products')">查看全部 ›</el-link>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col :span="4" v-for="p in hotProducts" :key="p.id">
          <ProductCard :product="p" @add-cart="addCart" />
        </el-col>
      </el-row>
    </el-card>

    <!-- 最新科普 -->
    <el-card class="section-card">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span class="section-title">健康科普</span>
          <el-link type="primary" @click="$router.push('/articles')">查看全部 ›</el-link>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col :span="8" v-for="a in articles" :key="a.id">
          <el-card class="article-card" shadow="hover" @click="$router.push(`/article/${a.id}`)">
            <el-image :src="a.coverImage" style="width:100%;height:160px" fit="cover">
              <template #error>
                <div style="height:160px;background:#f5f7fa;display:flex;align-items:center;justify-content:center">
                  <el-icon size="40" color="#c0c4cc"><Picture /></el-icon>
                </div>
              </template>
            </el-image>
            <div style="padding:12px">
              <div style="font-weight:600;margin-bottom:6px" class="ellipsis2">{{ a.title }}</div>
              <div style="color:#909399;font-size:13px" class="ellipsis2">{{ a.summary }}</div>
              <div style="color:#c0c4cc;font-size:12px;margin-top:8px">
                <el-icon><View /></el-icon> {{ a.viewCount }}
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, inject, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { productApi, categoryApi, articleApi, cartApi } from '@/api'
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import ProductCard from '@/components/ProductCard.vue'

const refreshCart = inject('refreshCart', () => {})

const router    = useRouter()
const userStore = useUserStore()

const topCategories = ref([])
const hotProducts   = ref([])
const articles      = ref([])

const banners = [
  { id: 1, title: '精选保健好物', desc: '为家人的健康，用心挑选每一款产品', color: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 50%, #bbf7d0 100%)' },
  { id: 2, title: '中药养生系列', desc: '传统中医智慧，守护现代健康生活',    color: 'linear-gradient(135deg, #fffbeb 0%, #fef3c7 50%, #fde68a 100%)' },
  { id: 3, title: '健康科普知识', desc: '权威健康资讯，助力科学保健',         color: 'linear-gradient(135deg, #eff6ff 0%, #dbeafe 50%, #bfdbfe 100%)' }
]

onMounted(async () => {
  const [catRes, prodRes, artRes] = await Promise.allSettled([
    categoryApi.tree(),
    productApi.page({ page: 1, size: 6, status: 1 }),
    articleApi.page({ page: 1, size: 3, status: 1 })
  ])
  if (catRes.status === 'fulfilled')  topCategories.value = catRes.value.data.filter(c => c.parentId === 0)
  if (prodRes.status === 'fulfilled') hotProducts.value   = prodRes.value.data.records
  if (artRes.status === 'fulfilled')  articles.value      = artRes.value.data.records
})

async function addCart(product) {
  if (!userStore.token) { router.push('/login'); return }
  await cartApi.add({ productId: product.id, quantity: 1 })
  ElMessage.success('已加入购物车')
  refreshCart()
}
</script>

<style scoped>
.home { display: flex; flex-direction: column; gap: 28px; }

.banner { border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-md); }
.banner-item {
  height: 100%;
  display: flex;
  align-items: center;
  padding: 60px 80px;
  position: relative;
}
.banner-text h2 {
  font-size: 36px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 12px;
  letter-spacing: -0.5px;
}
.banner-text p {
  color: var(--text-secondary);
  font-size: 16px;
  margin-bottom: 28px;
  line-height: 1.6;
}

.section-card { border-radius: var(--radius-lg) !important; }
.section-title {
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}
.section-title::before {
  content: '';
  width: 4px;
  height: 20px;
  background: var(--primary-gradient);
  border-radius: 2px;
}

.category-item {
  text-align: center;
  padding: 20px 8px;
  cursor: pointer;
  border-radius: var(--radius-md);
  transition: all 0.25s;
  border: 1px solid transparent;
}
.category-item:hover {
  background: var(--primary-lighter);
  border-color: rgba(46,125,50,0.15);
  transform: translateY(-3px);
  box-shadow: var(--shadow-sm);
}
.category-item p { margin-top: 10px; font-size: 13px; color: var(--text-primary); font-weight: 500; }

.article-card {
  cursor: pointer;
  border-radius: var(--radius-md) !important;
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
}
.article-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover) !important;
}

.ellipsis2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
</style>
