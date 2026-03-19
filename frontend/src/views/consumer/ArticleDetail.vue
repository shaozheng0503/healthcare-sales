<template>
  <div v-loading="loading" class="article-detail">
    <div v-if="article" class="article-container">
      <!-- 文章头部 -->
      <div class="article-header">
        <h1>{{ article.title }}</h1>
        <div class="article-meta">
          <span><el-icon><Calendar /></el-icon> {{ article.createdAt?.slice(0, 10) }}</span>
          <span><el-icon><View /></el-icon> {{ article.viewCount }} 次阅读</span>
        </div>
      </div>

      <el-divider />

      <!-- 正文 -->
      <div class="article-content">{{ article.content }}</div>

      <!-- 底部导航 -->
      <div class="article-footer">
        <el-button round icon="ArrowLeft" @click="$router.push('/articles')">返回列表</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { articleApi } from '@/api'

const route   = useRoute()
const loading = ref(false)
const article = ref(null)

onMounted(async () => {
  loading.value = true
  try {
    const res = await articleApi.detail(route.params.id)
    article.value = res.data
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.article-detail { max-width: 800px; margin: 0 auto; }

.article-container {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 48px;
}

.article-header h1 {
  font-size: 28px; font-weight: 700; color: var(--text-primary);
  line-height: 1.4; margin-bottom: 16px;
}
.article-meta {
  display: flex; gap: 24px;
  font-size: 14px; color: var(--text-muted);
}
.article-meta span { display: flex; align-items: center; gap: 4px; }

.article-content {
  line-height: 2; color: var(--text-primary);
  white-space: pre-wrap; font-size: 15px;
  letter-spacing: 0.3px;
}

.article-footer {
  margin-top: 40px; padding-top: 24px;
  border-top: 1px solid var(--border-light);
}
</style>
