<template>
  <el-card>
    <div style="margin-bottom:16px">
      <el-button type="success" icon="Plus" @click="openDialog()">新增分类</el-button>
    </div>

    <el-table :data="categoryTree" v-loading="loading" border row-key="id" default-expand-all
      :tree-props="{ children: 'children', hasChildren: 'hasChildren' }">
      <el-table-column label="分类名称" prop="name" min-width="160" />
      <el-table-column label="排序" prop="sort" width="80" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="toggleStatus(row)" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="{ row }">
          <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
          <el-button v-if="row.parentId === 0" type="success" link @click="openDialog(null, row.id)">添加子分类</el-button>
          <el-button type="danger"  link @click="deleteCategory(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <el-dialog v-model="dialogVisible" :title="editForm.id ? '编辑分类' : '新增分类'" width="400px">
    <el-form ref="formRef" :model="editForm" :rules="rules" label-width="80px">
      <el-form-item label="上级分类">
        <el-select v-model="editForm.parentId" style="width:100%">
          <el-option label="顶级分类" :value="0" />
          <el-option v-for="c in topCategories" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="分类名称" prop="name">
        <el-input v-model="editForm.name" placeholder="请输入分类名称" />
      </el-form-item>
      <el-form-item label="排序值">
        <el-input-number v-model="editForm.sort" :min="0" :max="999" style="width:100%" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" @click="submit">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { categoryApi } from '@/api'

const loading      = ref(false)
const categoryTree = ref([])
const dialogVisible = ref(false)
const formRef       = ref()
const editForm      = reactive({ id: null, name: '', parentId: 0, sort: 0 })
const rules         = { name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }] }

const topCategories = computed(() => categoryTree.value.filter(c => c.parentId === 0))

onMounted(loadData)

async function loadData() {
  loading.value = true
  try {
    const res = await categoryApi.tree()
    categoryTree.value = res.data
  } finally {
    loading.value = false
  }
}

function openDialog(row = null, parentId = 0) {
  Object.assign(editForm, { id: null, name: '', parentId, sort: 0 })
  if (row) Object.assign(editForm, row)
  dialogVisible.value = true
}

async function submit() {
  try { await formRef.value.validate() } catch { return }
  if (editForm.id) {
    await categoryApi.update(editForm)
  } else {
    await categoryApi.add(editForm)
  }
  ElMessage.success('操作成功')
  dialogVisible.value = false
  loadData()
}

async function toggleStatus(row) {
  await categoryApi.update({ id: row.id, status: row.status })
}

async function deleteCategory(row) {
  await ElMessageBox.confirm(`确定删除分类 "${row.name}"？删除后子分类也将受影响`, '警告', { type: 'warning' })
  await categoryApi.delete(row.id)
  ElMessage.success('删除成功')
  loadData()
}
</script>
