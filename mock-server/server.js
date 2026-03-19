const express = require('express')
const cors    = require('cors')
const app     = express()
app.use(cors())
app.use(express.json())

// ─── 统一响应 ─────────────────────────────────────────────
const ok  = (data) => ({ code: 200, message: '操作成功', data })
const page = (records, total = records.length) =>
  ok({ records, total, current: 1, size: 10 })

// ─── 用户 ─────────────────────────────────────────────────
app.post('/api/user/login', (req, res) => {
  const { username } = req.body
  const roles = { admin: 0, shop01: 1, user01: 2 }
  const role  = roles[username] ?? 2
  res.json(ok({
    token: 'mock-jwt-token-2026',
    userInfo: { id: 1, username, realName: username === 'admin' ? '系统管理员' : (username === 'shop01' ? '商家张三' : '李四'), role, status: 1 }
  }))
})
app.get('/api/user/info',   (req, res) => res.json(ok({ id:1, username:'admin', realName:'系统管理员', role:0 })))
app.post('/api/user/register', (req, res) => res.json(ok(null)))
app.get('/api/user/list',   (req, res) => res.json(page([
  { id:1, username:'admin',  realName:'系统管理员', phone:'13800000000', role:0, status:1, createdAt:'2026-01-01 00:00:00' },
  { id:2, username:'shop01', realName:'商家张三',   phone:'13811111111', role:1, status:1, createdAt:'2026-01-05 10:20:00' },
  { id:3, username:'user01', realName:'李四',       phone:'13822222222', role:2, status:1, createdAt:'2026-02-10 08:30:00' },
  { id:4, username:'user02', realName:'王芳',       phone:'13833333333', role:2, status:1, createdAt:'2026-02-15 14:20:00' },
  { id:5, username:'user03', realName:'陈明',       phone:'13844444444', role:2, status:0, createdAt:'2026-03-01 09:10:00' },
], 5)))
app.put('/api/user/:id/status', (req, res) => res.json(ok(null)))
app.delete('/api/user/:id',     (req, res) => res.json(ok(null)))
app.put('/api/user/update',     (req, res) => res.json(ok(null)))

// ─── 分类（非食用类保健用品） ─────────────────────────────
const categories = [
  { id:1, name:'外用贴剂类', parentId:0, sort:1, status:1, children:[
    { id:9,  name:'艾灸贴', parentId:1, sort:1, status:1, children:[] },
    { id:10, name:'热敷贴', parentId:1, sort:2, status:1, children:[] },
    { id:11, name:'冷敷贴', parentId:1, sort:3, status:1, children:[] },
  ]},
  { id:2, name:'理疗器械类', parentId:0, sort:2, status:1, children:[
    { id:12, name:'按摩仪', parentId:2, sort:1, status:1, children:[] },
    { id:13, name:'理疗仪', parentId:2, sort:2, status:1, children:[] },
  ]},
  { id:3, name:'健康监测类', parentId:0, sort:3, status:1, children:[
    { id:14, name:'血压计', parentId:3, sort:1, status:1, children:[] },
    { id:15, name:'血糖仪', parentId:3, sort:2, status:1, children:[] },
    { id:16, name:'体温计', parentId:3, sort:3, status:1, children:[] },
  ]},
  { id:4, name:'康复辅助类', parentId:0, sort:4, status:1, children:[
    { id:17, name:'护膝',       parentId:4, sort:1, status:1, children:[] },
    { id:18, name:'颈椎牵引器', parentId:4, sort:2, status:1, children:[] },
  ]},
  { id:5, name:'中医保健类', parentId:0, sort:5, status:1, children:[
    { id:19, name:'拔罐器', parentId:5, sort:1, status:1, children:[] },
    { id:20, name:'刮痧板', parentId:5, sort:2, status:1, children:[] },
  ]},
  { id:6, name:'睡眠环境类', parentId:0, sort:6, status:1, children:[
    { id:21, name:'记忆枕',   parentId:6, sort:1, status:1, children:[] },
    { id:22, name:'睡眠眼罩', parentId:6, sort:2, status:1, children:[] },
  ]},
  { id:7, name:'运动保健类', parentId:0, sort:7, status:1, children:[
    { id:23, name:'筋膜枪', parentId:7, sort:1, status:1, children:[] },
    { id:24, name:'瑜伽垫', parentId:7, sort:2, status:1, children:[] },
  ]},
  { id:8, name:'消毒防护类', parentId:0, sort:8, status:1, children:[
    { id:25, name:'消毒灯',     parentId:8, sort:1, status:1, children:[] },
    { id:26, name:'空气净化器', parentId:8, sort:2, status:1, children:[] },
  ]},
]
app.get('/api/category/tree', (req, res) => res.json(ok(categories)))
app.get('/api/category/list', (req, res) => res.json(ok(categories)))
app.post('/api/category',     (req, res) => res.json(ok(null)))
app.put('/api/category',      (req, res) => res.json(ok(null)))
app.delete('/api/category/:id',(req, res) => res.json(ok(null)))

// ─── 商品（非食用类保健用品） ─────────────────────────────
const products = [
  { id:1,  categoryId:9,  categoryName:'艾灸贴',   name:'南极人艾灸贴30片装',       price:39.90, originalPrice:59.00, stock:200, stockWarning:20, salesCount:156, status:1, imageUrl:'https://picsum.photos/200/200?random=101', description:'温经散寒，缓解肩颈腰腿酸痛' },
  { id:2,  categoryId:10, categoryName:'热敷贴',   name:'云南白药热敷贴6片装',      price:25.00, originalPrice:35.00, stock:150, stockWarning:15, salesCount:89,  status:1, imageUrl:'https://picsum.photos/200/200?random=102', description:'持续发热8小时，缓解肌肉疲劳' },
  { id:3,  categoryId:12, categoryName:'按摩仪',   name:'SKG颈椎按摩仪K5',          price:299.00,originalPrice:399.00,stock:80,  stockWarning:8,  salesCount:203, status:1, imageUrl:'https://picsum.photos/200/200?random=103', description:'脉冲+热敷双模式，缓解颈肩疲劳' },
  { id:4,  categoryId:13, categoryName:'理疗仪',   name:'奥佳华低频理疗仪',         price:198.00,originalPrice:258.00,stock:60,  stockWarning:5,  salesCount:67,  status:1, imageUrl:'https://picsum.photos/200/200?random=104', description:'低频脉冲电流刺激，舒缓肌肉酸痛' },
  { id:5,  categoryId:14, categoryName:'血压计',   name:'欧姆龙电子血压计U10',      price:298.00,originalPrice:368.00,stock:120, stockWarning:12, salesCount:312, status:1, imageUrl:'https://picsum.photos/200/200?random=105', description:'上臂式精准测量，家用医用级' },
  { id:6,  categoryId:15, categoryName:'血糖仪',   name:'鱼跃血糖仪580套装',        price:128.00,originalPrice:168.00,stock:100, stockWarning:10, salesCount:145, status:1, imageUrl:'https://picsum.photos/200/200?random=106', description:'微量采血，5秒速测，含试纸' },
  { id:7,  categoryId:17, categoryName:'护膝',     name:'保而防专业运动护膝',       price:168.00,originalPrice:228.00,stock:200, stockWarning:20, salesCount:89,  status:1, imageUrl:'https://picsum.photos/200/200?random=107', description:'硅胶环绕髌骨，运动防护+康复支撑' },
  { id:8,  categoryId:18, categoryName:'颈椎牵引器',name:'佳禾颈椎牵引器',          price:58.00, originalPrice:78.00, stock:180, stockWarning:15, salesCount:234, status:1, imageUrl:'https://picsum.photos/200/200?random=108', description:'充气式颈椎牵引，可调节力度' },
  { id:9,  categoryId:19, categoryName:'拔罐器',   name:'华佗牌真空拔罐器24罐',     price:69.00, originalPrice:99.00, stock:150, stockWarning:15, salesCount:178, status:1, imageUrl:'https://picsum.photos/200/200?random=109', description:'家用真空拔罐套装，操作简便' },
  { id:10, categoryId:20, categoryName:'刮痧板',   name:'砭石刮痧板套装',           price:45.00, originalPrice:68.00, stock:200, stockWarning:20, salesCount:156, status:1, imageUrl:'https://picsum.photos/200/200?random=110', description:'天然砭石材质，面部+身体刮痧' },
  { id:11, categoryId:21, categoryName:'记忆枕',   name:'泰普尔记忆枕头',           price:399.00,originalPrice:499.00,stock:3,   stockWarning:3,  salesCount:56,  status:1, imageUrl:'https://picsum.photos/200/200?random=111', description:'丹麦品牌，慢回弹记忆棉' },
  { id:12, categoryId:22, categoryName:'睡眠眼罩', name:'睡眠博士护颈枕',           price:199.00,originalPrice:259.00,stock:4,   stockWarning:5,  salesCount:78,  status:1, imageUrl:'https://picsum.photos/200/200?random=112', description:'分区设计，高低可调' },
  { id:13, categoryId:23, categoryName:'筋膜枪',   name:'麦瑞克筋膜枪Mini',         price:259.00,originalPrice:359.00,stock:90,  stockWarning:10, salesCount:127, status:1, imageUrl:'https://picsum.photos/200/200?random=113', description:'便携迷你款，6档力度调节' },
  { id:14, categoryId:24, categoryName:'瑜伽垫',   name:'Lululemon瑜伽垫5mm',       price:368.00,originalPrice:458.00,stock:60,  stockWarning:5,  salesCount:98,  status:1, imageUrl:'https://picsum.photos/200/200?random=114', description:'天然橡胶材质，防滑耐磨' },
  { id:15, categoryId:25, categoryName:'消毒灯',   name:'飞利浦紫外线消毒灯',       price:189.00,originalPrice:249.00,stock:100, stockWarning:10, salesCount:87,  status:1, imageUrl:'https://picsum.photos/200/200?random=115', description:'紫外线+臭氧双重杀菌' },
  { id:16, categoryId:26, categoryName:'空气净化器',name:'小米空气净化器4Pro',       price:899.00,originalPrice:1099.00,stock:40, stockWarning:3,  salesCount:65,  status:1, imageUrl:'https://picsum.photos/200/200?random=116', description:'除甲醛除菌，HEPA滤芯' },
]
app.get('/api/product/page',   (req, res) => res.json(page(products, 16)))
app.get('/api/product/:id',    (req, res) => res.json(ok(products.find(p=>p.id==req.params.id)||products[0])))
app.post('/api/product',       (req, res) => res.json(ok(null)))
app.put('/api/product',        (req, res) => res.json(ok(null)))
app.delete('/api/product/:id', (req, res) => res.json(ok(null)))
app.put('/api/product/:id/status',   (req, res) => res.json(ok(null)))
app.post('/api/product/stock/adjust',(req, res) => res.json(ok(null)))
app.get('/api/product/stock/log',    (req, res) => res.json(page([
  { id:1, productName:'南极人艾灸贴30片装', type:2, changeQuantity:-2, beforeStock:202, afterStock:200, orderNo:'HC20260318001', createdAt:'2026-03-18 10:20:00', remark:'订单出库' },
  { id:2, productName:'SKG颈椎按摩仪K5',   type:1, changeQuantity:10, beforeStock:70,  afterStock:80,  createdAt:'2026-03-17 14:30:00', remark:'入库补货' },
  { id:3, productName:'保而防专业运动护膝', type:2, changeQuantity:-1, beforeStock:201, afterStock:200, orderNo:'HC20260317002', createdAt:'2026-03-17 09:10:00', remark:'订单出库' },
])))

// ─── 购物车 ────────────────────────────────────────────────
app.get('/api/cart/list', (req, res) => res.json(ok([
  { id:1, userId:3, productId:1, productName:'南极人艾灸贴30片装', price:39.90, productImage:'https://picsum.photos/200/200?random=101', stock:200, quantity:2 },
  { id:2, userId:3, productId:8, productName:'佳禾颈椎牵引器',     price:58.00, productImage:'https://picsum.photos/200/200?random=108', stock:180, quantity:1 },
])))
app.post('/api/cart/add',    (req, res) => res.json(ok(null)))
app.put('/api/cart/update',  (req, res) => res.json(ok(null)))
app.delete('/api/cart/clear',(req, res) => res.json(ok(null)))
app.delete('/api/cart/:id',  (req, res) => res.json(ok(null)))

// ─── 订单 ─────────────────────────────────────────────────
const orders = [
  { id:1, orderNo:'HC20260318143201234', userId:3, username:'user01', realName:'李四', totalAmount:357.90, payAmount:357.90, status:3, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-18 14:32:00', payTime:'2026-03-18 14:32:30',
    items:[
      { id:1, productName:'SKG颈椎按摩仪K5',   productImage:'https://picsum.photos/60/60?random=103', price:299.00, quantity:1, totalPrice:299.00 },
      { id:2, productName:'佳禾颈椎牵引器',     productImage:'https://picsum.photos/60/60?random=108', price:58.00,  quantity:1, totalPrice:58.00 },
    ]
  },
  { id:2, orderNo:'HC20260317092305678', userId:3, username:'user01', realName:'李四', totalAmount:298.00, payAmount:298.00, status:2, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-17 09:23:00', payTime:'2026-03-17 09:23:45',
    items:[{ id:3, productName:'欧姆龙电子血压计U10', productImage:'https://picsum.photos/60/60?random=105', price:298.00, quantity:1, totalPrice:298.00 }]
  },
  { id:3, orderNo:'HC20260315161109012', userId:4, username:'user02', realName:'王芳', totalAmount:259.00,payAmount:259.00,status:1, receiverName:'王芳', receiverPhone:'13833333333', receiverAddress:'上海市浦东新区张江高科技园区', createdAt:'2026-03-15 16:11:00', payTime:'2026-03-15 16:12:00',
    items:[{ id:4, productName:'麦瑞克筋膜枪Mini', productImage:'https://picsum.photos/60/60?random=113', price:259.00, quantity:1, totalPrice:259.00 }]
  },
  { id:4, orderNo:'HC20260310103207654', userId:3, username:'user01', realName:'李四', totalAmount:69.00, payAmount:69.00, status:0, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-10 10:32:00',
    items:[{ id:5, productName:'华佗牌真空拔罐器24罐', productImage:'https://picsum.photos/60/60?random=109', price:69.00, quantity:1, totalPrice:69.00 }]
  },
]
app.post('/api/order/create',        (req, res) => res.json(ok({ orderNo:'HC20260319'+Date.now() })))
app.get('/api/order/my',             (req, res) => res.json(ok({ records: orders.slice(0,3), total:3, current:1, size:5 })))
app.get('/api/order/list',           (req, res) => res.json(page(orders, 4)))
app.get('/api/order/:orderNo',       (req, res) => res.json(ok(orders[0])))
app.post('/api/order/:no/pay',       (req, res) => res.json(ok(null)))
app.post('/api/order/:no/ship',      (req, res) => res.json(ok(null)))
app.post('/api/order/:no/complete',  (req, res) => res.json(ok(null)))
app.post('/api/order/:no/cancel',    (req, res) => res.json(ok(null)))

// ─── 统计 ─────────────────────────────────────────────────
app.get('/api/statistics/overview', (req, res) => res.json(ok({
  todayOrders: 12, todaySales: 4860.50, totalProducts: 16, totalUsers: 6,
  lowStockList: [
    { id:11, name:'泰普尔记忆枕头',     stock:3, stockWarning:3 },
    { id:12, name:'睡眠博士护颈枕',     stock:4, stockWarning:5 },
    { id:16, name:'小米空气净化器4Pro', stock:40, stockWarning:3 },
  ]
})))
app.get('/api/statistics/sales-trend', (req, res) => {
  const dates  = ['03-13','03-14','03-15','03-16','03-17','03-18','03-19']
  const sales  = [2100, 3200, 1800, 4500, 3860, 5200, 3100]
  const orders = [8, 12, 7, 18, 12, 20, 12]
  res.json(ok({ dates, sales, orders }))
})
app.get('/api/statistics/hot-products', (req, res) => res.json(ok([
  { id:5,  name:'欧姆龙电子血压计U10',  salesCount:312, revenue:92976 },
  { id:8,  name:'佳禾颈椎牵引器',       salesCount:234, revenue:13572 },
  { id:3,  name:'SKG颈椎按摩仪K5',      salesCount:203, revenue:60697 },
  { id:9,  name:'华佗牌真空拔罐器24罐',  salesCount:178, revenue:12282 },
  { id:1,  name:'南极人艾灸贴30片装',    salesCount:156, revenue:6224  },
])))
app.get('/api/statistics/order-status', (req, res) => res.json(ok([
  { name:'待支付', value:8  },
  { name:'已支付', value:15 },
  { name:'已发货', value:23 },
  { name:'已完成', value:86 },
  { name:'已取消', value:12 },
])))
app.get('/api/statistics/category-ratio', (req, res) => res.json(ok([
  { name:'理疗器械类', value:60697 },
  { name:'健康监测类', value:45270 },
  { name:'运动保健类', value:24908 },
  { name:'外用贴剂类', value:15980 },
  { name:'康复辅助类', value:13572 },
  { name:'中医保健类', value:12282 },
  { name:'睡眠环境类', value:8350  },
  { name:'消毒防护类', value:5680  },
])))

// ─── 文章（非食用类保健科普） ─────────────────────────────
const articles = [
  { id:1, title:'颈椎按摩仪的正确使用方法',     summary:'颈椎按摩仪已成为上班族缓解颈肩疲劳的热门选择，但不正确的使用方式可能适得其反...', coverImage:'https://picsum.photos/400/250?random=201', status:1, viewCount:458, createdAt:'2026-03-10 09:00:00' },
  { id:2, title:'如何选择适合自己的血压计',       summary:'家用血压计是高血压患者日常监测的必备工具，选对血压计才能获得准确的测量结果...', coverImage:'https://picsum.photos/400/250?random=202', status:1, viewCount:312, createdAt:'2026-03-12 14:30:00' },
  { id:3, title:'艾灸贴的保健原理与使用注意事项', summary:'艾灸贴结合了传统艾灸和现代贴敷技术，使用方便但需注意正确方法...', coverImage:'https://picsum.photos/400/250?random=203', status:1, viewCount:236, createdAt:'2026-03-14 11:20:00' },
  { id:4, title:'上班族颈椎保养指南',             summary:'长期伏案工作导致的颈椎问题已成为职业病之首。日常保养远比治疗重要...', coverImage:'https://picsum.photos/400/250?random=204', status:1, viewCount:189, createdAt:'2026-03-15 16:00:00' },
  { id:5, title:'运动损伤后的正确护理方式',       summary:'运动损伤处理不当可能加重伤情。掌握RICE原则和正确使用护具是关键...', coverImage:'https://picsum.photos/400/250?random=205', status:1, viewCount:175, createdAt:'2026-03-16 10:30:00' },
  { id:6, title:'改善睡眠质量的科学方法',         summary:'失眠已成为现代人的普遍困扰，合适的睡眠环境和保健用品可以有效改善睡眠质量...', coverImage:'https://picsum.photos/400/250?random=206', status:1, viewCount:134, createdAt:'2026-03-17 08:45:00' },
]
app.get('/api/article/page',   (req, res) => res.json(page(articles, 6)))
app.get('/api/article/:id',    (req, res) => res.json(ok({...articles[0], content:'颈椎按摩仪是通过脉冲电流、热敷或物理振动来缓解颈部肌肉紧张的保健器械。\n\n【适用人群】\n1. 长期伏案工作的上班族\n2. 经常低头看手机的人群\n3. 颈部肌肉僵硬酸痛者\n\n【正确使用方法】\n1. 每次使用15-20分钟，不宜超过30分钟\n2. 使用前在颈部涂抹少量水或导电凝胶\n3. 从低档位开始，逐渐增加到舒适力度\n4. 贴片应紧贴皮肤，避免悬空\n\n【使用禁忌】\n- 皮肤破损处不可使用\n- 心脏起搏器佩戴者禁用\n- 孕妇颈部禁用\n- 急性颈椎损伤期不可使用\n- 饭后30分钟内不宜使用' })))
app.post('/api/article',          (req, res) => res.json(ok(null)))
app.put('/api/article',           (req, res) => res.json(ok(null)))
app.delete('/api/article/:id',    (req, res) => res.json(ok(null)))
app.put('/api/article/:id/publish',(req, res) => res.json(ok(null)))

// ─── 文件上传（mock） ────────────────────────────────────
app.post('/api/file/upload', (req, res) => res.json(ok({ url: 'https://picsum.photos/200/200?random=99', name: 'test.png' })))

app.listen(8080, () => console.log('Mock API running on http://localhost:8080'))
