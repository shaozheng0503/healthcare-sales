<template>
  <div>
    <h2 class="page-title">个人中心</h2>
    <el-row :gutter="24">
      <!-- 左侧用户卡片 -->
      <el-col :span="8">
        <div class="user-card">
          <div class="user-avatar-area">
            <div class="avatar-ring">
              <el-avatar :size="72" icon="UserFilled" />
            </div>
            <div class="user-name">
              {{ userStore.userInfo?.realName || userStore.userInfo?.username }}
            </div>
            <el-tag :type="roleMap[userStore.userInfo?.role]?.type" size="small" round effect="plain">
              {{ roleMap[userStore.userInfo?.role]?.label }}
            </el-tag>
          </div>

          <div class="user-menu">
            <div class="menu-item" :class="{ active: activeMenu === 'info' }" @click="activeMenu = 'info'">
              <el-icon><User /></el-icon>
              <span>个人信息</span>
              <el-icon class="menu-arrow"><ArrowRight /></el-icon>
            </div>
            <div class="menu-item" :class="{ active: activeMenu === 'password' }" @click="activeMenu = 'password'">
              <el-icon><Lock /></el-icon>
              <span>修改密码</span>
              <el-icon class="menu-arrow"><ArrowRight /></el-icon>
            </div>
          </div>
        </div>
      </el-col>

      <!-- 右侧内容 -->
      <el-col :span="16">
        <transition name="slide-up" mode="out-in">
          <!-- 个人信息 -->
          <el-card v-if="activeMenu === 'info'" key="info" class="content-card">
            <template #header>
              <div class="card-title"><el-icon color="var(--primary)"><User /></el-icon> 个人信息</div>
            </template>
            <el-form ref="infoFormRef" :model="infoForm" label-width="90px" style="max-width:480px">
              <el-form-item label="用户名">
                <el-input :value="userStore.userInfo?.username" disabled />
              </el-form-item>
              <el-form-item label="真实姓名">
                <el-input v-model="infoForm.realName" placeholder="请输入真实姓名" />
              </el-form-item>
              <el-form-item label="手机号">
                <el-input v-model="infoForm.phone" placeholder="请输入手机号" />
              </el-form-item>
              <el-form-item label="邮箱">
                <el-input v-model="infoForm.email" placeholder="请输入邮箱" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" style="border-radius:8px" @click="saveInfo">保存修改</el-button>
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 修改密码 -->
          <el-card v-else key="password" class="content-card">
            <template #header>
              <div class="card-title"><el-icon color="var(--accent)"><Lock /></el-icon> 修改密码</div>
            </template>
            <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-width="90px" style="max-width:480px">
              <el-form-item label="原密码" prop="oldPassword">
                <el-input v-model="pwdForm.oldPassword" show-password placeholder="请输入当前密码" />
              </el-form-item>
              <el-form-item label="新密码" prop="newPassword">
                <el-input v-model="pwdForm.newPassword" show-password placeholder="至少6位" />
              </el-form-item>
              <el-form-item label="确认密码" prop="confirmPassword">
                <el-input v-model="pwdForm.confirmPassword" show-password placeholder="再次输入新密码" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" style="border-radius:8px" @click="changePassword">确认修改</el-button>
              </el-form-item>
            </el-form>
          </el-card>
        </transition>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { userApi } from '@/api'

const userStore = useUserStore()
const activeMenu = ref('info')

const roleMap = {
  0: { label: '管理员', type: 'danger' },
  1: { label: '商家',   type: 'warning' },
  2: { label: '消费者', type: 'info' }
}

const infoForm = reactive({
  realName: userStore.userInfo?.realName || '',
  phone:    userStore.userInfo?.phone    || '',
  email:    userStore.userInfo?.email    || ''
})

const pwdFormRef = ref()
const pwdForm    = reactive({ oldPassword: '', newPassword: '', confirmPassword: '' })
const pwdRules   = {
  oldPassword:     [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword:     [{ required: true, min: 6, message: '密码至少6位', trigger: 'blur' }],
  confirmPassword: [{ required: true, validator: (r, v, cb) => v !== pwdForm.newPassword ? cb(new Error('两次密码不一致')) : cb(), trigger: 'blur' }]
}

async function saveInfo() {
  await userApi.update(infoForm)
  const res = await userApi.getInfo()
  const updated = res.data
  userStore.userInfo = updated
  localStorage.setItem('userInfo', JSON.stringify(updated))
  infoForm.realName = updated.realName || ''
  infoForm.phone    = updated.phone || ''
  infoForm.email    = updated.email || ''
  ElMessage.success('保存成功')
}

async function changePassword() {
  try { await pwdFormRef.value.validate() } catch { return }
  await userApi.update({ oldPassword: pwdForm.oldPassword, password: pwdForm.newPassword })
  ElMessage.success('密码修改成功，请重新登录')
  userStore.logout()
  window.location.href = '/login'
}
</script>

<style scoped>
.page-title { font-size: 22px; font-weight: 700; margin-bottom: 24px; color: var(--text-primary); }

/* 用户卡片 */
.user-card {
  background: var(--bg-card); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm); overflow: hidden;
  position: sticky; top: 100px;
}
.user-avatar-area {
  padding: 32px 24px;
  text-align: center;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}
.avatar-ring {
  display: inline-flex; padding: 4px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary-light), var(--primary));
}
.avatar-ring :deep(.el-avatar) { border: 3px solid #fff; }
.user-name {
  margin-top: 12px; font-size: 18px; font-weight: 600; color: var(--text-primary);
}
.user-avatar-area .el-tag { margin-top: 8px; }

.user-menu { padding: 8px; }
.menu-item {
  display: flex; align-items: center; gap: 10px;
  padding: 14px 16px; border-radius: var(--radius-sm);
  cursor: pointer; transition: all 0.2s;
  font-size: 14px; color: var(--text-secondary);
}
.menu-item:hover { background: #f8fafc; }
.menu-item.active {
  background: var(--primary-lighter); color: var(--primary); font-weight: 500;
}
.menu-item span { flex: 1; }
.menu-arrow { font-size: 12px; color: var(--text-muted); }
.menu-item.active .menu-arrow { color: var(--primary); }

/* 内容卡片 */
.content-card { border-radius: var(--radius-lg) !important; }
.card-title { display: flex; align-items: center; gap: 8px; font-weight: 600; font-size: 15px; }

/* slide-up 动画在 App.vue 全局定义 */
</style>
