<template>
  <div class="checkout-page">
    <h2 class="page-title">确认订单</h2>

    <el-row :gutter="24">
      <el-col :span="16">
        <!-- 收货信息 -->
        <el-card class="section-card">
          <template #header>
            <div class="section-header">
              <el-icon color="var(--primary)"><Location /></el-icon>
              <span>收货信息</span>
            </div>
          </template>
          <el-form ref="addrFormRef" :model="addrForm" :rules="addrRules" label-width="90px">
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="收货人" prop="receiverName">
                  <el-input v-model="addrForm.receiverName" placeholder="请输入收货人姓名" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="手机号码" prop="receiverPhone">
                  <el-input v-model="addrForm.receiverPhone" placeholder="11位手机号" />
                </el-form-item>
              </el-col>
              <el-col :span="24">
                <el-form-item label="收货地址" prop="receiverAddress">
                  <el-input v-model="addrForm.receiverAddress" placeholder="省市区 + 详细地址" />
                </el-form-item>
              </el-col>
              <el-col :span="24">
                <el-form-item label="买家备注">
                  <el-input v-model="addrForm.remark" placeholder="可选，填写备注信息" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>

        <!-- 商品清单 -->
        <el-card class="section-card" style="margin-top:16px">
          <template #header>
            <div class="section-header">
              <el-icon color="var(--primary)"><Goods /></el-icon>
              <span>商品清单 ({{ checkoutItems.length }}件)</span>
            </div>
          </template>
          <div v-for="item in checkoutItems" :key="item.productId" class="checkout-item">
            <el-image :src="item.productImage" class="item-img" fit="cover">
              <template #error><div class="item-img-fallback"><el-icon><Picture /></el-icon></div></template>
            </el-image>
            <div class="item-info">
              <div class="item-name">{{ item.productName }}</div>
              <div class="item-meta">
                <span class="item-price">¥{{ item.price }}</span>
                <span class="item-qty">x{{ item.quantity }}</span>
              </div>
            </div>
            <div class="item-subtotal">¥{{ (item.price * item.quantity).toFixed(2) }}</div>
          </div>
        </el-card>
      </el-col>

      <!-- 支付面板 -->
      <el-col :span="8">
        <div class="pay-card">
          <div class="pay-title">支付方式</div>
          <div class="pay-method active">
            <el-icon color="var(--primary)" :size="20"><Wallet /></el-icon>
            <span>余额支付（模拟）</span>
            <el-icon color="var(--primary)"><Check /></el-icon>
          </div>

          <div class="pay-divider"></div>

          <div class="pay-row">
            <span>商品合计</span>
            <span>¥{{ totalAmount }}</span>
          </div>
          <div class="pay-row">
            <span>运费</span>
            <span style="color:var(--primary)">免运费</span>
          </div>
          <div class="pay-divider"></div>
          <div class="pay-row pay-total">
            <span>实付金额</span>
            <span class="pay-price">¥{{ totalAmount }}</span>
          </div>

          <el-button type="primary" size="large"
            style="width:100%;height:48px;border-radius:12px;font-size:16px;margin-top:24px"
            :loading="submitting" @click="submitOrder">
            提交订单
          </el-button>

          <div class="pay-hint">
            <el-icon><Warning /></el-icon> 提交后将自动模拟支付
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { orderApi } from '@/api'

const router    = useRouter()
const submitting = ref(false)
const checkoutItems = ref([])
const payType   = ref(1)

const addrFormRef = ref()
const addrForm  = reactive({ receiverName: '', receiverPhone: '', receiverAddress: '', remark: '' })
const addrRules = {
  receiverName:    [{ required: true, message: '请填写收货人', trigger: 'blur' }],
  receiverPhone:   [{ required: true, pattern: /^1[3-9]\d{9}$/, message: '手机号格式错误', trigger: 'blur' }],
  receiverAddress: [{ required: true, message: '请填写收货地址', trigger: 'blur' }]
}

const totalAmount = computed(() => {
  return checkoutItems.value.reduce((sum, item) => sum + item.price * item.quantity, 0).toFixed(2)
})

onMounted(() => {
  const data = sessionStorage.getItem('checkoutItems')
  if (!data) { router.push('/cart'); return }
  checkoutItems.value = JSON.parse(data)
})

async function submitOrder() {
  try { await addrFormRef.value.validate() } catch { return }
  if (!checkoutItems.value.length) { ElMessage.warning('请选择商品'); return }
  submitting.value = true
  try {
    const res = await orderApi.create({
      ...addrForm,
      payType: payType.value,
      items: checkoutItems.value.map(i => ({ cartId: i.id, productId: i.productId, quantity: i.quantity }))
    })
    await orderApi.pay(res.data.orderNo)
    sessionStorage.removeItem('checkoutItems')
    ElMessage.success('下单并支付成功！')
    router.push('/orders')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.checkout-page { }
.page-title { font-size: 22px; font-weight: 700; margin-bottom: 24px; color: var(--text-primary); }

.section-card { border-radius: var(--radius-lg) !important; }
.section-header { display: flex; align-items: center; gap: 8px; font-weight: 600; font-size: 15px; }

.checkout-item {
  display: flex; align-items: center; gap: 16px;
  padding: 14px 0;
  border-bottom: 1px solid #f1f5f9;
}
.checkout-item:last-child { border-bottom: none; }
.item-img { width: 64px; height: 64px; border-radius: 8px; flex-shrink: 0; }
.item-img-fallback {
  width: 64px; height: 64px; border-radius: 8px; background: #f1f5f9;
  display: flex; align-items: center; justify-content: center; color: #cbd5e1; font-size: 20px;
}
.item-info { flex: 1; }
.item-name { font-size: 14px; color: var(--text-primary); line-height: 1.5; }
.item-meta { margin-top: 4px; display: flex; gap: 10px; }
.item-price { color: var(--text-secondary); font-size: 13px; }
.item-qty { color: var(--text-muted); font-size: 13px; }
.item-subtotal { font-size: 16px; font-weight: 600; color: #e53e3e; white-space: nowrap; }

/* 支付面板 */
.pay-card {
  background: var(--bg-card); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm); padding: 28px 24px;
  position: sticky; top: 100px;
}
.pay-title { font-size: 18px; font-weight: 700; margin-bottom: 16px; color: var(--text-primary); }

.pay-method {
  display: flex; align-items: center; gap: 10px;
  padding: 14px 16px; border-radius: var(--radius-sm);
  border: 2px solid var(--border-light);
  font-size: 14px; color: var(--text-secondary);
  transition: border-color 0.2s;
}
.pay-method.active { border-color: var(--primary); background: var(--primary-lighter); }
.pay-method span { flex: 1; }

.pay-divider { height: 1px; background: var(--border-light); margin: 18px 0; }
.pay-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 14px; color: var(--text-secondary); }
.pay-total { font-weight: 600; color: var(--text-primary); font-size: 15px; }
.pay-price { font-size: 26px; font-weight: 700; color: #e53e3e; }

.pay-hint {
  display: flex; align-items: center; justify-content: center; gap: 4px;
  margin-top: 12px; font-size: 12px; color: var(--text-muted);
}
</style>
