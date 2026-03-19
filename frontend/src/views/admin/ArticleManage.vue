<template>
  <el-card>
    <el-form :model="query" inline>
      <el-form-item label="标题">
        <el-input v-model="query.title" placeholder="搜索标题" clearable style="width:200px" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable style="width:120px">
          <el-option label="草稿"   :value="0" />
          <el-option label="已发布" :value="1" />
          <el-option label="已下架" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadList">搜索</el-button>
        <el-button @click="query.title='';query.status=null;loadList()">重置</el-button>
      </el-form-item>
      <el-form-item style="float:right">
        <el-button type="success" icon="Plus" @click="openDialog()">写文章</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column label="封面" width="90">
        <template #default="{ row }">
          <el-image :src="row.coverImage" style="width:60px;height:40px;border-radius:4px" fit="cover">
            <template #error><el-icon><Picture /></el-icon></template>
          </el-image>
        </template>
      </el-table-column>
      <el-table-column label="标题" prop="title" min-width="200" show-overflow-tooltip />
      <el-table-column label="摘要" prop="summary" min-width="200" show-overflow-tooltip />
      <el-table-column label="浏览量" prop="viewCount" width="90" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="statusMap[row.status]?.type" size="small">{{ statusMap[row.status]?.label }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" prop="createdAt" width="160" />
      <el-table-column label="操作" width="180">
        <template #default="{ row }">
          <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
          <el-button v-if="row.status !== 1" type="success" link @click="publish(row)">发布</el-button>
          <el-button type="danger"  link @click="deleteArticle(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
      v-model:current-page="query.page" v-model:page-size="query.size"
      :total="total" layout="total, sizes, prev, pager, next" @change="loadList" />
  </el-card>

  <!-- 文章编辑对话框 -->
  <el-dialog v-model="dialogVisible" :title="editForm.id ? '编辑文章' : '新增文章'" width="800px" destroy-on-close>
    <el-form ref="formRef" :model="editForm" :rules="rules" label-width="80px">
      <el-form-item label="文章标题" prop="title">
        <el-input v-model="editForm.title" placeholder="请输入文章标题" />
      </el-form-item>
      <el-form-item label="封面图片">
        <div class="image-upload-area">
          <el-upload
            class="cover-uploader"
            action="/api/file/upload"
            :headers="uploadHeaders"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
            accept=".jpg,.jpeg,.png,.gif,.webp"
          >
            <el-image v-if="editForm.coverImage" :src="editForm.coverImage" fit="cover" class="upload-preview" />
            <el-icon v-else class="upload-icon"><Plus /></el-icon>
          </el-upload>
          <el-input v-model="editForm.coverImage" placeholder="或直接输入封面图URL" style="margin-top:8px" clearable />
        </div>
      </el-form-item>
      <el-form-item label="文章摘要">
        <el-input v-model="editForm.summary" type="textarea" :rows="2" placeholder="简短描述，显示在列表页" />
      </el-form-item>
      <el-form-item label="文章内容" prop="content">
        <el-input v-model="editForm.content" type="textarea" :rows="12" placeholder="文章正文内容" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button @click="submit(0)">保存草稿</el-button>
      <el-button type="primary" @click="submit(1)">发布文章</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { articleApi } from '@/api'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const uploadHeaders = computed(() => ({ Authorization: `Bearer ${userStore.token}` }))

const loading       = ref(false)
const list          = ref([])
const total         = ref(0)
const query         = reactive({ page: 1, size: 10, title: '', status: null })
const dialogVisible = ref(false)
const formRef       = ref()
const editForm      = reactive({ id: null, title: '', coverImage: '', summary: '', content: '' })
const rules         = {
  title:   [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入内容', trigger: 'blur' }]
}
const statusMap = {
  0: { label: '草稿',   type: 'info' },
  1: { label: '已发布', type: 'success' },
  2: { label: '已下架', type: 'danger' }
}

onMounted(loadList)

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

function openDialog(row = null) {
  Object.assign(editForm, { id: null, title: '', coverImage: '', summary: '', content: '' })
  if (row) Object.assign(editForm, row)
  dialogVisible.value = true
}

async function submit(status) {
  try { await formRef.value.validate() } catch { return }
  const data = { ...editForm, status }
  if (editForm.id) {
    await articleApi.update(data)
  } else {
    await articleApi.add(data)
  }
  ElMessage.success(status === 1 ? '发布成功' : '保存成功')
  dialogVisible.value = false
  loadList()
}

async function publish(row) {
  await articleApi.publish(row.id)
  ElMessage.success('发布成功')
  loadList()
}

async function deleteArticle(row) {
  await ElMessageBox.confirm(`确定删除文章"${row.title}"？`, '警告', { type: 'warning' })
  await articleApi.delete(row.id)
  ElMessage.success('删除成功')
  loadList()
}

// ──── 封面图上传 ────
function beforeUpload(file) {
  const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)
  const isLt5M = file.size / 1024 / 1024 < 5
  if (!isImage) ElMessage.error('仅支持 jpg/png/gif/webp 格式')
  if (!isLt5M) ElMessage.error('图片大小不能超过5MB')
  return isImage && isLt5M
}
function handleUploadSuccess(res) {
  if (res.code === 200) {
    editForm.coverImage = res.data.url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(res.message || '上传失败')
  }
}
</script>

<style scoped>
.image-upload-area { width: 100%; }
.cover-uploader :deep(.el-upload) {
  border: 1px dashed #d9d9d9; border-radius: 6px; cursor: pointer;
  width: 160px; height: 100px; display: flex; align-items: center; justify-content: center;
  transition: border-color 0.3s;
}
.cover-uploader :deep(.el-upload:hover) { border-color: #67c23a; }
.upload-preview { width: 160px; height: 100px; border-radius: 6px; }
.upload-icon { font-size: 28px; color: #8c939d; }
</style>
