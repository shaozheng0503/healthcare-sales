const puppeteer = require('puppeteer')
const path      = require('path')
const fs        = require('fs')

const OUT = path.join(__dirname, '..', 'screenshots')
if (!fs.existsSync(OUT)) fs.mkdirSync(OUT, { recursive: true })

const adminInfo = { token: 'mock-jwt-token-2026', userInfo: { id:1, username:'admin', realName:'系统管理员', role:0, status:1 } }
const consumerInfo = { token: 'mock-jwt-token-2026', userInfo: { id:3, username:'user01', realName:'李四', role:2, status:1 } }

// 购物车数据（结算页需要）
const checkoutItems = JSON.stringify([
  { id:1, productId:1, productName:'汤臣倍健维生素C咀嚼片100片', price:39.90, productImage:'https://picsum.photos/200/200?random=1', stock:200, quantity:2 },
  { id:2, productId:8, productName:'菊花枸杞养生茶20包',         price:38.00, productImage:'https://picsum.photos/200/200?random=8', stock:180, quantity:1 },
])

async function setLogin(page, info) {
  await page.evaluate((t, u) => {
    localStorage.setItem('token', t)
    localStorage.setItem('userInfo', u)
  }, info.token, JSON.stringify(info.userInfo))
}

async function shot(page, name, url, { role = 'admin', wait = 2000, before } = {}) {
  const info = role === 'consumer' ? consumerInfo : adminInfo
  await setLogin(page, info)
  if (before) await before(page)
  await page.goto('http://localhost:3000' + url, { waitUntil: 'networkidle0', timeout: 20000 })
  await new Promise(r => setTimeout(r, wait))
  await page.screenshot({ path: path.join(OUT, name + '.png'), fullPage: false })
  console.log('  ✅', name)
}

;(async () => {
  console.log('🚀 开始截图...\n')

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  })
  const page = await browser.newPage()
  await page.setViewport({ width: 1440, height: 900 })

  // ─── 公共页面（未登录） ───
  console.log('📌 登录/注册')
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle0' })
  await new Promise(r => setTimeout(r, 1500))
  await page.screenshot({ path: path.join(OUT, '01_login.png') })
  console.log('  ✅ 01_login')

  await page.goto('http://localhost:3000/register', { waitUntil: 'networkidle0' })
  await new Promise(r => setTimeout(r, 1500))
  await page.screenshot({ path: path.join(OUT, '02_register.png') })
  console.log('  ✅ 02_register')

  // ─── 消费者前台 ───
  console.log('\n📌 消费者前台')
  await shot(page, '03_home',           '/',               { role:'consumer' })
  await shot(page, '04_products',       '/products',       { role:'consumer' })
  await shot(page, '05_product_detail', '/product/1',      { role:'consumer' })
  await shot(page, '06_cart',           '/cart',           { role:'consumer' })
  await shot(page, '07_checkout',       '/checkout',       { role:'consumer', before: async (p) => {
    await p.evaluate(data => sessionStorage.setItem('checkoutItems', data), checkoutItems)
  }})
  await shot(page, '08_orders',         '/orders',         { role:'consumer' })
  await shot(page, '09_articles',       '/articles',       { role:'consumer' })
  await shot(page, '10_article_detail', '/article/1',      { role:'consumer' })
  await shot(page, '11_profile',        '/profile',        { role:'consumer' })

  // ─── 管理后台 ───
  console.log('\n📌 管理后台')
  await shot(page, '12_dashboard',     '/admin/dashboard',  { wait: 3000 })  // ECharts 需要更长渲染时间
  await shot(page, '13_user_manage',   '/admin/user',       {})
  await shot(page, '14_category',      '/admin/category',   {})
  await shot(page, '15_product',       '/admin/product',    {})
  await shot(page, '16_stock',         '/admin/stock',      {})
  await shot(page, '17_order_manage',  '/admin/order',      {})
  await shot(page, '18_statistics',    '/admin/statistics',  { wait: 3000 })
  await shot(page, '19_article_admin', '/admin/article',    {})

  await browser.close()
  console.log('\n🎉 全部 19 张截图完成！保存在 screenshots/ 目录')
})().catch(e => { console.error('❌ 截图失败:', e.message); process.exit(1) })
