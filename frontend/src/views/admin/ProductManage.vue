<template>
  <el-card>
    <!-- 搜索栏 -->
    <el-form :model="query" inline class="search-form">
      <el-form-item label="商品名称">
        <el-input v-model="query.name" placeholder="搜索商品名称" clearable style="width:200px" />
      </el-form-item>
      <el-form-item label="分类">
        <el-cascader v-model="query.categoryId" :options="categoryTree" :props="{ checkStrictly: true, value: 'id', label: 'name', children: 'children' }"
          clearable placeholder="选择分类" style="width:200px" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable placeholder="上架状态" style="width:120px">
          <el-option label="上架" :value="1" />
          <el-option label="下架" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadList">搜索</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
      <el-form-item style="float:right">
        <el-button type="success" icon="Plus" @click="openDialog()">新增商品</el-button>
      </el-form-item>
    </el-form>

    <!-- 表格 -->
    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column label="ID" prop="id" width="70" />
      <el-table-column label="图片" width="80">
        <template #default="{ row }">
          <el-image :src="row.imageUrl" style="width:50px;height:50px;border-radius:4px" fit="cover">
            <template #error><el-icon><Picture /></el-icon></template>
          </el-image>
        </template>
      </el-table-column>
      <el-table-column label="商品名称" prop="name" min-width="160" show-overflow-tooltip />
      <el-table-column label="分类" prop="categoryName" width="100" />
      <el-table-column label="价格" width="100">
        <template #default="{ row }">
          <span style="color:#f56c6c;font-weight:600">¥{{ row.price }}</span>
        </template>
      </el-table-column>
      <el-table-column label="库存" prop="stock" width="80">
        <template #default="{ row }">
          <el-tag :type="row.stock <= row.stockWarning ? 'danger' : 'success'" size="small">
            {{ row.stock }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="销量" prop="salesCount" width="80" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-switch v-model="row.status" :active-value="1" :inactive-value="0"
            @change="toggleStatus(row)" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button type="warning" link size="small" @click="openStockAdjust(row)">调库存</el-button>
          <el-button type="danger"  link size="small" @click="deleteProduct(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
      v-model:current-page="query.page" v-model:page-size="query.size"
      :total="total" :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next"
      @change="loadList" />
  </el-card>

  <!-- 新增/编辑对话框 -->
  <el-dialog v-model="dialogVisible" :title="editForm.id ? '编辑商品' : '新增商品'" width="700px" destroy-on-close>
    <el-form ref="editFormRef" :model="editForm" :rules="editRules" label-width="90px">
      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="商品名称" prop="name">
            <el-input v-model="editForm.name" placeholder="请输入商品名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="所属分类" prop="categoryId">
            <el-cascader v-model="editForm.categoryId" :options="categoryTree"
              :props="{ checkStrictly: true, value: 'id', label: 'name', children: 'children' }"
              style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="销售价格" prop="price">
            <el-input-number v-model="editForm.price" :precision="2" :min="0.01" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="原价">
            <el-input-number v-model="editForm.originalPrice" :precision="2" :min="0" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="库存数量" prop="stock">
            <el-input-number v-model="editForm.stock" :min="0" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="预警库存">
            <el-input-number v-model="editForm.stockWarning" :min="0" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="商品图片">
            <div class="image-upload-area">
              <el-upload
                class="product-uploader"
                action="/api/file/upload"
                :headers="uploadHeaders"
                :show-file-list="false"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                :before-upload="beforeUpload"
                accept=".jpg,.jpeg,.png,.gif,.webp"
              >
                <el-image v-if="editForm.imageUrl" :src="editForm.imageUrl" fit="cover" class="upload-preview" />
                <el-icon v-else class="upload-icon"><Plus /></el-icon>
              </el-upload>
              <el-input v-model="editForm.imageUrl" placeholder="或直接输入图片URL" style="margin-top:8px" clearable />
            </div>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="商品描述">
            <el-input v-model="editForm.description" type="textarea" :rows="4" placeholder="商品描述" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="submitLoading" @click="submitProduct">确定</el-button>
    </template>
  </el-dialog>

  <!-- 调整库存对话框 -->
  <el-dialog v-model="stockDialogVisible" title="调整库存" width="400px">
    <el-form label-width="80px">
      <el-form-item label="当前库存"><el-tag>{{ currentProduct.stock }}</el-tag></el-form-item>
      <el-form-item label="调整类型">
        <el-radio-group v-model="stockForm.type">
          <el-radio :value="1">入库（增加）</el-radio>
          <el-radio :value="3">手动调整</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="调整数量">
        <el-input-number v-model="stockForm.changeQuantity" :min="1" style="width:100%" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="stockForm.remark" placeholder="可选备注" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="stockDialogVisible = false">取消</el-button>
      <el-button type="primary" @click="submitStockAdjust">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { productApi, categoryApi } from '@/api'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const uploadHeaders = computed(() => ({ Authorization: `Bearer ${userStore.token}` }))

const loading = ref(false)
const list    = ref([])
const total   = ref(0)
const query   = reactive({ page: 1, size: 10, name: '', categoryId: null, status: null })

const categoryTree = ref([])
const dialogVisible  = ref(false)
const submitLoading  = ref(false)
const editFormRef    = ref()
const editForm       = reactive({ id: null, name: '', categoryId: null, price: null, originalPrice: null, stock: 0, stockWarning: 10, imageUrl: '', description: '' })
const editRules      = {
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  stock: [{ required: true, message: '请输入库存', trigger: 'blur' }]
}

const stockDialogVisible = ref(false)
const currentProduct     = ref({})
const stockForm          = reactive({ productId: null, type: 1, changeQuantity: 1, remark: '' })

onMounted(() => {
  loadList()
  loadCategories()
})

async function loadList() {
  loading.value = true
  try {
    // 级联选择器返回数组，取最后一级的ID发给后端
    const params = { ...query }
    if (Array.isArray(params.categoryId)) {
      params.categoryId = params.categoryId[params.categoryId.length - 1]
    }
    const res = await productApi.page(params)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  const res = await categoryApi.tree()
  categoryTree.value = res.data
}

function resetQuery() {
  Object.assign(query, { page: 1, name: '', categoryId: null, status: null })
  loadList()
}

function openDialog(row = null) {
  Object.assign(editForm, { id: null, name: '', categoryId: null, price: null, originalPrice: null, stock: 0, stockWarning: 10, imageUrl: '', description: '' })
  if (row) {
    Object.assign(editForm, row)
    // 级联选择器需要数组路径 [parentId, childId]，将单个 categoryId 转换
    if (row.categoryId && !Array.isArray(row.categoryId)) {
      editForm.categoryId = buildCascaderPath(row.categoryId)
    }
  }
  dialogVisible.value = true
}

/** 根据分类ID，在分类树中查找完整路径 [parentId, childId] */
function buildCascaderPath(catId) {
  for (const parent of categoryTree.value) {
    if (parent.id === catId) return [catId]
    if (parent.children) {
      for (const child of parent.children) {
        if (child.id === catId) return [parent.id, catId]
      }
    }
  }
  return [catId]  // fallback
}

async function submitProduct() {
  try { await editFormRef.value.validate() } catch { return }
  submitLoading.value = true
  try {
    const data = { ...editForm }
    // 级联选择器返回数组，取最后一级的ID
    if (Array.isArray(data.categoryId)) {
      data.categoryId = data.categoryId[data.categoryId.length - 1]
    }
    if (data.id) {
      await productApi.update(data)
    } else {
      await productApi.add(data)
    }
    ElMessage.success(data.id ? '修改成功' : '添加成功')
    dialogVisible.value = false
    loadList()
  } finally {
    submitLoading.value = false
  }
}

async function toggleStatus(row) {
  await productApi.updateStatus(row.id, row.status)
  ElMessage.success(row.status === 1 ? '已上架' : '已下架')
}

async function deleteProduct(row) {
  await ElMessageBox.confirm(`确定删除商品"${row.name}"？`, '警告', { type: 'warning' })
  await productApi.delete(row.id)
  ElMessage.success('删除成功')
  loadList()
}

function openStockAdjust(row) {
  currentProduct.value = row
  Object.assign(stockForm, { productId: row.id, type: 1, changeQuantity: 1, remark: '' })
  stockDialogVisible.value = true
}

async function submitStockAdjust() {
  await productApi.adjustStock(stockForm)
  ElMessage.success('库存调整成功')
  stockDialogVisible.value = false
  loadList()
}

// ──── 图片上传 ────
function beforeUpload(file) {
  const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)
  const isLt5M = file.size / 1024 / 1024 < 5
  if (!isImage) ElMessage.error('仅支持 jpg/png/gif/webp 格式图片')
  if (!isLt5M) ElMessage.error('图片大小不能超过5MB')
  return isImage && isLt5M
}
function handleUploadSuccess(res) {
  if (res.code === 200) {
    editForm.imageUrl = res.data.url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(res.message || '上传失败')
  }
}
function handleUploadError() {
  ElMessage.error('上传失败，请重试')
}
</script>

<style scoped>
.search-form { margin-bottom: 4px; }
.image-upload-area { width: 100%; }
.product-uploader :deep(.el-upload) {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.3s;
}
.product-uploader :deep(.el-upload:hover) { border-color: #67c23a; }
.upload-preview { width: 120px; height: 120px; border-radius: 6px; }
.upload-icon { font-size: 28px; color: #8c939d; }
</style>
