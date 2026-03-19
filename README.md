# Healthcare Sales Management System

# 日常保健用品销售管理系统

<p>
  <img src="https://img.shields.io/badge/Java-11-blue" />
  <img src="https://img.shields.io/badge/Spring%20Boot-2.7.18-green" />
  <img src="https://img.shields.io/badge/Vue-3.3-brightgreen" />
  <img src="https://img.shields.io/badge/Element%20Plus-2.13-409eff" />
  <img src="https://img.shields.io/badge/MySQL-8.0-orange" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
</p>

面向中小型保健用品销售企业的全栈 Web 管理系统，覆盖 **管理员、商家、消费者** 三类角色，实现商品管理、库存管理、订单处理、销售统计和保健科普等核心功能。

---

## 系统预览

### 登录页

左右分栏设计，左侧品牌展示区，右侧登录表单，一键快捷填充测试账号。

![登录页](screenshots/01_login.png)

### 消费者首页

Banner 轮播 + 分类导航 + 热销商品 + 健康科普推荐，绿色健康主题配色。

![首页](screenshots/03_home.png)

### 商品列表与详情

左侧二级分类树 + 右侧商品卡片网格（含折扣标签、一键加购按钮），支持搜索、排序。

<table>
  <tr>
    <td><img src="screenshots/04_products.png" alt="商品列表" /></td>
    <td><img src="screenshots/05_product_detail.png" alt="商品详情" /></td>
  </tr>
</table>

### 购物车与结算

重新设计的购物车（订单摘要面板）与结算页面（支付方式选择卡片）。

<table>
  <tr>
    <td><img src="screenshots/06_cart.png" alt="购物车" /></td>
    <td><img src="screenshots/07_checkout.png" alt="结算" /></td>
  </tr>
</table>

### 我的订单

Tab 状态筛选，订单卡片展示商品明细，支持支付、取消、确认收货操作。

![我的订单](screenshots/08_orders.png)

### 科普文章

文章卡片列表（封面 hover 放大效果）+ 热门排行（前3名橙色渐变徽章）。

<table>
  <tr>
    <td><img src="screenshots/09_articles.png" alt="科普列表" /></td>
    <td><img src="screenshots/10_article_detail.png" alt="文章详情" /></td>
  </tr>
</table>

### 个人中心

左侧用户卡片（渐变头像圆环）+ 右侧信息编辑/密码修改（切换动画）。

![个人中心](screenshots/11_profile.png)

### 管理后台 — 数据看板

四色渐变统计卡片 + ECharts 销售趋势图 + 订单状态饼图 + 热销排行 + 库存预警。

![数据看板](screenshots/12_dashboard.png)

### 管理后台 — 功能页面

<table>
  <tr>
    <td><img src="screenshots/13_user_manage.png" alt="用户管理" /><br/><b>用户管理</b></td>
    <td><img src="screenshots/14_category.png" alt="分类管理" /><br/><b>分类管理</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/15_product.png" alt="商品管理" /><br/><b>商品管理</b></td>
    <td><img src="screenshots/16_stock.png" alt="库存管理" /><br/><b>库存管理</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/17_order_manage.png" alt="订单管理" /><br/><b>订单管理</b></td>
    <td><img src="screenshots/18_statistics.png" alt="销售统计" /><br/><b>销售统计</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/19_article_admin.png" alt="科普管理" /><br/><b>科普管理</b></td>
    <td><img src="screenshots/02_register.png" alt="注册页" /><br/><b>注册页</b></td>
  </tr>
</table>

---

## 技术栈

### 后端

| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 11 | 运行环境 |
| Spring Boot | 2.7.18 | Web 框架，RESTful API |
| MyBatis-Plus | 3.5.4 | ORM 框架，简化 CRUD + 分页 |
| MySQL | 8.0 | 关系型数据库 |
| Druid | 1.2.20 | 数据库连接池 |
| JWT (jjwt) | 0.11.5 | 无状态认证 |
| BCrypt | Spring 内置 | 密码加密 |

### 前端

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue.js | 3.3 | 响应式前端框架 |
| Element Plus | 2.13 | UI 组件库 |
| Pinia | 2.1 | 状态管理 |
| Vue Router | 4.2 | 路由管理 + 权限守卫 |
| Axios | 1.5 | HTTP 客户端 + 拦截器 |
| ECharts | 5.4 | 数据可视化图表 |
| Vite | 4.4 | 构建工具 |

---

## 项目结构

```
healthcare-sales/
├── database/
│   └── healthcare_sales.sql          # 完整建库脚本（8张表 + 初始数据）
│
├── backend/                          # Spring Boot 后端（38个Java文件）
│   ├── pom.xml                       # Maven 依赖
│   ├── mvnw / mvnw.cmd              # Maven Wrapper
│   └── src/main/
│       ├── java/com/healthcare/sales/
│       │   ├── HealthcareSalesApplication.java
│       │   ├── controller/           # 8个REST控制器（44个API端点）
│       │   ├── service/impl/         # 4个业务服务
│       │   ├── mapper/               # 8个MyBatis接口
│       │   ├── entity/               # 8个实体类
│       │   ├── interceptor/          # JWT认证拦截器
│       │   ├── config/               # Web/MyBatis/Bean配置
│       │   ├── common/               # 统一响应Result + 全局异常处理
│       │   └── utils/                # JWT工具 + ThreadLocal用户上下文
│       └── resources/
│           ├── application.yml       # 应用配置
│           └── mapper/*.xml          # MyBatis XML映射
│
├── frontend/                         # Vue 3 前端（24个组件 + 5个JS）
│   ├── package.json
│   ├── vite.config.js                # Vite配置 + API代理
│   └── src/
│       ├── main.js                   # 入口（全局注册图标）
│       ├── App.vue                   # 根组件（设计系统CSS变量 + 路由动画）
│       ├── api/index.js              # 42个API接口定义
│       ├── router/index.js           # 19个路由 + 权限守卫
│       ├── store/user.js             # Pinia用户状态
│       ├── utils/request.js          # Axios封装（Token注入 + 错误处理）
│       ├── components/               # 公共组件（ProductCard, LeafIcon）
│       └── views/
│           ├── common/               # 登录(左右分栏) + 注册
│           ├── consumer/             # 消费者前台9个页面
│           └── admin/                # 管理后台9个页面
│
├── screenshots/                      # 19张系统截图
├── docs/                             # 测试用例 + 论文素材 + 部署说明
├── mock-server/                      # Mock API服务器（开发/截图用）
├── .gitignore
└── README.md
```

---

## 快速开始

### 环境要求

- **Java** 11+ （[下载](https://adoptium.net/)）
- **MySQL** 8.0+ （[下载](https://dev.mysql.com/downloads/)）
- **Node.js** 16+ （[下载](https://nodejs.org/)）

### 1. 克隆项目

```bash
git clone https://github.com/your-username/healthcare-sales.git
cd healthcare-sales
```

### 2. 初始化数据库

```bash
mysql -u root -p < database/healthcare_sales.sql
```

> 创建 `healthcare_sales` 数据库，包含 8 张表 + 完整初始数据（6个用户、16个分类、12个商品、8个订单、6篇文章）

### 3. 修改数据库密码

```bash
# 编辑 backend/src/main/resources/application.yml 第14行
password: root   # ← 改成你的MySQL密码
```

### 4. 启动后端

```bash
cd backend

# Linux / macOS
./mvnw spring-boot:run

# Windows
mvnw.cmd spring-boot:run

# 或用 IDEA 直接运行 HealthcareSalesApplication.java
```

> 首次启动会自动下载 Maven 和依赖。看到 `Started HealthcareSalesApplication` 表示成功。

### 5. 启动前端

```bash
cd frontend
npm install    # 首次需要
npm run dev
```

### 6. 访问系统

| 入口 | 地址 |
|------|------|
| 消费者前台 | http://localhost:3000 |
| 管理后台 | http://localhost:3000/admin |

### 测试账号

| 账号 | 密码 | 角色 | 可访问功能 |
|------|------|------|-----------|
| `admin` | `admin123` | 管理员 | 全部功能（含用户管理） |
| `shop01` | `admin123` | 商家 | 商品/库存/订单/统计/文章管理 |
| `user01` | `admin123` | 消费者 | 浏览/购物/下单/个人中心 |
| `user02` ~ `user04` | `admin123` | 消费者 | 同上 |

---

## 功能清单

### 消费者前台（9个页面）

| 模块 | 功能 |
|------|------|
| 首页 | Banner 轮播、分类导航、热销商品、科普推荐 |
| 商品浏览 | 分类筛选、关键词搜索、价格/销量排序、商品卡片（折扣标签） |
| 商品详情 | 大图展示、价格对比、库存状态、加购/购买按钮 |
| 购物车 | 多选、数量调整、实时合计、去结算 |
| 下单结算 | 收货信息表单、商品清单、模拟支付 |
| 我的订单 | 5种状态筛选、支付/取消/确认收货 |
| 科普文章 | 文章列表、热门排行、详情阅读（浏览量统计） |
| 个人中心 | 修改个人信息、修改密码（验证旧密码） |

### 管理后台（9个页面）

| 模块 | 功能 |
|------|------|
| 数据看板 | 今日 KPI（4色渐变卡片）、销售趋势图、订单饼图、热销 Top5、库存预警 |
| 用户管理 | 列表筛选、启用/禁用、删除（仅管理员可见） |
| 分类管理 | 二级分类树、增删改查 |
| 商品管理 | CRUD、上下架、图片上传、分类级联选择、库存调整 |
| 库存管理 | 预警列表、入库操作、变动日志追溯（按商品名/类型筛选） |
| 订单管理 | 订单号/状态/日期筛选、详情弹窗、发货/取消操作 |
| 销售统计 | 趋势折线图、分类占比饼图、热销柱状图（支持自定义日期范围） |
| 科普管理 | 文章 CRUD、发布/下架、封面上传 |

---

## 核心流程

### 购物流程

```
浏览商品 → 查看详情 → 加入购物车 → 选择结算
→ 填写收货信息 → 提交订单（自动扣库存 + 清购物车）
→ 模拟支付 → 等待发货 → 确认收货
```

### 订单状态机

```
待支付(0) ──支付──→ 已支付(1) ──发货──→ 已发货(2) ──确认收货──→ 已完成(3)
    │                    │
    └──取消──→ 已取消(4) ←──取消（退回库存+记录日志）
```

### 库存管理

```
手动入库     → 库存增加 → 记录日志（type=1）
消费者下单   → 库存扣减 → 记录日志（type=2）  # 乐观锁：UPDATE WHERE stock >= quantity
订单取消     → 库存回滚 → 记录日志（type=4）
库存 ≤ 预警值 → 看板和库存页显示预警
```

---

## API 接口

系统共 **44 个 REST API** 接口：

<details>
<summary><b>用户模块 /api/user （7个）</b></summary>

| 方法 | 路径 | 认证 | 功能 |
|------|------|------|------|
| POST | /user/login | - | 登录（返回JWT + 用户信息） |
| POST | /user/register | - | 注册 |
| GET | /user/info | 登录 | 获取当前用户信息 |
| PUT | /user/update | 登录 | 修改个人信息/密码 |
| GET | /user/list | 管理员 | 用户分页列表 |
| PUT | /user/{id}/status | 管理员 | 启用/禁用 |
| DELETE | /user/{id} | 管理员 | 删除用户 |
</details>

<details>
<summary><b>商品模块 /api/product （8个）</b></summary>

| 方法 | 路径 | 认证 | 功能 |
|------|------|------|------|
| GET | /product/page | - | 商品分页（搜索/分类/排序/预警筛选） |
| GET | /product/{id} | - | 商品详情（含分类名） |
| POST | /product | 商家+ | 新增商品 |
| PUT | /product | 商家+ | 编辑商品 |
| DELETE | /product/{id} | 商家+ | 删除商品 |
| PUT | /product/{id}/status | 商家+ | 上架/下架 |
| POST | /product/stock/adjust | 商家+ | 库存调整 |
| GET | /product/stock/log | 商家+ | 库存日志 |
</details>

<details>
<summary><b>购物车 /api/cart （5个） | 订单 /api/order （8个） | 统计 /api/statistics （5个） | 分类 /api/category （4个） | 文章 /api/article （6个） | 文件 /api/file （1个）</b></summary>

详见源码中各 Controller 文件。
</details>

---

## 数据库设计

### ER 关系

```
user(1) ──→ (N)orders ──→ (N)order_item ──→ (N)product ──→ (1)category
user(1) ──→ (N)cart ──→ (N)product
user(1) ──→ (N)article
product(1) ──→ (N)stock_log
category ──→ category（自关联，二级分类）
```

### 8 张数据表

| 表名 | 说明 | 关键设计 |
|------|------|---------|
| `user` | 用户表 | role(0/1/2) 三角色，BCrypt 密码 |
| `category` | 分类表 | parent_id 自关联实现二级分类树 |
| `product` | 商品表 | stock_warning 预警值，乐观锁扣减 |
| `cart` | 购物车 | user+product 联合唯一索引 |
| `orders` | 订单表 | 5 种状态流转，HC+时间戳订单号 |
| `order_item` | 订单明细 | 商品名/价格快照，防改价影响历史 |
| `stock_log` | 库存日志 | 4 种变动类型，完整审计追溯 |
| `article` | 科普文章 | 草稿/发布/下架，浏览量统计 |

---

## 安全设计

| 机制 | 实现方式 |
|------|---------|
| 身份认证 | JWT 无状态令牌（24h 有效期），全局拦截器校验 |
| 密码安全 | BCrypt 单向哈希，修改密码需验证旧密码 |
| 角色权限 | Controller 层 `checkAdmin()` / `checkBackend()` |
| 防超卖 | 数据库乐观锁 `UPDATE ... WHERE stock >= #{quantity}` |
| 数据隔离 | 购物车更新/删除校验用户归属 |
| 文件安全 | 上传白名单（jpg/png/gif/webp）+ 5MB 限制 |
| 接口保护 | 公开接口白名单放行，其余全局认证 |

---

## 开发文档

| 文档 | 路径 | 内容 |
|------|------|------|
| 功能测试记录 | `docs/功能测试记录.md` | 63 个真实测试用例 + 19 张系统截图，覆盖全部模块 |
| 部署说明 | `docs/部署说明.md` | 详细部署步骤 + 常见问题排查 |
| 测试用例 | `docs/测试用例.md` | 68 个功能测试用例，覆盖 8 大模块 |
| 论文素材 | `docs/论文图表素材.md` | 用例图、ER图、架构图、流程图 |
| 开发进展 | `毕设开发进展文档.md` | 完整开发过程记录 |

---

## 常见问题

<details>
<summary><b>后端启动报数据库连接失败</b></summary>

检查 `application.yml` 中的数据库地址、用户名、密码，确认 MySQL 服务运行中，`healthcare_sales` 数据库已创建。
</details>

<details>
<summary><b>前端页面空白 / 接口 404</b></summary>

确认后端已启动在 8080 端口。Vite 开发服务器通过 proxy 将 `/api` 请求转发到 `http://localhost:8080`。
</details>

<details>
<summary><b>没有安装 Maven</b></summary>

项目包含 Maven Wrapper（`mvnw`），首次运行自动下载 Maven 3.9.6。
</details>

<details>
<summary><b>npm install 或 Maven 下载慢</b></summary>

```bash
# npm 使用国内镜像
npm config set registry https://registry.npmmirror.com

# Maven 使用阿里云镜像（~/.m2/settings.xml）
<mirror>
  <id>aliyun</id>
  <mirrorOf>central</mirrorOf>
  <url>https://maven.aliyun.com/repository/central</url>
</mirror>
```
</details>

<details>
<summary><b>Java 版本不兼容</b></summary>

需要 Java 11+，不支持 Java 8。运行 `java -version` 确认版本。
</details>

---

## License

MIT License
