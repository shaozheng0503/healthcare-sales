<template>
  <el-card>
    <el-form :model="query" inline>
      <el-form-item label="用户名">
        <el-input v-model="query.username" placeholder="搜索用户名" clearable style="width:180px" />
      </el-form-item>
      <el-form-item label="角色">
        <el-select v-model="query.role" clearable style="width:120px">
          <el-option label="管理员" :value="0" />
          <el-option label="商家"   :value="1" />
          <el-option label="消费者" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadList">搜索</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column label="ID" prop="id" width="70" />
      <el-table-column label="头像" width="70">
        <template #default="{ row }">
          <el-avatar :size="36" icon="UserFilled" :src="row.avatar" />
        </template>
      </el-table-column>
      <el-table-column label="用户名" prop="username" width="120" />
      <el-table-column label="真实姓名" prop="realName" width="100" />
      <el-table-column label="手机号" prop="phone" width="130" />
      <el-table-column label="角色" width="90">
        <template #default="{ row }">
          <el-tag :type="roleMap[row.role]?.type" size="small">{{ roleMap[row.role]?.label }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-switch v-model="row.status" :active-value="1" :inactive-value="0"
            :disabled="row.role === 0" @change="toggleStatus(row)" />
        </template>
      </el-table-column>
      <el-table-column label="注册时间" prop="createdAt" width="160" />
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button type="danger" link size="small" :disabled="row.role === 0" @click="deleteUser(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination style="margin-top:16px;justify-content:flex-end;display:flex"
      v-model:current-page="query.page" v-model:page-size="query.size"
      :total="total" layout="total, sizes, prev, pager, next" @change="loadList" />
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userApi } from '@/api'

const loading = ref(false)
const list    = ref([])
const total   = ref(0)
const query   = reactive({ page: 1, size: 10, username: '', role: null })

const roleMap = {
  0: { label: '管理员', type: 'danger' },
  1: { label: '商家',   type: 'warning' },
  2: { label: '消费者', type: 'info' }
}

onMounted(loadList)

async function loadList() {
  loading.value = true
  try {
    const res = await userApi.list(query)
    list.value  = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  Object.assign(query, { page: 1, username: '', role: null })
  loadList()
}

async function toggleStatus(row) {
  await userApi.updateStatus(row.id, row.status)
  ElMessage.success(row.status === 1 ? '已启用' : '已禁用')
}

async function deleteUser(row) {
  await ElMessageBox.confirm(`确定删除用户 "${row.username}"？`, '警告', { type: 'warning' })
  await userApi.delete(row.id)
  ElMessage.success('删除成功')
  loadList()
}
</script>
