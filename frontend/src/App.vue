<template>
  <router-view v-slot="{ Component, route }">
    <transition :name="route.meta.transition || 'fade'" mode="out-in">
      <component :is="Component" :key="route.path" />
    </transition>
  </router-view>
</template>

<script setup>
</script>

<style>
/* ═══════════════ 设计变量 ═══════════════ */
:root {
  --primary: #2e7d32;
  --primary-light: #4caf50;
  --primary-lighter: #e8f5e9;
  --primary-gradient: linear-gradient(135deg, #43a047 0%, #2e7d32 100%);
  --accent: #ff7043;
  --accent-gradient: linear-gradient(135deg, #ff8a65 0%, #ff5722 100%);
  --bg-page: #f0f2f5;
  --bg-card: #ffffff;
  --text-primary: #1a1a2e;
  --text-secondary: #64748b;
  --text-muted: #94a3b8;
  --border-light: #e2e8f0;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
  --shadow-lg: 0 12px 40px rgba(0,0,0,0.12);
  --shadow-hover: 0 8px 30px rgba(46,125,50,0.15);
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 24px;
}

/* ═══════════════ 基础重置 ═══════════════ */
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', 'Segoe UI', sans-serif;
  background: var(--bg-page);
  color: var(--text-primary);
  -webkit-font-smoothing: antialiased;
}

/* ═══════════════ Element Plus 覆写 ═══════════════ */
.el-button--primary {
  background: var(--primary-gradient) !important;
  border: none !important;
  font-weight: 500;
}
.el-button--primary:hover {
  opacity: 0.9;
  box-shadow: 0 4px 14px rgba(46,125,50,0.35);
}
.el-card {
  border: none !important;
  border-radius: var(--radius-md) !important;
  box-shadow: var(--shadow-sm) !important;
  transition: box-shadow 0.3s, transform 0.3s;
}
.el-tag { border-radius: 6px !important; font-weight: 500; }
.el-input__wrapper, .el-select__wrapper {
  border-radius: var(--radius-sm) !important;
}

/* ═══════════════ 滚动条 ═══════════════ */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

/* ═══════════════ 路由过渡动画 ═══════════════ */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.25s ease;
}
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-up-enter-active, .slide-up-leave-active {
  transition: all 0.3s ease;
}
.slide-up-enter-from { opacity: 0; transform: translateY(20px); }
.slide-up-leave-to   { opacity: 0; transform: translateY(-10px); }

/* ═══════════════ 通用工具类 ═══════════════ */
.glass-card {
  background: rgba(255,255,255,0.85);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.5);
}
.gradient-text {
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.hover-lift { transition: transform 0.3s, box-shadow 0.3s; }
.hover-lift:hover { transform: translateY(-4px); box-shadow: var(--shadow-hover) !important; }
</style>
