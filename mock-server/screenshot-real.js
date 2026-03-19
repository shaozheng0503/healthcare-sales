const puppeteer = require('puppeteer')
const path = require('path')

const BASE = 'http://localhost:3000'
const OUT = path.join(__dirname, '..', 'screenshots', 'real')

async function sleep(ms) { return new Promise(r => setTimeout(r, ms)) }

async function run() {
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'], defaultViewport: { width: 1440, height: 900 } })
  const page = await browser.newPage()

  const fs = require('fs')
  if (!fs.existsSync(OUT)) fs.mkdirSync(OUT, { recursive: true })

  async function shot(name, url, opts = {}) {
    try {
      if (url) await page.goto(url, { waitUntil: 'networkidle0', timeout: 15000 })
      if (opts.wait) await sleep(opts.wait)
      await page.screenshot({ path: path.join(OUT, name), fullPage: opts.fullPage || false })
      console.log(`  ✅ ${name}`)
    } catch (e) {
      console.log(`  ❌ ${name}: ${e.message.slice(0, 80)}`)
    }
  }

  // === 1. 登录页 ===
  console.log('\n=== 登录/注册 ===')
  await shot('01_login.png', BASE + '/login', { wait: 1000 })

  // === 2. 管理员登录 ===
  await page.goto(BASE + '/login', { waitUntil: 'networkidle0' })
  await sleep(500)
  // 填写登录表单
  const inputs = await page.$$('input')
  if (inputs.length >= 2) {
    await inputs[0].click({ clickCount: 3 })
    await inputs[0].type('admin')
    await inputs[1].click({ clickCount: 3 })
    await inputs[1].type('admin123')
    await sleep(300)
    await shot('02_login_filled.png')
    // 点击登录按钮
    const btns = await page.$$('button')
    for (const btn of btns) {
      const text = await page.evaluate(el => el.textContent, btn)
      if (text.includes('登') || text.includes('Login')) {
        await btn.click()
        break
      }
    }
    await sleep(2000)
  }

  // === 3. 管理后台 ===
  console.log('\n=== 管理后台 ===')
  await shot('03_dashboard.png', BASE + '/admin/dashboard', { wait: 2000 })
  await shot('04_user_manage.png', BASE + '/admin/user', { wait: 1500 })
  await shot('05_category.png', BASE + '/admin/category', { wait: 1500 })
  await shot('06_product_manage.png', BASE + '/admin/product', { wait: 1500 })
  await shot('07_stock.png', BASE + '/admin/stock', { wait: 1500 })
  await shot('08_order_manage.png', BASE + '/admin/order', { wait: 1500 })
  await shot('09_statistics.png', BASE + '/admin/statistics', { wait: 2000 })
  await shot('10_article_admin.png', BASE + '/admin/article', { wait: 1500 })

  // === 4. 切换消费者 ===
  console.log('\n=== 消费者前台 ===')
  // 先退出登录，再以消费者身份登录
  await page.evaluate(() => { localStorage.clear() })
  await page.goto(BASE + '/login', { waitUntil: 'networkidle0' })
  await sleep(500)
  const inputs2 = await page.$$('input')
  if (inputs2.length >= 2) {
    await inputs2[0].click({ clickCount: 3 })
    await inputs2[0].type('user01')
    await inputs2[1].click({ clickCount: 3 })
    await inputs2[1].type('admin123')
    const btns = await page.$$('button')
    for (const btn of btns) {
      const text = await page.evaluate(el => el.textContent, btn)
      if (text.includes('登') || text.includes('Login')) { await btn.click(); break }
    }
    await sleep(2000)
  }

  await shot('11_home.png', BASE + '/', { wait: 2000 })
  await shot('12_products.png', BASE + '/products', { wait: 2000 })
  await shot('13_product_detail.png', BASE + '/product/3', { wait: 1500 })
  await shot('14_cart.png', BASE + '/cart', { wait: 1500 })
  await shot('15_orders.png', BASE + '/orders', { wait: 1500 })
  await shot('16_articles.png', BASE + '/articles', { wait: 1500 })
  await shot('17_article_detail.png', BASE + '/article/1', { wait: 1500 })
  await shot('18_profile.png', BASE + '/profile', { wait: 1500 })

  // 注册页（无需登录）
  await page.evaluate(() => { localStorage.clear() })
  await shot('19_register.png', BASE + '/register', { wait: 1000 })

  await browser.close()
  console.log('\n截图完成，保存在 screenshots/real/')
}

run().catch(e => { console.error(e); process.exit(1) })
