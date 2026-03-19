<template>
  <div class="login-page">
    <!-- 装饰背景 -->
    <div class="bg-decoration">
      <div class="circle c1"></div>
      <div class="circle c2"></div>
      <div class="circle c3"></div>
    </div>

    <div class="login-container">
      <!-- 左侧品牌区 -->
      <div class="brand-side">
        <div class="brand-content">
          <div class="brand-icon">
            <el-icon :size="56" color="#fff"><Leaf /></el-icon>
          </div>
          <h1>健康优选</h1>
          <p class="brand-slogan">安全可靠的保健用品<br />呵护您的健康生活</p>
          <div class="brand-features">
            <div class="feature-item">
              <el-icon><Check /></el-icon> 品质保障
            </div>
            <div class="feature-item">
              <el-icon><Check /></el-icon> 专业科普
            </div>
            <div class="feature-item">
              <el-icon><Check /></el-icon> 智能管理
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧表单区 -->
      <div class="form-side">
        <div class="form-content">
          <h2>欢迎登录</h2>
          <p class="form-subtitle">日常保健用品销售管理系统</p>

          <el-form ref="formRef" :model="form" :rules="rules" size="large" style="margin-top:32px">
            <el-form-item prop="username">
              <el-input v-model="form.username" placeholder="请输入用户名" prefix-icon="User" clearable />
            </el-form-item>
            <el-form-item prop="password">
              <el-input v-model="form.password" placeholder="请输入密码" prefix-icon="Lock"
                show-password @keyup.enter="handleLogin" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" style="width:100%;height:44px;font-size:16px;border-radius:10px"
                :loading="loading" @click="handleLogin">
                登 录
              </el-button>
            </el-form-item>
          </el-form>

          <div class="login-links">
            还没有账号？
            <el-link type="primary" @click="$router.push('/register')">立即注册</el-link>
            <el-divider direction="vertical" />
            <el-link @click="$router.push('/')">浏览商城</el-link>
          </div>

          <div class="test-accounts">
            <div class="test-title">测试账号（密码均为 admin123）</div>
            <div class="test-items">
              <span class="test-tag admin" @click="fillAccount('admin')">admin 管理员</span>
              <span class="test-tag shop" @click="fillAccount('shop01')">shop01 商家</span>
              <span class="test-tag user" @click="fillAccount('user01')">user01 消费者</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const route  = useRoute()
const userStore = useUserStore()

const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

function fillAccount(username) {
  form.username = username
  form.password = 'admin123'
}

async function handleLogin() {
  try {
    await formRef.value.validate()
  } catch { return }
  loading.value = true
  try {
    const res = await userApi.login(form)
    userStore.setLogin(res.data)
    ElMessage.success('登录成功')
    const redirect = route.query.redirect
    if (redirect) {
      router.push(redirect)
    } else if ([0, 1].includes(res.data.userInfo.role)) {
      router.push('/admin/dashboard')
    } else {
      router.push('/')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(160deg, #f0fdf4 0%, #dcfce7 40%, #d1fae5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* 装饰圆形 */
.bg-decoration { position: absolute; inset: 0; pointer-events: none; }
.circle { position: absolute; border-radius: 50%; opacity: 0.08; }
.c1 { width: 600px; height: 600px; background: var(--primary); top: -200px; right: -100px; }
.c2 { width: 400px; height: 400px; background: var(--primary-light); bottom: -150px; left: -100px; }
.c3 { width: 200px; height: 200px; background: var(--accent); top: 50%; left: 15%; }

.login-container {
  display: flex;
  width: 880px;
  min-height: 520px;
  border-radius: var(--radius-xl);
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  position: relative;
  z-index: 1;
}

/* 左侧品牌 */
.brand-side {
  flex: 0 0 360px;
  background: var(--primary-gradient);
  padding: 48px 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: #fff;
  position: relative;
  overflow: hidden;
}
.brand-side::after {
  content: '';
  position: absolute;
  width: 300px; height: 300px;
  border-radius: 50%;
  background: rgba(255,255,255,0.06);
  bottom: -80px; right: -60px;
}
.brand-content { position: relative; z-index: 1; }
.brand-icon {
  width: 80px; height: 80px;
  background: rgba(255,255,255,0.15);
  border-radius: 20px;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 24px;
}
.brand-side h1 { font-size: 28px; font-weight: 700; margin-bottom: 12px; }
.brand-slogan { font-size: 15px; line-height: 1.8; opacity: 0.85; margin-bottom: 32px; }
.brand-features { display: flex; flex-direction: column; gap: 10px; }
.feature-item {
  display: flex; align-items: center; gap: 8px;
  font-size: 14px; opacity: 0.9;
}

/* 右侧表单 */
.form-side {
  flex: 1;
  background: #fff;
  padding: 48px 44px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.form-content h2 { font-size: 24px; font-weight: 700; color: var(--text-primary); }
.form-subtitle { color: var(--text-muted); font-size: 14px; margin-top: 6px; }

.login-links { text-align: center; color: var(--text-secondary); font-size: 14px; margin-top: 8px; }

/* 测试账号 */
.test-accounts {
  margin-top: 24px;
  padding: 16px;
  background: #f8fafc;
  border-radius: var(--radius-md);
}
.test-title { font-size: 12px; color: var(--text-muted); margin-bottom: 10px; }
.test-items { display: flex; gap: 8px; flex-wrap: wrap; }
.test-tag {
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 500;
}
.test-tag:hover { transform: scale(1.05); }
.test-tag.admin { background: #fef2f2; color: #dc2626; }
.test-tag.shop  { background: #fffbeb; color: #d97706; }
.test-tag.user  { background: #eff6ff; color: #2563eb; }
</style>
