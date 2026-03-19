<template>
  <el-container class="admin-layout">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '64px' : '220px'" class="sidebar">
      <div class="sidebar-logo">
        <el-icon size="24" color="#67c23a"><Leaf /></el-icon>
        <span v-show="!isCollapse" class="logo-text">健康优选</span>
      </div>

      <el-menu
        :default-active="$route.path"
        router
        :collapse="isCollapse"
        background-color="#1d2935"
        text-color="#bfcbd9"
        active-text-color="#67c23a"
      >
        <el-menu-item index="/admin/dashboard">
          <el-icon><DataLine /></el-icon>
          <template #title>数据看板</template>
        </el-menu-item>

        <el-menu-item v-if="isAdmin" index="/admin/user">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>

        <el-sub-menu index="goods">
          <template #title>
            <el-icon><Goods /></el-icon>
            <span>商品管理</span>
          </template>
          <el-menu-item index="/admin/category">分类管理</el-menu-item>
          <el-menu-item index="/admin/product">商品列表</el-menu-item>
          <el-menu-item index="/admin/stock">库存管理</el-menu-item>
        </el-sub-menu>

        <el-menu-item index="/admin/order">
          <el-icon><List /></el-icon>
          <template #title>订单管理</template>
        </el-menu-item>

        <el-menu-item index="/admin/statistics">
          <el-icon><TrendCharts /></el-icon>
          <template #title>销售统计</template>
        </el-menu-item>

        <el-menu-item index="/admin/article">
          <el-icon><Document /></el-icon>
          <template #title>科普管理</template>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <!-- 顶部导航 -->
      <el-header class="admin-header">
        <div class="header-left">
          <el-icon class="collapse-btn" @click="isCollapse = !isCollapse">
            <component :is="isCollapse ? 'Expand' : 'Fold'" />
          </el-icon>
          <!-- 面包屑 -->
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/admin/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item>{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <el-tag :type="isAdmin ? 'danger' : 'warning'" size="small" style="margin-right:12px">
            {{ isAdmin ? '管理员' : '商家' }}
          </el-tag>
          <el-dropdown @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="32" icon="UserFilled" />
              <span>{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="home">返回商城</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 内容区 -->
      <el-main class="admin-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/store/user'

const router    = useRouter()
const userStore = useUserStore()
const isCollapse = ref(false)
const isAdmin   = computed(() => userStore.isAdmin)

function handleCommand(cmd) {
  if (cmd === 'home') {
    router.push('/')
  } else if (cmd === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', { type: 'warning' }).then(() => {
      userStore.logout()
      router.push('/login')
    })
  }
}
</script>

<style scoped>
.admin-layout { height: 100vh; }

.sidebar {
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
  transition: width 0.3s;
  overflow: hidden;
}
.sidebar-logo {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
}
.logo-text { color: #fff; font-size: 16px; font-weight: 600; letter-spacing: 0.5px; }

.el-menu { border-right: none !important; }
.el-menu :deep(.el-menu-item) {
  border-radius: 8px;
  margin: 2px 8px;
  transition: all 0.2s;
}
.el-menu :deep(.el-menu-item:hover) { background: rgba(255,255,255,0.08) !important; }
.el-menu :deep(.el-menu-item.is-active) {
  background: linear-gradient(90deg, rgba(46,125,50,0.5) 0%, rgba(46,125,50,0.15) 100%) !important;
  color: #4ade80 !important;
}
.el-menu :deep(.el-sub-menu__title) {
  border-radius: 8px;
  margin: 2px 8px;
}

.admin-header {
  background: var(--bg-card);
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 0 var(--border-light);
  padding: 0 24px;
  height: 64px !important;
}
.header-left { display: flex; align-items: center; gap: 16px; }
.collapse-btn { font-size: 20px; cursor: pointer; color: var(--text-secondary); transition: color 0.2s; }
.collapse-btn:hover { color: var(--primary); }
.header-right { display: flex; align-items: center; }
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 14px;
  color: var(--text-primary);
  padding: 6px 12px;
  border-radius: 8px;
  transition: background 0.2s;
}
.user-info:hover { background: #f1f5f9; }

.admin-main {
  background: var(--bg-page);
  overflow-y: auto;
  padding: 24px;
}
</style>
