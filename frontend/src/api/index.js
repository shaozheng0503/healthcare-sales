import request from '@/utils/request'

// ==================== 用户相关 ====================
export const userApi = {
  login:    data => request.post('/user/login', data),
  register: data => request.post('/user/register', data),
  getInfo:  ()   => request.get('/user/info'),
  update:   data => request.put('/user/update', data),
  list:     params => request.get('/user/list', { params }),
  updateStatus: (id, status) => request.put(`/user/${id}/status`, { status }),
  delete:   id   => request.delete(`/user/${id}`)
}

// ==================== 分类相关 ====================
export const categoryApi = {
  tree:   ()     => request.get('/category/tree'),
  list:   ()     => request.get('/category/list'),
  add:    data   => request.post('/category', data),
  update: data   => request.put('/category', data),
  delete: id     => request.delete(`/category/${id}`)
}

// ==================== 商品相关 ====================
export const productApi = {
  page:   params => request.get('/product/page', { params }),
  detail: id     => request.get(`/product/${id}`),
  add:    data   => request.post('/product', data),
  update: data   => request.put('/product', data),
  delete: id     => request.delete(`/product/${id}`),
  updateStatus: (id, status) => request.put(`/product/${id}/status`, { status }),
  // 库存管理
  adjustStock: data => request.post('/product/stock/adjust', data),
  stockLog:    params => request.get('/product/stock/log', { params })
}

// ==================== 购物车 ====================
export const cartApi = {
  list:   ()     => request.get('/cart/list'),
  add:    data   => request.post('/cart/add', data),
  update: data   => request.put('/cart/update', data),
  delete: id     => request.delete(`/cart/${id}`),
  clear:  ()     => request.delete('/cart/clear')
}

// ==================== 订单相关 ====================
export const orderApi = {
  create:  data   => request.post('/order/create', data),
  myList:  params => request.get('/order/my', { params }),
  list:    params => request.get('/order/list', { params }),
  detail:  orderNo => request.get(`/order/${orderNo}`),
  pay:     orderNo => request.post(`/order/${orderNo}/pay`),
  cancel:  orderNo => request.post(`/order/${orderNo}/cancel`),
  ship:    orderNo => request.post(`/order/${orderNo}/ship`),
  complete: orderNo => request.post(`/order/${orderNo}/complete`)
}

// ==================== 统计相关 ====================
export const statisticsApi = {
  overview:     ()      => request.get('/statistics/overview'),
  salesTrend:   params  => request.get('/statistics/sales-trend', { params }),
  hotProducts:  ()      => request.get('/statistics/hot-products'),
  orderStatus:  ()      => request.get('/statistics/order-status'),
  categoryRatio: ()     => request.get('/statistics/category-ratio')
}

// ==================== 文件上传 ====================
export const fileApi = {
  upload: data => request.post('/file/upload', data, { headers: { 'Content-Type': 'multipart/form-data' } })
}

// ==================== 文章相关 ====================
export const articleApi = {
  page:   params => request.get('/article/page', { params }),
  detail: id     => request.get(`/article/${id}`),
  add:    data   => request.post('/article', data),
  update: data   => request.put('/article', data),
  delete: id     => request.delete(`/article/${id}`),
  publish: id    => request.put(`/article/${id}/publish`)
}
