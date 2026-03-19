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
  { id:4, username:'user02', realName:'王五',       phone:'13833333333', role:2, status:1, createdAt:'2026-02-15 14:20:00' },
  { id:5, username:'user03', realName:'赵六',       phone:'13844444444', role:2, status:0, createdAt:'2026-03-01 09:10:00' },
], 5)))
app.put('/api/user/:id/status', (req, res) => res.json(ok(null)))
app.delete('/api/user/:id',     (req, res) => res.json(ok(null)))
app.put('/api/user/update',     (req, res) => res.json(ok(null)))

// ─── 分类 ─────────────────────────────────────────────────
const categories = [
  { id:1, name:'维生素与矿物质', parentId:0, sort:1, status:1, children:[
    { id:6,  name:'维生素C', parentId:1, sort:1, status:1, children:[] },
    { id:7,  name:'维生素D', parentId:1, sort:2, status:1, children:[] },
    { id:8,  name:'钙镁锌',  parentId:1, sort:3, status:1, children:[] },
  ]},
  { id:2, name:'中药保健品', parentId:0, sort:2, status:1, children:[
    { id:9,  name:'人参制品', parentId:2, sort:1, status:1, children:[] },
    { id:10, name:'枸杞制品', parentId:2, sort:2, status:1, children:[] },
  ]},
  { id:3, name:'蛋白质与营养品', parentId:0, sort:3, status:1, children:[
    { id:11, name:'乳清蛋白', parentId:3, sort:1, status:1, children:[] },
    { id:12, name:'胶原蛋白', parentId:3, sort:2, status:1, children:[] },
  ]},
  { id:4, name:'养生茶饮', parentId:0, sort:4, status:1, children:[
    { id:13, name:'花草茶',   parentId:4, sort:1, status:1, children:[] },
    { id:14, name:'养生茶包', parentId:4, sort:2, status:1, children:[] },
  ]},
  { id:5, name:'理疗器械', parentId:0, sort:5, status:1, children:[
    { id:15, name:'按摩器', parentId:5, sort:1, status:1, children:[] },
    { id:16, name:'血压计', parentId:5, sort:2, status:1, children:[] },
  ]},
]
app.get('/api/category/tree', (req, res) => res.json(ok(categories)))
app.get('/api/category/list', (req, res) => res.json(ok(categories)))
app.post('/api/category',     (req, res) => res.json(ok(null)))
app.put('/api/category',      (req, res) => res.json(ok(null)))
app.delete('/api/category/:id',(req, res) => res.json(ok(null)))

// ─── 商品 ─────────────────────────────────────────────────
const products = [
  { id:1,  categoryId:6,  categoryName:'维生素C', name:'汤臣倍健维生素C咀嚼片100片', price:39.90, originalPrice:59.00, stock:200, stockWarning:20, salesCount:156, status:1, imageUrl:'https://picsum.photos/200/200?random=1', description:'补充维生素C，增强免疫力' },
  { id:2,  categoryId:7,  categoryName:'维生素D', name:'星鲨维生素D软胶囊60粒',     price:25.00, originalPrice:35.00, stock:150, stockWarning:15, salesCount:89,  status:1, imageUrl:'https://picsum.photos/200/200?random=2', description:'促进钙吸收，骨骼健康' },
  { id:3,  categoryId:8,  categoryName:'钙镁锌',  name:'汤臣倍健钙镁锌片60片',     price:68.00, originalPrice:88.00, stock:100, stockWarning:10, salesCount:203, status:1, imageUrl:'https://picsum.photos/200/200?random=3', description:'补钙补锌，促进健康' },
  { id:4,  categoryId:9,  categoryName:'人参制品', name:'同仁堂红参片100g',         price:198.00,originalPrice:258.00,stock:80,  stockWarning:8,  salesCount:67,  status:1, imageUrl:'https://picsum.photos/200/200?random=4', description:'精选长白山红参，补气养血' },
  { id:5,  categoryId:10, categoryName:'枸杞制品', name:'枸杞原浆30袋装',           price:128.00,originalPrice:168.00,stock:120, stockWarning:12, salesCount:145, status:1, imageUrl:'https://picsum.photos/200/200?random=5', description:'新疆枸杞鲜榨原浆，养肝明目' },
  { id:6,  categoryId:11, categoryName:'乳清蛋白', name:'Myprotein乳清蛋白粉1kg',   price:258.00,originalPrice:318.00,stock:60,  stockWarning:5,  salesCount:312, status:1, imageUrl:'https://picsum.photos/200/200?random=6', description:'高纯度乳清蛋白，运动后补充' },
  { id:7,  categoryId:13, categoryName:'花草茶',   name:'玫瑰花草茶100g',           price:45.00, originalPrice:58.00, stock:200, stockWarning:20, salesCount:89,  status:1, imageUrl:'https://picsum.photos/200/200?random=7', description:'云南玫瑰花茶，美容养颜' },
  { id:8,  categoryId:14, categoryName:'养生茶包', name:'菊花枸杞养生茶20包',       price:38.00, originalPrice:48.00, stock:180, stockWarning:15, salesCount:234, status:1, imageUrl:'https://picsum.photos/200/200?random=8', description:'清肝明目，适合长期用眼人群' },
  { id:9,  categoryId:15, categoryName:'按摩器',   name:'颈椎按摩仪',               price:299.00,originalPrice:399.00,stock:3,   stockWarning:3,  salesCount:56,  status:1, imageUrl:'https://picsum.photos/200/200?random=9', description:'热敷+震动，缓解颈肩疲劳' },
  { id:10, categoryId:16, categoryName:'血压计',   name:'欧姆龙电子血压计',         price:298.00,originalPrice:368.00,stock:4,   stockWarning:5,  salesCount:78,  status:1, imageUrl:'https://picsum.photos/200/200?random=10',description:'家用医用级，精准测量' },
]
app.get('/api/product/page',   (req, res) => res.json(page(products, 10)))
app.get('/api/product/:id',    (req, res) => res.json(ok(products.find(p=>p.id==req.params.id)||products[0])))
app.post('/api/product',       (req, res) => res.json(ok(null)))
app.put('/api/product',        (req, res) => res.json(ok(null)))
app.delete('/api/product/:id', (req, res) => res.json(ok(null)))
app.put('/api/product/:id/status',   (req, res) => res.json(ok(null)))
app.post('/api/product/stock/adjust',(req, res) => res.json(ok(null)))
app.get('/api/product/stock/log',    (req, res) => res.json(page([
  { id:1, productName:'汤臣倍健维生素C', type:2, changeQuantity:-2, beforeStock:202, afterStock:200, orderNo:'HC20260318001', createdAt:'2026-03-18 10:20:00', remark:'订单出库' },
  { id:2, productName:'颈椎按摩仪',     type:1, changeQuantity:5,  beforeStock:0,   afterStock:5,   createdAt:'2026-03-17 14:30:00', remark:'入库补货' },
  { id:3, productName:'枸杞原浆',       type:2, changeQuantity:-1, beforeStock:121, afterStock:120, orderNo:'HC20260317002', createdAt:'2026-03-17 09:10:00', remark:'订单出库' },
])))

// ─── 购物车 ────────────────────────────────────────────────
app.get('/api/cart/list', (req, res) => res.json(ok([
  { id:1, userId:3, productId:1, productName:'汤臣倍健维生素C咀嚼片100片', price:39.90, productImage:'https://picsum.photos/200/200?random=1', stock:200, quantity:2 },
  { id:2, userId:3, productId:8, productName:'菊花枸杞养生茶20包',         price:38.00, productImage:'https://picsum.photos/200/200?random=8', stock:180, quantity:1 },
])))
app.post('/api/cart/add',    (req, res) => res.json(ok(null)))
app.put('/api/cart/update',  (req, res) => res.json(ok(null)))
app.delete('/api/cart/:id',  (req, res) => res.json(ok(null)))
app.delete('/api/cart/clear',(req, res) => res.json(ok(null)))

// ─── 订单 ─────────────────────────────────────────────────
const orders = [
  { id:1, orderNo:'HC20260318143201234', userId:3, username:'user01', realName:'李四', totalAmount:117.80, payAmount:117.80, status:3, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-18 14:32:00', payTime:'2026-03-18 14:32:30',
    items:[
      { id:1, productName:'汤臣倍健维生素C咀嚼片100片', productImage:'https://picsum.photos/60/60?random=1', price:39.90, quantity:2, totalPrice:79.80 },
      { id:2, productName:'菊花枸杞养生茶20包',         productImage:'https://picsum.photos/60/60?random=8', price:38.00, quantity:1, totalPrice:38.00 },
    ]
  },
  { id:2, orderNo:'HC20260317092305678', userId:3, username:'user01', realName:'李四', totalAmount:68.00, payAmount:68.00, status:2, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-17 09:23:00', payTime:'2026-03-17 09:23:45',
    items:[{ id:3, productName:'汤臣倍健钙镁锌片60片', productImage:'https://picsum.photos/60/60?random=3', price:68.00, quantity:1, totalPrice:68.00 }]
  },
  { id:3, orderNo:'HC20260315161109012', userId:4, username:'user02', realName:'王五', totalAmount:258.00,payAmount:258.00,status:1, receiverName:'王五', receiverPhone:'13833333333', receiverAddress:'上海市浦东新区张江高科技园区', createdAt:'2026-03-15 16:11:00', payTime:'2026-03-15 16:12:00',
    items:[{ id:4, productName:'Myprotein乳清蛋白粉1kg', productImage:'https://picsum.photos/60/60?random=6', price:258.00, quantity:1, totalPrice:258.00 }]
  },
  { id:4, orderNo:'HC20260310103207654', userId:3, username:'user01', realName:'李四', totalAmount:45.00, payAmount:45.00, status:0, receiverName:'李四', receiverPhone:'13822222222', receiverAddress:'北京市朝阳区望京街道1号楼', createdAt:'2026-03-10 10:32:00',
    items:[{ id:5, productName:'玫瑰花草茶100g', productImage:'https://picsum.photos/60/60?random=7', price:45.00, quantity:1, totalPrice:45.00 }]
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
  todayOrders: 12, todaySales: 3860.50, totalProducts: 210, totalUsers: 1268,
  lowStockList: [
    { id:9,  name:'颈椎按摩仪',   stock:3, stockWarning:3  },
    { id:10, name:'欧姆龙电子血压计', stock:4, stockWarning:5 },
  ]
})))
app.get('/api/statistics/sales-trend', (req, res) => {
  const dates  = ['03-13','03-14','03-15','03-16','03-17','03-18','03-19']
  const sales  = [2100, 3200, 1800, 4500, 3860, 5200, 3100]
  const orders = [8, 12, 7, 18, 12, 20, 12]
  res.json(ok({ dates, sales, orders }))
})
app.get('/api/statistics/hot-products', (req, res) => res.json(ok([
  { id:6, name:'Myprotein乳清蛋白粉1kg',   salesCount:312, revenue:80496 },
  { id:8, name:'菊花枸杞养生茶20包',       salesCount:234, revenue:8892  },
  { id:3, name:'汤臣倍健钙镁锌片60片',     salesCount:203, revenue:13804 },
  { id:1, name:'汤臣倍健维生素C咀嚼片100片',salesCount:156, revenue:6224  },
  { id:5, name:'枸杞原浆30袋装',           salesCount:145, revenue:18560 },
])))
app.get('/api/statistics/order-status', (req, res) => res.json(ok([
  { name:'待支付', value:8  },
  { name:'已支付', value:15 },
  { name:'已发货', value:23 },
  { name:'已完成', value:86 },
  { name:'已取消', value:12 },
])))
app.get('/api/statistics/category-ratio', (req, res) => res.json(ok([
  { name:'乳清蛋白', value:80496 },
  { name:'枸杞制品', value:18560 },
  { name:'钙镁锌',   value:13804 },
  { name:'养生茶包', value:8892  },
  { name:'维生素C',  value:6224  },
  { name:'人参制品', value:4752  },
  { name:'血压计',   value:3920  },
  { name:'按摩器',   value:2394  },
])))

// ─── 文章 ─────────────────────────────────────────────────
const articles = [
  { id:1, title:'维生素C对免疫力的重要作用', summary:'维生素C是人体必需的水溶性维生素，对于增强免疫力、促进铁的吸收、保护细胞免受氧化损伤具有重要意义...', coverImage:'https://picsum.photos/400/250?random=11', status:1, viewCount:1256, createdAt:'2026-03-10 09:00:00' },
  { id:2, title:'枸杞的养生功效与食用方法',   summary:'枸杞作为传统中医常用药材，含有丰富的多糖、类胡萝卜素等活性成分，具有明目、护肝、抗疲劳等多种保健功效...', coverImage:'https://picsum.photos/400/250?random=12', status:1, viewCount:892,  createdAt:'2026-03-12 14:30:00' },
  { id:3, title:'如何科学补充蛋白质',         summary:'蛋白质是人体重要的营养素，参与肌肉合成、免疫调节、酶和激素的合成等众多生理过程。合理补充蛋白质对健康至关重要...', coverImage:'https://picsum.photos/400/250?random=13', status:1, viewCount:634,  createdAt:'2026-03-14 11:20:00' },
  { id:4, title:'中老年人补钙指南',           summary:'随着年龄增长，骨密度逐渐下降，适当补充钙质和维生素D，配合适量运动，是预防骨质疏松的有效方法...', coverImage:'https://picsum.photos/400/250?random=14', status:1, viewCount:445,  createdAt:'2026-03-15 16:00:00' },
  { id:5, title:'花草茶的健康饮用指南',       summary:'花草茶富含天然植物活性成分，具有舒缓压力、美容养颜等功效。了解不同花草茶的特性，才能正确饮用发挥功效...', coverImage:'https://picsum.photos/400/250?random=15', status:1, viewCount:378,  createdAt:'2026-03-16 10:30:00' },
  { id:6, title:'运动后如何正确恢复体能',     summary:'科学的运动后恢复方案，包括补充蛋白质、碳水化合物以及适当的拉伸休息，可以有效减少肌肉酸痛、加快恢复速度...', coverImage:'https://picsum.photos/400/250?random=16', status:1, viewCount:523,  createdAt:'2026-03-17 08:45:00' },
]
app.get('/api/article/page',   (req, res) => res.json(page(articles, 6)))
app.get('/api/article/:id',    (req, res) => res.json(ok({...articles[0], content:'维生素C（抗坏血酸）是一种重要的水溶性维生素，人体自身无法合成，必须从食物或补充剂中获取。\n\n【主要功效】\n1. 增强免疫力：维生素C能促进白细胞的产生和功能，帮助身体抵抗细菌和病毒感染。\n2. 抗氧化作用：作为强效抗氧化剂，维生素C能中和体内自由基，减少氧化应激，保护细胞免受损伤。\n3. 促进铁吸收：维生素C能将三价铁还原为二价铁，显著提高非血红素铁的吸收率。\n4. 胶原蛋白合成：维生素C是胶原蛋白合成的必需辅酶，有助于皮肤、骨骼和伤口愈合。\n\n【推荐摄入量】\n成人每日推荐摄入量为100mg，上限为2000mg。过量摄入可能导致腹泻、肾结石等副作用。\n\n【食物来源】\n新鲜蔬菜水果是维生素C的最佳来源，如猕猴桃、柑橘、草莓、青椒、菠菜等。' })))
app.post('/api/article',          (req, res) => res.json(ok(null)))
app.put('/api/article',           (req, res) => res.json(ok(null)))
app.delete('/api/article/:id',    (req, res) => res.json(ok(null)))
app.put('/api/article/:id/publish',(req, res) => res.json(ok(null)))

// ─── 文件上传（mock） ────────────────────────────────────
app.post('/api/file/upload', (req, res) => res.json(ok({ url: 'https://picsum.photos/200/200?random=99', name: 'test.png' })))

app.listen(8080, () => console.log('Mock API running on http://localhost:8080'))
