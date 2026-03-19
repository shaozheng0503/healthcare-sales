<template>
  <div>
    <h2 class="page-title">健康科普</h2>
    <el-row :gutter="24">
      <!-- 文章列表 -->
      <el-col :span="18">
        <el-row :gutter="20" v-loading="loading">
          <el-col :span="8" v-for="a in list" :key="a.id" style="margin-bottom:24px">
            <div class="article-card hover-lift" @click="$router.push(`/article/${a.id}`)">
              <div class="article-cover">
                <el-image :src="a.coverImage" style="width:100%;height:160px" fit="cover">
                  <template #error>
                    <div class="cover-fallback">
                      <el-icon size="36" color="#cbd5e1"><Document /></el-icon>
                    </div>
                  </template>
                </el-image>
              </div>
              <div class="article-body">
                <div class="article-title">{{ a.title }}</div>
                <div class="article-summary">{{ a.summary }}</div>
                <div class="article-meta">
                  <span><el-icon><View /></el-icon> {{ a.viewCount }}</span>
                  <span>{{ a.createdAt?.slice(0, 10) }}</span>
                </div>
              </div>
            </div>
          </el-col>
        </el-row>

        <div v-if="!loading && list.length === 0" class="empty-state">
          <el-icon size="56" color="#cbd5e1"><Document /></el-icon>
          <p>暂无科普文章</p>
        </div>

        <el-pagination style="margin-top:8px;justify-content:center;display:flex"
          v-model:current-page="query.page" v-model:page-size="query.size"
          :total="total" layout="prev, pager, next" @change="loadList" />
      </el-col>

      <!-- 热门推荐 -->
      <el-col :span="6">
        <div class="hot-panel">
          <div class="hot-header">
            <el-icon color="var(--accent)"><TrendCharts /></el-icon>
            热门科普
          </div>
          <div v-for="(a, i) in hotArticles" :key="a.id" class="hot-item"
            @click="$router.push(`/article/${a.id}`)">
            <span class="hot-rank" :class="{ top: i < 3 }">{{ i + 1 }}</span>
            <div class="hot-info">
              <span class="hot-title">{{ a.title }}</span>
              <span class="hot-views"><el-icon><View /></el-icon> {{ a.viewCount }}</span>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { articleApi } from '@/api'

const loading     = ref(false)
const list        = ref([])
const total       = ref(0)
const hotArticles = ref([])
const query       = reactive({ page: 1, size: 9, status: 1 })

onMounted(async () => {
  loadList()
  const res = await articleApi.page({ page: 1, size: 5, status: 1, orderBy: 'view_count' })
  hotArticles.value = res.data.records
})

async function loadList() {
  loading.value = true
  try {
    const res = await articleApi.page(query)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.page-title { font-size: 22px; font-weight: 700; margin-bottom: 24px; color: var(--text-primary); }

.article-card {
  background: var(--bg-card); border-radius: var(--radius-md);
  overflow: hidden; cursor: pointer;
}
.article-cover { overflow: hidden; }
.article-cover :deep(.el-image) { transition: transform 0.4s; }
.article-card:hover .article-cover :deep(.el-image) { transform: scale(1.05); }
.cover-fallback {
  height: 160px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
  display: flex; align-items: center; justify-content: center;
}

.article-body { padding: 16px; }
.article-title {
  font-weight: 600; font-size: 15px; color: var(--text-primary);
  line-height: 1.5; margin-bottom: 8px;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.article-summary {
  font-size: 13px; color: var(--text-muted); line-height: 1.6;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.article-meta {
  margin-top: 12px; display: flex; gap: 16px;
  font-size: 12px; color: var(--text-muted);
}
.article-meta span { display: flex; align-items: center; gap: 3px; }

.empty-state { text-align: center; padding: 60px 0; color: var(--text-muted); }
.empty-state p { margin-top: 12px; }

/* 热门面板 */
.hot-panel {
  background: var(--bg-card); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm); padding: 20px;
  position: sticky; top: 100px;
}
.hot-header {
  display: flex; align-items: center; gap: 8px;
  font-size: 16px; font-weight: 700; color: var(--text-primary);
  padding-bottom: 14px; margin-bottom: 4px;
  border-bottom: 2px solid var(--border-light);
}
.hot-item {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 12px 0; border-bottom: 1px solid #f1f5f9;
  cursor: pointer; transition: background 0.15s;
}
.hot-item:last-child { border-bottom: none; }
.hot-item:hover { background: #fafafa; margin: 0 -8px; padding-left: 8px; padding-right: 8px; border-radius: 6px; }

.hot-rank {
  flex-shrink: 0; width: 22px; height: 22px;
  border-radius: 6px; background: #f1f5f9;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700; color: var(--text-muted);
}
.hot-rank.top { background: var(--accent-gradient); color: #fff; }

.hot-info { flex: 1; min-width: 0; }
.hot-title {
  font-size: 13px; color: var(--text-primary); line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.hot-item:hover .hot-title { color: var(--primary); }
.hot-views { font-size: 12px; color: var(--text-muted); display: flex; align-items: center; gap: 2px; margin-top: 4px; }
</style>
