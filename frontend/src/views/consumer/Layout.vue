<template>
  <el-container class="consumer-layout">
    <!-- 顶部导航 -->
    <el-header class="top-header">
      <div class="header-inner">
        <!-- Logo -->
        <div class="logo" @click="$router.push('/')">
          <el-icon size="28" color="#67c23a"><Leaf /></el-icon>
          <span>健康优选</span>
        </div>

        <!-- 搜索栏 -->
        <div class="search-bar">
          <el-input v-model="searchKw" placeholder="搜索保健商品..." size="large"
            @keyup.enter="doSearch">
            <template #append>
              <el-button icon="Search" @click="doSearch" />
            </template>
          </el-input>
        </div>

        <!-- 右侧操作 -->
        <div class="header-actions">
          <!-- 购物车 -->
          <el-badge :value="cartCount || ''" :hidden="!cartCount" type="danger">
            <el-button link icon="ShoppingCart" size="large" @click="$router.push('/cart')">
              购物车
            </el-button>
          </el-badge>

          <!-- 用户 -->
          <template v-if="userStore.token">
            <el-dropdown @command="handleUserCmd">
              <el-button link size="large">
                <el-avatar :size="28" icon="UserFilled" style="margin-right:4px" />
                {{ userStore.userInfo?.realName || userStore.userInfo?.username }}
                <el-icon><ArrowDown /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="orders">我的订单</el-dropdown-item>
                  <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                  <el-dropdown-item v-if="userStore.isBackend" command="admin">进入后台</el-dropdown-item>
                  <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <template v-else>
            <el-button type="primary" @click="$router.push('/login')">登录</el-button>
            <el-button @click="$router.push('/register')">注册</el-button>
          </template>
        </div>
      </div>

      <!-- 导航菜单 -->
      <div class="nav-menu">
        <div class="nav-inner">
          <el-menu mode="horizontal" :default-active="$route.path" router :ellipsis="false"
            background-color="transparent" text-color="rgba(255,255,255,0.9)" active-text-color="#fff">
            <el-menu-item index="/">首页</el-menu-item>
            <el-menu-item index="/products">全部商品</el-menu-item>
            <el-sub-menu v-for="cat in topCategories" :key="cat.id" :index="`/products?categoryId=${cat.id}`">
              <template #title>{{ cat.name }}</template>
              <el-menu-item v-for="sub in cat.children" :key="sub.id"
                :index="`/products?categoryId=${sub.id}`">{{ sub.name }}</el-menu-item>
            </el-sub-menu>
            <el-menu-item index="/articles">健康科普</el-menu-item>
          </el-menu>
        </div>
      </div>
    </el-header>

    <!-- 内容区 -->
    <el-main class="consumer-main">
      <router-view />
    </el-main>

    <!-- 底部 -->
    <el-footer class="consumer-footer" height="80px">
      <p>© 2026 健康优选 日常保健用品销售管理系统</p>
      <p style="color:#ccc;font-size:12px">提供安全可靠的保健用品，呵护您的健康生活</p>
    </el-footer>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, watch, provide } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/store/user'
import { categoryApi, cartApi } from '@/api'

const router    = useRouter()
const route     = useRoute()
const userStore = useUserStore()

const searchKw      = ref('')
const topCategories = ref([])
const cartCount     = ref(0)

// 提供刷新购物车的方法，子组件可以调用
provide('refreshCart', refreshCart)

onMounted(async () => {
  try {
    const res = await categoryApi.tree()
    topCategories.value = res.data.filter(c => c.parentId === 0)
  } catch {}
  if (userStore.token) refreshCart()
})

// 路由切换时刷新购物车计数（加购后跳转页面时自动更新）
watch(() => route.path, () => {
  if (userStore.token) refreshCart()
})

async function refreshCart() {
  try {
    const res = await cartApi.list()
    cartCount.value = res.data?.length || 0
  } catch {}
}

function doSearch() {
  if (searchKw.value.trim()) {
    router.push({ path: '/products', query: { keyword: searchKw.value } })
  }
}

function handleUserCmd(cmd) {
  if (cmd === 'orders')  router.push('/orders')
  if (cmd === 'profile') router.push('/profile')
  if (cmd === 'admin')   router.push('/admin/dashboard')
  if (cmd === 'logout') {
    ElMessageBox.confirm('确定退出登录？', '提示').then(() => {
      userStore.logout()
      router.push('/')
    })
  }
}
</script>

<style scoped>
.consumer-layout { min-height: 100vh; display: flex; flex-direction: column; background: var(--bg-page); }

.top-header {
  background: var(--bg-card);
  height: auto !important;
  padding: 0;
  box-shadow: 0 1px 0 var(--border-light);
  position: sticky;
  top: 0;
  z-index: 100;
}
.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  height: 68px;
  display: flex;
  align-items: center;
  gap: 28px;
  padding: 0 20px;
}
.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  font-size: 20px;
  font-weight: 700;
  color: var(--primary);
  white-space: nowrap;
  letter-spacing: -0.3px;
}
.search-bar { flex: 1; max-width: 480px; }
.search-bar :deep(.el-input__wrapper) {
  border-radius: 22px !important;
  background: #f1f5f9;
  box-shadow: none !important;
  padding-left: 16px;
}
.search-bar :deep(.el-input__wrapper:focus-within) {
  background: #fff;
  box-shadow: 0 0 0 2px rgba(46,125,50,0.2) !important;
}
.search-bar :deep(.el-input-group__append) {
  border-radius: 0 22px 22px 0 !important;
  background: var(--primary-gradient);
  border: none;
  color: #fff;
  box-shadow: none;
}
.header-actions { display: flex; align-items: center; gap: 12px; white-space: nowrap; }

.nav-menu {
  background: var(--primary-gradient);
}
.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}
.nav-menu .el-menu { border-bottom: none !important; }
.nav-menu .el-menu--horizontal > .el-menu-item {
  border-bottom: none !important;
  border-radius: 6px;
  margin: 4px 2px;
  transition: background 0.2s;
}
.nav-menu .el-menu--horizontal > .el-menu-item:hover,
.nav-menu .el-menu--horizontal > .el-menu-item.is-active {
  background: rgba(255,255,255,0.18) !important;
}

.consumer-main {
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 28px 20px;
  flex: 1;
}

.consumer-footer {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  color: #94a3b8;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-size: 13px;
}
</style>
