<template>
  <div class="register-page">
    <div class="bg-decoration">
      <div class="circle c1"></div>
      <div class="circle c2"></div>
    </div>

    <div class="register-card">
      <div class="reg-header">
        <div class="reg-icon">
          <el-icon :size="32" color="#fff"><Leaf /></el-icon>
        </div>
        <h2>创建账号</h2>
        <p>加入健康优选，开始健康生活</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-width="0" size="large">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名（4-20位字母数字）" prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="realName">
          <el-input v-model="form.realName" placeholder="真实姓名" prefix-icon="Avatar" />
        </el-form-item>
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="手机号" prefix-icon="Phone" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" placeholder="密码（6-20位）" prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form.confirmPassword" placeholder="确认密码" prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" style="width:100%;height:44px;font-size:16px;border-radius:10px"
            :loading="loading" @click="handleRegister">
            注 册
          </el-button>
        </el-form-item>
      </el-form>

      <div style="text-align:center;color:var(--text-secondary);font-size:14px">
        已有账号？<el-link type="primary" @click="$router.push('/login')">立即登录</el-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userApi } from '@/api'

const router  = useRouter()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', realName: '', phone: '', password: '', confirmPassword: '' })

const validateConfirm = (rule, value, callback) => {
  if (value !== form.password) callback(new Error('两次密码不一致'))
  else callback()
}
const rules = {
  username:        [{ required: true, min: 4, max: 20, message: '用户名4-20位', trigger: 'blur' }],
  realName:        [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  phone:           [{ required: true, pattern: /^1[3-9]\d{9}$/, message: '手机号格式错误', trigger: 'blur' }],
  password:        [{ required: true, min: 6, max: 20, message: '密码6-20位', trigger: 'blur' }],
  confirmPassword: [{ required: true, validator: validateConfirm, trigger: 'blur' }]
}

async function handleRegister() {
  try {
    await formRef.value.validate()
  } catch { return }
  loading.value = true
  try {
    await userApi.register(form)
    ElMessage.success('注册成功，请登录')
    router.push('/login')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: linear-gradient(160deg, #f0fdf4 0%, #dcfce7 40%, #d1fae5 100%);
  display: flex; align-items: center; justify-content: center;
  position: relative; overflow: hidden;
}
.bg-decoration { position: absolute; inset: 0; pointer-events: none; }
.circle { position: absolute; border-radius: 50%; opacity: 0.08; }
.c1 { width: 500px; height: 500px; background: var(--primary); top: -150px; left: -100px; }
.c2 { width: 350px; height: 350px; background: var(--accent); bottom: -100px; right: -80px; }

.register-card {
  background: #fff;
  border-radius: var(--radius-xl);
  padding: 44px 40px;
  width: 440px;
  box-shadow: var(--shadow-lg);
  position: relative; z-index: 1;
}
.reg-header { text-align: center; margin-bottom: 28px; }
.reg-icon {
  width: 56px; height: 56px;
  background: var(--primary-gradient);
  border-radius: 14px;
  display: inline-flex; align-items: center; justify-content: center;
  margin-bottom: 12px;
}
.reg-header h2 { font-size: 22px; font-weight: 700; color: var(--text-primary); }
.reg-header p { color: var(--text-muted); font-size: 13px; margin-top: 4px; }
</style>
