import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/store/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/common/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/common/Register.vue'),
    meta: { title: '注册' }
  },

  // 管理员/商家后台
  {
    path: '/admin',
    component: () => import('@/views/admin/Layout.vue'),
    redirect: '/admin/dashboard',
    meta: { requiresAuth: true, roles: [0, 1] },
    children: [
      { path: 'dashboard',           name: 'Dashboard',       component: () => import('@/views/admin/Dashboard.vue'),        meta: { title: '数据看板' } },
      { path: 'user',                name: 'UserManage',      component: () => import('@/views/admin/UserManage.vue'),       meta: { title: '用户管理', roles: [0] } },
      { path: 'category',            name: 'CategoryManage',  component: () => import('@/views/admin/CategoryManage.vue'),   meta: { title: '分类管理' } },
      { path: 'product',             name: 'ProductManage',   component: () => import('@/views/admin/ProductManage.vue'),    meta: { title: '商品管理' } },
      { path: 'stock',               name: 'StockManage',     component: () => import('@/views/admin/StockManage.vue'),      meta: { title: '库存管理' } },
      { path: 'order',               name: 'OrderManage',     component: () => import('@/views/admin/OrderManage.vue'),      meta: { title: '订单管理' } },
      { path: 'statistics',          name: 'Statistics',      component: () => import('@/views/admin/Statistics.vue'),       meta: { title: '销售统计' } },
      { path: 'article',             name: 'ArticleManage',   component: () => import('@/views/admin/ArticleManage.vue'),    meta: { title: '科普管理' } }
    ]
  },

  // 消费者前台
  {
    path: '/',
    component: () => import('@/views/consumer/Layout.vue'),
    children: [
      { path: '',                    name: 'Home',            component: () => import('@/views/consumer/Home.vue'),           meta: { title: '首页' } },
      { path: 'products',            name: 'Products',        component: () => import('@/views/consumer/Products.vue'),       meta: { title: '商品列表' } },
      { path: 'product/:id',         name: 'ProductDetail',   component: () => import('@/views/consumer/ProductDetail.vue'),  meta: { title: '商品详情' } },
      { path: 'cart',                name: 'Cart',            component: () => import('@/views/consumer/Cart.vue'),           meta: { title: '购物车', requiresAuth: true } },
      { path: 'checkout',            name: 'Checkout',        component: () => import('@/views/consumer/Checkout.vue'),       meta: { title: '确认订单', requiresAuth: true } },
      { path: 'orders',              name: 'Orders',          component: () => import('@/views/consumer/Orders.vue'),         meta: { title: '我的订单', requiresAuth: true } },
      { path: 'articles',            name: 'Articles',        component: () => import('@/views/consumer/Articles.vue'),       meta: { title: '健康科普' } },
      { path: 'article/:id',         name: 'ArticleDetail',   component: () => import('@/views/consumer/ArticleDetail.vue'),  meta: { title: '文章详情' } },
      { path: 'profile',             name: 'Profile',         component: () => import('@/views/consumer/Profile.vue'),        meta: { title: '个人中心', requiresAuth: true } }
    ]
  },

  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

// 路由守卫
router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - 健康优选` : '健康优选'

  const userStore = useUserStore()
  if (to.meta.requiresAuth && !userStore.token) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }
  if (to.meta.roles && !to.meta.roles.includes(userStore.userInfo?.role)) {
    next({ path: '/' })
    return
  }
  next()
})

export default router
