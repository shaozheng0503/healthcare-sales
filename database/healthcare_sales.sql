-- ============================================================
-- 日常保健用品销售管理系统 数据库设计
-- Java 11.0.15.1 + MySQL 8.0.36
-- ============================================================

CREATE DATABASE IF NOT EXISTS healthcare_sales
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE healthcare_sales;

-- ============================================================
-- 1. 用户表
-- role: 0=管理员  1=商家/员工  2=消费者
-- status: 0=禁用  1=正常
-- ============================================================
CREATE TABLE `user` (
    `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username`    VARCHAR(50)      NOT NULL COMMENT '用户名（登录账号）',
    `password`    VARCHAR(100)     NOT NULL COMMENT '密码（BCrypt加密）',
    `real_name`   VARCHAR(50)               COMMENT '真实姓名',
    `phone`       VARCHAR(20)               COMMENT '手机号',
    `email`       VARCHAR(100)              COMMENT '邮箱',
    `avatar`      VARCHAR(255)              COMMENT '头像URL',
    `role`        TINYINT          NOT NULL DEFAULT 2 COMMENT '角色：0管理员 1商家 2消费者',
    `status`      TINYINT          NOT NULL DEFAULT 1 COMMENT '状态：0禁用 1正常',
    `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_role` (`role`),
    KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================================
-- 2. 商品分类表（支持二级分类）
-- parent_id=0 表示一级分类
-- status: 0=禁用  1=启用
-- ============================================================
CREATE TABLE `category` (
    `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name`        VARCHAR(50)      NOT NULL COMMENT '分类名称',
    `parent_id`   BIGINT UNSIGNED  NOT NULL DEFAULT 0 COMMENT '父分类ID，0为顶级分类',
    `icon`        VARCHAR(255)              COMMENT '分类图标URL',
    `sort`        INT              NOT NULL DEFAULT 0 COMMENT '排序值，越小越靠前',
    `status`      TINYINT          NOT NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- ============================================================
-- 3. 商品表
-- status: 0=下架  1=上架
-- ============================================================
CREATE TABLE `product` (
    `id`            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `category_id`   BIGINT UNSIGNED  NOT NULL COMMENT '分类ID',
    `name`          VARCHAR(100)     NOT NULL COMMENT '商品名称',
    `description`   TEXT                      COMMENT '商品描述',
    `price`         DECIMAL(10, 2)   NOT NULL COMMENT '销售价格',
    `original_price` DECIMAL(10, 2)           COMMENT '原价（划线价）',
    `stock`         INT              NOT NULL DEFAULT 0 COMMENT '库存数量',
    `stock_warning` INT              NOT NULL DEFAULT 10 COMMENT '库存预警值',
    `image_url`     VARCHAR(255)              COMMENT '商品主图URL',
    `images`        TEXT                      COMMENT '商品图片列表（JSON格式）',
    `sales_count`   INT              NOT NULL DEFAULT 0 COMMENT '累计销量',
    `status`        TINYINT          NOT NULL DEFAULT 1 COMMENT '状态：0下架 1上架',
    `created_by`    BIGINT UNSIGNED           COMMENT '创建人ID',
    `created_at`    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_stock` (`stock`),
    KEY `idx_sales_count` (`sales_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- ============================================================
-- 4. 购物车表
-- ============================================================
CREATE TABLE `cart` (
    `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id`     BIGINT UNSIGNED  NOT NULL COMMENT '用户ID',
    `product_id`  BIGINT UNSIGNED  NOT NULL COMMENT '商品ID',
    `quantity`    INT              NOT NULL DEFAULT 1 COMMENT '购买数量',
    `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_product` (`user_id`, `product_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- ============================================================
-- 5. 订单表
-- status: 0=待支付  1=已支付  2=已发货  3=已完成  4=已取消
-- pay_type: 1=余额支付（模拟）  2=支付宝  3=微信
-- ============================================================
CREATE TABLE `orders` (
    `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_no`        VARCHAR(30)      NOT NULL COMMENT '订单编号（唯一）',
    `user_id`         BIGINT UNSIGNED  NOT NULL COMMENT '下单用户ID',
    `total_amount`    DECIMAL(10, 2)   NOT NULL COMMENT '订单总金额',
    `pay_amount`      DECIMAL(10, 2)   NOT NULL COMMENT '实付金额',
    `status`          TINYINT          NOT NULL DEFAULT 0 COMMENT '订单状态：0待支付 1已支付 2已发货 3已完成 4已取消',
    `pay_type`        TINYINT                   COMMENT '支付方式：1模拟 2支付宝 3微信',
    `pay_time`        DATETIME                  COMMENT '支付时间',
    `receiver_name`   VARCHAR(50)      NOT NULL COMMENT '收货人姓名',
    `receiver_phone`  VARCHAR(20)      NOT NULL COMMENT '收货人手机号',
    `receiver_address` VARCHAR(255)    NOT NULL COMMENT '收货地址',
    `remark`          VARCHAR(500)              COMMENT '买家备注',
    `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ============================================================
-- 6. 订单详情表
-- ============================================================
CREATE TABLE `order_item` (
    `id`            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id`      BIGINT UNSIGNED  NOT NULL COMMENT '订单ID',
    `order_no`      VARCHAR(30)      NOT NULL COMMENT '订单编号',
    `product_id`    BIGINT UNSIGNED  NOT NULL COMMENT '商品ID',
    `product_name`  VARCHAR(100)     NOT NULL COMMENT '商品名称（快照）',
    `product_image` VARCHAR(255)              COMMENT '商品图片（快照）',
    `price`         DECIMAL(10, 2)   NOT NULL COMMENT '购买时单价（快照）',
    `quantity`      INT              NOT NULL COMMENT '购买数量',
    `total_price`   DECIMAL(10, 2)   NOT NULL COMMENT '小计金额',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_order_no` (`order_no`),
    KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单详情表';

-- ============================================================
-- 7. 库存变动日志表
-- type: 1=入库  2=出库（订单）  3=手动调整  4=订单取消回滚
-- ============================================================
CREATE TABLE `stock_log` (
    `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `product_id`      BIGINT UNSIGNED  NOT NULL COMMENT '商品ID',
    `product_name`    VARCHAR(100)     NOT NULL COMMENT '商品名称（快照）',
    `type`            TINYINT          NOT NULL COMMENT '变动类型：1入库 2出库 3手动调整 4取消回滚',
    `change_quantity` INT              NOT NULL COMMENT '变动数量（正=增加 负=减少）',
    `before_stock`    INT              NOT NULL COMMENT '变动前库存',
    `after_stock`     INT              NOT NULL COMMENT '变动后库存',
    `order_no`        VARCHAR(30)               COMMENT '关联订单编号',
    `operator_id`     BIGINT UNSIGNED           COMMENT '操作人ID',
    `remark`          VARCHAR(255)              COMMENT '备注',
    `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_product_id` (`product_id`),
    KEY `idx_type` (`type`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存变动日志表';

-- ============================================================
-- 8. 保健科普文章表
-- status: 0=草稿  1=已发布  2=已下架
-- ============================================================
CREATE TABLE `article` (
    `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title`       VARCHAR(200)     NOT NULL COMMENT '文章标题',
    `summary`     VARCHAR(500)              COMMENT '文章摘要',
    `content`     LONGTEXT         NOT NULL COMMENT '文章内容（富文本）',
    `cover_image` VARCHAR(255)              COMMENT '封面图URL',
    `author_id`   BIGINT UNSIGNED  NOT NULL COMMENT '作者ID',
    `status`      TINYINT          NOT NULL DEFAULT 0 COMMENT '状态：0草稿 1已发布 2已下架',
    `view_count`  INT              NOT NULL DEFAULT 0 COMMENT '浏览次数',
    `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`),
    KEY `idx_author_id` (`author_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='保健科普文章表';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 初始账号（密码均为：admin123）
-- BCrypt加密（$2a$ 前缀，Spring Security BCryptPasswordEncoder 原生支持）
INSERT INTO `user` (`username`, `password`, `real_name`, `phone`, `role`, `status`) VALUES
('admin',  '$2a$10$zMAqucwyGr3URyD.WLYaTuxPeI9dPiF9oC/a2DAMFS2cBCptTvySe', '系统管理员', '13800000000', 0, 1),
('shop01', '$2a$10$R9XO2damw5RGgIdsHcXSROPrhYhjVeqfld28SVkrlMkKrBrjAUkv.', '商家张三',   '13811111111', 1, 1),
('user01', '$2a$10$EQ.ZJKIdGXAIqjQASx9McuA2EyuZeupN7EvCN3Scg9J/V0KuDch.u', '李四',       '13822222222', 2, 1);

-- 一级分类
INSERT INTO `category` (`name`, `parent_id`, `sort`) VALUES
('维生素与矿物质', 0, 1),
('中药保健品',     0, 2),
('蛋白质与营养品', 0, 3),
('养生茶饮',       0, 4),
('理疗器械',       0, 5);

-- 二级分类
INSERT INTO `category` (`name`, `parent_id`, `sort`) VALUES
('维生素C',     1, 1),
('维生素D',     1, 2),
('钙镁锌',      1, 3),
('人参制品',    2, 1),
('枸杞制品',    2, 2),
('乳清蛋白',    3, 1),
('胶原蛋白',    3, 2),
('花草茶',      4, 1),
('养生茶包',    4, 2),
('按摩器',      5, 1),
('血压计',      5, 2);

-- 示例商品数据
INSERT INTO `product` (`category_id`, `name`, `description`, `price`, `original_price`, `stock`, `stock_warning`, `sales_count`, `status`, `created_by`) VALUES
(6,  '汤臣倍健维生素C咀嚼片100片',   '补充维生素C，增强免疫力，每片含维生素C 100mg', 39.90,  59.00, 200, 20, 156, 1, 1),
(7,  '星鲨维生素D软胶囊60粒',         '促进钙吸收，骨骼健康，适合中老年人群',         25.00,  35.00, 150, 15, 89,  1, 1),
(8,  '汤臣倍健钙镁锌片60片',          '补钙补锌，促进骨骼和免疫系统健康',             68.00,  88.00, 100, 10, 203, 1, 1),
(9,  '同仁堂红参片100g',              '精选长白山红参，补气养血，提高免疫力',         198.00, 258.00, 80,  8,  67,  1, 1),
(10, '枸杞原浆30袋装',                '新疆枸杞鲜榨原浆，养肝明目，抗氧化',           128.00, 168.00, 120, 12, 145, 1, 1),
(11, 'Myprotein乳清蛋白粉1kg',        '高纯度乳清蛋白，运动后补充，促进肌肉恢复',     258.00, 318.00, 60,  5,  312, 1, 1),
(13, '玫瑰花草茶100g',               '云南玫瑰花茶，美容养颜，舒缓压力',              45.00,  58.00, 200, 20, 89,  1, 1),
(14, '菊花枸杞养生茶20包',            '清肝明目，适合长期使用手机/电脑人群',           38.00,  48.00, 180, 15, 234, 1, 1),
(15, '颈椎按摩仪',                    '热敷+震动按摩，缓解颈肩疲劳，适合上班族',      299.00, 399.00, 30,  3,  56,  1, 1),
(16, '欧姆龙电子血压计',              '上臂式血压计，家用医用级，精准测量',            298.00, 368.00, 45,  5,  78,  1, 1);

-- 补充商品（胶原蛋白、按摩器二级分类下的其他商品）
INSERT INTO `product` (`category_id`, `name`, `description`, `price`, `original_price`, `stock`, `stock_warning`, `sales_count`, `status`, `created_by`) VALUES
(12, 'FANCL胶原蛋白饮30日分',        '日本进口，小分子胶原蛋白，美容抗衰',             188.00, 228.00, 90, 10, 127, 1, 1),
(6,  '养生堂天然维生素C 70片',        '天然维生素C提取，非化学合成，温和不伤胃',         59.00,  79.00, 160, 15, 98, 1, 1);

-- ============================================================
-- 额外消费者账号（密码均为 admin123）
-- ============================================================
INSERT INTO `user` (`username`, `password`, `real_name`, `phone`, `role`, `status`) VALUES
('user02', '$2a$10$EQ.ZJKIdGXAIqjQASx9McuA2EyuZeupN7EvCN3Scg9J/V0KuDch.u', '王芳',   '13833333333', 2, 1),
('user03', '$2a$10$EQ.ZJKIdGXAIqjQASx9McuA2EyuZeupN7EvCN3Scg9J/V0KuDch.u', '陈明',   '13844444444', 2, 1),
('user04', '$2a$10$EQ.ZJKIdGXAIqjQASx9McuA2EyuZeupN7EvCN3Scg9J/V0KuDch.u', '赵丽',   '13855555555', 2, 1);

-- ============================================================
-- 示例订单数据（涵盖5种状态，近7天内）
-- ============================================================

-- 订单1：已完成（3天前下单）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260316120001', 3, 107.90, 107.90, 3, 1, DATE_SUB(NOW(), INTERVAL 3 DAY),
 '李四', '13822222222', '浙江省杭州市西湖区文一路88号', DATE_SUB(NOW(), INTERVAL 3 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(1, 'HC20260316120001', 1, '汤臣倍健维生素C咀嚼片100片', 39.90, 1, 39.90),
(1, 'HC20260316120001', 3, '汤臣倍健钙镁锌片60片', 68.00, 1, 68.00);

-- 订单2：已完成（2天前）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260317090002', 4, 326.00, 326.00, 3, 1, DATE_SUB(NOW(), INTERVAL 2 DAY),
 '王芳', '13833333333', '江苏省南京市鼓楼区中山路100号', DATE_SUB(NOW(), INTERVAL 2 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(2, 'HC20260317090002', 4, '同仁堂红参片100g', 198.00, 1, 198.00),
(2, 'HC20260317090002', 5, '枸杞原浆30袋装', 128.00, 1, 128.00);

-- 订单3：已发货（1天前）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260318140003', 5, 258.00, 258.00, 2, 1, DATE_SUB(NOW(), INTERVAL 1 DAY),
 '陈明', '13844444444', '上海市浦东新区张江高科技园区', DATE_SUB(NOW(), INTERVAL 1 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(3, 'HC20260318140003', 6, 'Myprotein乳清蛋白粉1kg', 258.00, 1, 258.00);

-- 订单4：已支付待发货（今天）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260319100004', 6, 359.00, 359.00, 1, 1, NOW(),
 '赵丽', '13855555555', '广东省深圳市南山区科技园南路', NOW());
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(4, 'HC20260319100004', 8, '菊花枸杞养生茶20包', 38.00, 2, 76.00),
(4, 'HC20260319100004', 6, 'Myprotein乳清蛋白粉1kg', 258.00, 1, 258.00),
(4, 'HC20260319100004', 2, '星鲨维生素D软胶囊60粒', 25.00, 1, 25.00);

-- 订单5：待支付（今天）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260319110005', 3, 597.00, 597.00, 0, 1,
 '李四', '13822222222', '浙江省杭州市余杭区阿里巴巴西溪园区', NOW());
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(5, 'HC20260319110005', 9, '颈椎按摩仪', 299.00, 1, 299.00),
(5, 'HC20260319110005', 10, '欧姆龙电子血压计', 298.00, 1, 298.00);

-- 订单6：已取消（昨天）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260318160006', 4, 79.80, 79.80, 4, 1,
 '王芳', '13833333333', '江苏省南京市鼓楼区中山路100号', DATE_SUB(NOW(), INTERVAL 1 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(6, 'HC20260318160006', 1, '汤臣倍健维生素C咀嚼片100片', 39.90, 2, 79.80);

-- 订单7：已完成（5天前）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260314080007', 3, 173.00, 173.00, 3, 1, DATE_SUB(NOW(), INTERVAL 5 DAY),
 '李四', '13822222222', '浙江省杭州市西湖区文一路88号', DATE_SUB(NOW(), INTERVAL 5 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(7, 'HC20260314080007', 5, '枸杞原浆30袋装', 128.00, 1, 128.00),
(7, 'HC20260314080007', 7, '玫瑰花草茶100g', 45.00, 1, 45.00);

-- 订单8：已完成（6天前）
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260313150008', 5, 136.00, 136.00, 3, 1, DATE_SUB(NOW(), INTERVAL 6 DAY),
 '陈明', '13844444444', '上海市浦东新区世纪大道200号', DATE_SUB(NOW(), INTERVAL 6 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(8, 'HC20260313150008', 3, '汤臣倍健钙镁锌片60片', 68.00, 2, 136.00);

-- ============================================================
-- 库存变动日志
-- ============================================================
INSERT INTO `stock_log` (`product_id`, `product_name`, `type`, `change_quantity`, `before_stock`, `after_stock`, `order_no`, `operator_id`, `remark`) VALUES
(1, '汤臣倍健维生素C咀嚼片100片', 2, -1, 200, 199, 'HC20260316120001', 3, '订单出库'),
(3, '汤臣倍健钙镁锌片60片',       2, -1, 100, 99,  'HC20260316120001', 3, '订单出库'),
(4, '同仁堂红参片100g',           2, -1, 80,  79,  'HC20260317090002', 4, '订单出库'),
(5, '枸杞原浆30袋装',             2, -1, 120, 119, 'HC20260317090002', 4, '订单出库'),
(6, 'Myprotein乳清蛋白粉1kg',     2, -1, 60,  59,  'HC20260318140003', 5, '订单出库'),
(8, '菊花枸杞养生茶20包',         2, -2, 180, 178, 'HC20260319100004', 6, '订单出库'),
(6, 'Myprotein乳清蛋白粉1kg',     2, -1, 59,  58,  'HC20260319100004', 6, '订单出库'),
(2, '星鲨维生素D软胶囊60粒',      2, -1, 150, 149, 'HC20260319100004', 6, '订单出库'),
(5, '枸杞原浆30袋装',             2, -1, 119, 118, 'HC20260314080007', 3, '订单出库'),
(7, '玫瑰花草茶100g',             2, -1, 200, 199, 'HC20260314080007', 3, '订单出库'),
(3, '汤臣倍健钙镁锌片60片',       2, -2, 99,  97,  'HC20260313150008', 5, '订单出库'),
(1, '汤臣倍健维生素C咀嚼片100片', 4,  2, 199, 201, 'HC20260318160006', 4, '订单取消回滚');

-- ============================================================
-- 科普文章（5篇已发布 + 1篇草稿）
-- ============================================================
INSERT INTO `article` (`title`, `summary`, `content`, `author_id`, `status`, `view_count`, `created_at`) VALUES
('维生素C的正确补充方式',
 '很多人知道要补充维生素C，但你真的补对了吗？了解维生素C的最佳摄入量和注意事项。',
 '维生素C是人体必需的水溶性维生素，参与胶原蛋白的合成、促进铁的吸收、增强免疫功能等。\n\n一、每日推荐摄入量\n成年人每日推荐摄入量为100mg，上限为2000mg/天。过量摄入可能导致消化不良、腹泻等不适。\n\n二、最佳补充时间\n建议在饭后30分钟服用，避免空腹服用刺激胃黏膜。\n\n三、天然食物来源\n猕猴桃、鲜枣、柑橘、草莓、彩椒等都是维生素C含量丰富的食物。\n\n四、哪些人需要额外补充？\n1. 吸烟者\n2. 压力大、熬夜多的人群\n3. 术后恢复期患者\n4. 饮食不均衡的人群\n\n五、注意事项\n- 维生素C不宜与碱性药物同服\n- 肾功能不全者慎用大剂量维生素C\n- 咀嚼片服用后建议漱口，保护牙齿',
 1, 1, 236, DATE_SUB(NOW(), INTERVAL 10 DAY)),

('中老年人如何科学补钙？',
 '骨质疏松是中老年人常见问题，但补钙不是越多越好。来看看科学补钙的正确姿势。',
 '随着年龄增长，骨量逐渐流失，骨质疏松的风险也在增加。\n\n一、每日钙需求量\n50岁以上每日钙摄入量建议在1000-1200mg。\n\n二、补钙的最佳搭档——维生素D\n维生素D能促进钙的吸收和利用。建议每天晒太阳15-20分钟。\n\n三、钙片怎么选？\n1. 碳酸钙：含钙量高（40%），适合胃酸正常人群\n2. 柠檬酸钙：吸收不依赖胃酸，适合老年人\n3. 液体钙：吸收较好，口感佳\n\n四、补钙误区\n- 误区1：骨头汤能补钙（实际含钙量极低）\n- 误区2：补钙会导致结石（适量补钙反而降低结石风险）\n- 误区3：一次大量补钙（应分次服用，每次不超过500mg）',
 1, 1, 189, DATE_SUB(NOW(), INTERVAL 8 DAY)),

('枸杞养生：不只是泡水这么简单',
 '枸杞是国人最爱的养生食材之一，但很多人的吃法并不能发挥最大功效。',
 '枸杞是传统中药材中的"药食同源"佳品。\n\n一、枸杞的主要功效\n1. 养肝明目\n2. 抗氧化\n3. 增强免疫\n4. 补肾益精\n\n二、最佳食用方式\n- 干嚼：营养吸收最充分，每天20-30颗\n- 煲汤：出锅前10分钟放入\n- 泡水：用60-70°C温水泡\n- 枸杞原浆：保留鲜枸杞大部分营养\n\n三、枸杞并非人人适合\n- 感冒发烧时不宜食用\n- 腹泻期间暂停食用\n- 高血压患者适量食用\n- 糖尿病患者控制用量',
 1, 1, 312, DATE_SUB(NOW(), INTERVAL 6 DAY)),

('上班族颈椎保养指南',
 '长期伏案工作导致的颈椎问题已成为职业病之首。日常保养远比治疗重要。',
 '现代上班族长时间面对电脑，颈椎问题日益严重。\n\n一、正确的坐姿\n1. 电脑屏幕上沿与眼睛平齐\n2. 双脚平放地面\n3. 每45-60分钟起身活动\n\n二、颈椎保健操\n1. 前后点头：各10次\n2. 左右转头：各10次\n3. 耸肩运动：保持5秒，10次\n4. 头部环绕：顺逆各5圈\n\n三、辅助保健器械\n- 颈椎按摩仪：热敷+按摩\n- U型枕：午休支撑\n- 颈椎牵引器：缓解压迫\n\n四、睡眠姿势建议\n- 枕头高度约10-15cm\n- 推荐仰卧或侧卧',
 2, 1, 458, DATE_SUB(NOW(), INTERVAL 4 DAY)),

('喝茶养生的科学依据',
 '中国人喝了几千年的茶，现代科学证实了茶叶的多项健康益处。',
 '茶叶含有多种有益健康的活性成分。\n\n一、主要健康成分\n1. 茶多酚：强效抗氧化剂\n2. 咖啡因：提神醒脑\n3. 茶氨酸：放松精神\n4. 茶色素：降低心血管疾病风险\n\n二、不同茶的养生功效\n- 绿茶：抗氧化能力最强\n- 菊花茶：清肝明目\n- 玫瑰花茶：疏肝理气\n- 红茶：暖胃助消化\n- 普洱茶：降脂减肥\n\n三、喝茶注意事项\n- 避免空腹喝浓茶\n- 服药期间不宜喝茶\n- 睡前2小时不建议喝茶',
 2, 1, 175, DATE_SUB(NOW(), INTERVAL 2 DAY)),

('蛋白质补充全攻略（草稿）',
 '运动健身人群如何科学选择和使用蛋白粉？',
 '蛋白质是人体必需的宏量营养素。\n\n一、每日需求\n- 普通成年人：0.8-1.0g/kg\n- 运动爱好者：1.2-1.5g/kg\n- 健身增肌：1.5-2.0g/kg\n\n二、蛋白粉的分类\n1. 乳清蛋白：吸收最快\n2. 酪蛋白：缓释型\n3. 植物蛋白：适合素食者\n\n（待补充更多内容...）',
 1, 0, 0, NOW());
