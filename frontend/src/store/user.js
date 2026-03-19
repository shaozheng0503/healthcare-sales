import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || 'null'))

  const isAdmin = computed(() => userInfo.value?.role === 0)
  const isShop  = computed(() => userInfo.value?.role === 1)
  const isBackend = computed(() => [0, 1].includes(userInfo.value?.role))

  function setLogin(data) {
    token.value = data.token
    userInfo.value = data.userInfo
    localStorage.setItem('token', data.token)
    localStorage.setItem('userInfo', JSON.stringify(data.userInfo))
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
  }

  return { token, userInfo, isAdmin, isShop, isBackend, setLogin, logout }
})
