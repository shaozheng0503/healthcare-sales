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

-- 一级分类（8个，全部为非食用类保健用品）
INSERT INTO `category` (`name`, `parent_id`, `sort`) VALUES
('外用贴剂类',   0, 1),
('理疗器械类',   0, 2),
('健康监测类',   0, 3),
('康复辅助类',   0, 4),
('中医保健类',   0, 5),
('睡眠环境类',   0, 6),
('运动保健类',   0, 7),
('消毒防护类',   0, 8);

-- 二级分类
INSERT INTO `category` (`name`, `parent_id`, `sort`) VALUES
('艾灸贴',       1, 1),
('热敷贴',       1, 2),
('冷敷贴',       1, 3),
('按摩仪',       2, 1),
('理疗仪',       2, 2),
('血压计',       3, 1),
('血糖仪',       3, 2),
('体温计',       3, 3),
('护膝',         4, 1),
('颈椎牵引器',   4, 2),
('拔罐器',       5, 1),
('刮痧板',       5, 2),
('记忆枕',       6, 1),
('睡眠眼罩',     6, 2),
('筋膜枪',       7, 1),
('瑜伽垫',       7, 2),
('消毒灯',       8, 1),
('空气净化器',   8, 2);

-- 示例商品数据（非食用类保健用品，每个一级分类2个）
INSERT INTO `product` (`category_id`, `name`, `description`, `price`, `original_price`, `stock`, `stock_warning`, `sales_count`, `status`, `created_by`) VALUES
(9,  '南极人艾灸贴30片装',            '温经散寒，缓解肩颈腰腿酸痛，自发热艾草贴敷',    39.90,  59.00, 200, 20, 156, 1, 1),
(10, '云南白药热敷贴6片装',           '持续发热8小时，缓解肌肉疲劳和关节不适',           25.00,  35.00, 150, 15, 89,  1, 1),
(12, 'SKG颈椎按摩仪K5',              '脉冲+热敷双模式，4D浮动按摩头，缓解颈肩疲劳',   299.00, 399.00, 80,  8,  203, 1, 1),
(13, '奥佳华低频理疗仪',              '低频脉冲电流刺激，舒缓肌肉酸痛，多种模式可选',  198.00, 258.00, 60,  5,  67,  1, 1),
(14, '欧姆龙电子血压计U10',           '上臂式精准测量，大屏显示，双人记忆，家用医用级', 298.00, 368.00, 120, 12, 312, 1, 1),
(15, '鱼跃血糖仪580套装',             '微量采血，5秒速测，含50片试纸+采血笔',           128.00, 168.00, 100, 10, 145, 1, 1),
(17, '保而防专业运动护膝',            '德国品牌，硅胶环绕髌骨，运动防护+康复支撑',      168.00, 228.00, 200, 20, 89,  1, 1),
(18, '佳禾颈椎牵引器',                '充气式颈椎牵引，缓解颈椎压迫，可调节力度',        58.00,  78.00, 180, 15, 234, 1, 1),
(19, '华佗牌真空拔罐器24罐',          '家用真空拔罐套装，含24个不同规格罐体，操作简便', 69.00,  99.00, 150, 15, 178, 1, 1),
(20, '砭石刮痧板套装',                '天然砭石材质，含面部+身体刮痧板，附收纳袋',       45.00,  68.00, 200, 20, 156, 1, 1),
(21, '泰普尔记忆枕头',                '丹麦品牌，慢回弹记忆棉，符合人体工学曲线',       399.00, 499.00, 30,  3,  56,  1, 1),
(22, '睡眠博士护颈枕',                '分区设计，高低可调，适合不同睡姿，改善颈椎问题',  199.00, 259.00, 45,  5,  78,  1, 1),
(23, '麦瑞克筋膜枪Mini',              '便携迷你款，6档力度调节，深层肌肉放松',          259.00, 359.00, 90,  10, 127, 1, 1),
(24, 'Lululemon瑜伽垫5mm',           '天然橡胶材质，防滑耐磨，双面纹理，含背带',       368.00, 458.00, 60,  5,  98,  1, 1),
(25, '飞利浦紫外线消毒灯',            '紫外线+臭氧双重杀菌，定时自动关闭，安全防护',   189.00, 249.00, 100, 10, 87,  1, 1),
(26, '小米空气净化器4Pro',            '除甲醛除菌除异味，HEPA滤芯，适用60㎡',           899.00,1099.00, 40,  3,  65,  1, 1);

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

-- 订单1：已完成（3天前）— 艾灸贴 + 热敷贴
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260316120001', 3, 64.90, 64.90, 3, 1, DATE_SUB(NOW(), INTERVAL 3 DAY),
 '李四', '13822222222', '浙江省杭州市西湖区文一路88号', DATE_SUB(NOW(), INTERVAL 3 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(1, 'HC20260316120001', 1, '南极人艾灸贴30片装', 39.90, 1, 39.90),
(1, 'HC20260316120001', 2, '云南白药热敷贴6片装', 25.00, 1, 25.00);

-- 订单2：已完成（2天前）— 按摩仪 + 理疗仪
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260317090002', 4, 497.00, 497.00, 3, 1, DATE_SUB(NOW(), INTERVAL 2 DAY),
 '王芳', '13833333333', '江苏省南京市鼓楼区中山路100号', DATE_SUB(NOW(), INTERVAL 2 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(2, 'HC20260317090002', 3, 'SKG颈椎按摩仪K5', 299.00, 1, 299.00),
(2, 'HC20260317090002', 4, '奥佳华低频理疗仪', 198.00, 1, 198.00);

-- 订单3：已发货（1天前）— 血压计
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260318140003', 5, 298.00, 298.00, 2, 1, DATE_SUB(NOW(), INTERVAL 1 DAY),
 '陈明', '13844444444', '上海市浦东新区张江高科技园区', DATE_SUB(NOW(), INTERVAL 1 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(3, 'HC20260318140003', 5, '欧姆龙电子血压计U10', 298.00, 1, 298.00);

-- 订单4：已支付待发货（今天）— 护膝 + 筋膜枪 + 拔罐器
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260319100004', 6, 496.00, 496.00, 1, 1, NOW(),
 '赵丽', '13855555555', '广东省深圳市南山区科技园南路', NOW());
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(4, 'HC20260319100004', 7, '保而防专业运动护膝', 168.00, 1, 168.00),
(4, 'HC20260319100004', 13, '麦瑞克筋膜枪Mini', 259.00, 1, 259.00),
(4, 'HC20260319100004', 9, '华佗牌真空拔罐器24罐', 69.00, 1, 69.00);

-- 订单5：待支付（今天）— 记忆枕 + 空气净化器
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260319110005', 3, 1298.00, 1298.00, 0, 1,
 '李四', '13822222222', '浙江省杭州市余杭区阿里巴巴西溪园区', NOW());
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(5, 'HC20260319110005', 11, '泰普尔记忆枕头', 399.00, 1, 399.00),
(5, 'HC20260319110005', 16, '小米空气净化器4Pro', 899.00, 1, 899.00);

-- 订单6：已取消（昨天）— 艾灸贴x2
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260318160006', 4, 79.80, 79.80, 4, 1,
 '王芳', '13833333333', '江苏省南京市鼓楼区中山路100号', DATE_SUB(NOW(), INTERVAL 1 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(6, 'HC20260318160006', 1, '南极人艾灸贴30片装', 39.90, 2, 79.80);

-- 订单7：已完成（5天前）— 血糖仪 + 刮痧板
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260314080007', 3, 173.00, 173.00, 3, 1, DATE_SUB(NOW(), INTERVAL 5 DAY),
 '李四', '13822222222', '浙江省杭州市西湖区文一路88号', DATE_SUB(NOW(), INTERVAL 5 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(7, 'HC20260314080007', 6, '鱼跃血糖仪580套装', 128.00, 1, 128.00),
(7, 'HC20260314080007', 10, '砭石刮痧板套装', 45.00, 1, 45.00);

-- 订单8：已完成（6天前）— 颈椎牵引器x2
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `pay_amount`, `status`, `pay_type`, `pay_time`,
    `receiver_name`, `receiver_phone`, `receiver_address`, `created_at`) VALUES
('HC20260313150008', 5, 116.00, 116.00, 3, 1, DATE_SUB(NOW(), INTERVAL 6 DAY),
 '陈明', '13844444444', '上海市浦东新区世纪大道200号', DATE_SUB(NOW(), INTERVAL 6 DAY));
INSERT INTO `order_item` (`order_id`, `order_no`, `product_id`, `product_name`, `price`, `quantity`, `total_price`) VALUES
(8, 'HC20260313150008', 8, '佳禾颈椎牵引器', 58.00, 2, 116.00);

-- ============================================================
-- 库存变动日志
-- ============================================================
INSERT INTO `stock_log` (`product_id`, `product_name`, `type`, `change_quantity`, `before_stock`, `after_stock`, `order_no`, `operator_id`, `remark`) VALUES
(1,  '南极人艾灸贴30片装',      2, -1, 200, 199, 'HC20260316120001', 3, '订单出库'),
(2,  '云南白药热敷贴6片装',     2, -1, 150, 149, 'HC20260316120001', 3, '订单出库'),
(3,  'SKG颈椎按摩仪K5',        2, -1, 80,  79,  'HC20260317090002', 4, '订单出库'),
(4,  '奥佳华低频理疗仪',        2, -1, 60,  59,  'HC20260317090002', 4, '订单出库'),
(5,  '欧姆龙电子血压计U10',     2, -1, 120, 119, 'HC20260318140003', 5, '订单出库'),
(7,  '保而防专业运动护膝',      2, -1, 200, 199, 'HC20260319100004', 6, '订单出库'),
(13, '麦瑞克筋膜枪Mini',       2, -1, 90,  89,  'HC20260319100004', 6, '订单出库'),
(9,  '华佗牌真空拔罐器24罐',    2, -1, 150, 149, 'HC20260319100004', 6, '订单出库'),
(6,  '鱼跃血糖仪580套装',       2, -1, 100, 99,  'HC20260314080007', 3, '订单出库'),
(10, '砭石刮痧板套装',          2, -1, 200, 199, 'HC20260314080007', 3, '订单出库'),
(8,  '佳禾颈椎牵引器',          2, -2, 180, 178, 'HC20260313150008', 5, '订单出库'),
(1,  '南极人艾灸贴30片装',      4,  2, 199, 201, 'HC20260318160006', 4, '订单取消回滚');

-- ============================================================
-- 科普文章（5篇已发布 + 1篇草稿）
-- ============================================================
INSERT INTO `article` (`title`, `summary`, `content`, `author_id`, `status`, `view_count`, `created_at`) VALUES
('颈椎按摩仪的正确使用方法',
 '颈椎按摩仪已成为上班族缓解颈肩疲劳的热门选择，但不正确的使用方式可能适得其反。',
 '颈椎按摩仪是通过脉冲电流、热敷或物理振动来缓解颈部肌肉紧张的保健器械。\n\n一、适用人群\n1. 长期伏案工作的上班族\n2. 经常低头看手机的人群\n3. 颈部肌肉僵硬酸痛者\n4. 颈椎曲度变直的早期患者\n\n二、正确使用方法\n1. 每次使用15-20分钟，不宜超过30分钟\n2. 使用前在颈部涂抹少量水或导电凝胶\n3. 从低档位开始，逐渐增加到舒适力度\n4. 贴片应紧贴皮肤，避免悬空\n\n三、使用禁忌\n- 皮肤破损处不可使用\n- 心脏起搏器佩戴者禁用\n- 孕妇颈部禁用\n- 急性颈椎损伤期不可使用\n- 饭后30分钟内不宜使用',
 1, 1, 458, DATE_SUB(NOW(), INTERVAL 10 DAY)),

('如何选择适合自己的血压计',
 '家用血压计是高血压患者日常监测的必备工具，选对血压计才能获得准确的测量结果。',
 '随着健康意识的提高，越来越多家庭配备了电子血压计。\n\n一、血压计的类型\n1. 上臂式：医院和家庭最常用，准确度最高\n2. 腕式：便携但受姿势影响大\n3. 指夹式：误差较大，不推荐\n\n二、选购要点\n1. 优先选择上臂式，通过ESH或AAMI认证\n2. 袖带尺寸要匹配（标准22-32cm，大号32-42cm）\n3. 选择带记忆功能的，方便跟踪趋势\n4. 大屏显示，适合老年人阅读\n\n三、正确测量方法\n1. 测量前静坐5分钟\n2. 手臂与心脏保持同一高度\n3. 袖带下缘距肘窝2cm\n4. 每天固定时间测量\n5. 连续测2-3次取平均值\n\n四、测量注意事项\n- 避免在运动、进食、吸烟后立即测量\n- 测量时不要说话\n- 冬季注意室温不要过低',
 1, 1, 312, DATE_SUB(NOW(), INTERVAL 8 DAY)),

('艾灸贴的保健原理与使用注意事项',
 '艾灸贴结合了传统艾灸和现代贴敷技术，使用方便但需注意正确方法。',
 '艾灸贴是将艾草提取物与自发热材料结合的外用保健贴剂。\n\n一、工作原理\n1. 自发热材料（铁粉+活性炭）接触空气后氧化产热\n2. 艾草精油在热力作用下渗透皮肤\n3. 持续温热刺激穴位，促进局部血液循环\n\n二、常用贴敷部位\n- 肩颈酸痛：大椎穴、肩井穴\n- 腰部不适：肾俞穴、命门穴\n- 膝关节酸痛：膝眼穴\n- 手脚冰凉：涌泉穴、关元穴\n\n三、使用注意事项\n1. 贴敷时间不超过8小时\n2. 皮肤敏感者先小面积试贴\n3. 贴敷后如有灼热感应立即取下\n4. 避免在睡觉时使用（防止低温烫伤）\n5. 孕妇腹部和腰骶部禁用\n6. 皮肤破损、湿疹部位不可贴敷',
 1, 1, 236, DATE_SUB(NOW(), INTERVAL 6 DAY)),

('上班族颈椎保养指南',
 '长期伏案工作导致的颈椎问题已成为职业病之首。日常保养远比治疗重要。',
 '现代上班族长时间面对电脑，颈椎问题日益严重。\n\n一、正确的坐姿\n1. 电脑屏幕上沿与眼睛平齐\n2. 双脚平放地面\n3. 每45-60分钟起身活动\n\n二、颈椎保健操\n1. 前后点头：缓慢低头抬头各10次\n2. 左右转头：缓慢转头看左右肩各10次\n3. 耸肩运动：双肩上耸保持5秒，放松，10次\n4. 头部环绕：缓慢做圆周运动，顺逆各5圈\n\n三、辅助保健用品\n- 颈椎按摩仪：脉冲+热敷缓解肌肉紧张\n- 颈椎牵引器：轻度牵引缓解压迫\n- 记忆枕：支撑颈椎自然曲度\n- 护颈枕：午休时保护颈椎\n\n四、睡眠姿势建议\n- 枕头高度约10-15cm（拳头高度）\n- 推荐仰卧或侧卧\n- 避免趴着睡觉',
 2, 1, 189, DATE_SUB(NOW(), INTERVAL 4 DAY)),

('运动损伤后的正确护理方式',
 '运动损伤处理不当可能加重伤情。掌握RICE原则和正确使用护具是关键。',
 '运动损伤是运动爱好者常见的问题，正确的初期处理至关重要。\n\n一、RICE急救原则\n1. Rest（休息）：立即停止运动，避免受伤部位承重\n2. Ice（冰敷）：用冷敷贴或冰袋冷敷15-20分钟，每2小时一次\n3. Compression（加压）：用弹性绷带适当加压包扎\n4. Elevation（抬高）：将受伤部位抬高于心脏水平\n\n二、常见运动损伤与护具选择\n- 膝关节扭伤：佩戴专业运动护膝\n- 踝关节扭伤：使用护踝固定\n- 腰肌劳损：佩戴护腰带\n- 肌肉酸痛：使用筋膜枪放松深层肌肉\n\n三、恢复期保健\n1. 48小时后可改为热敷贴促进血液循环\n2. 配合低频理疗仪辅助康复\n3. 循序渐进恢复运动量\n4. 运动前做好充分热身',
 2, 1, 175, DATE_SUB(NOW(), INTERVAL 2 DAY)),

('改善睡眠质量的科学方法（草稿）',
 '失眠已成为现代人的普遍困扰，合适的睡眠环境和保健用品可以有效改善睡眠质量。',
 '良好的睡眠对健康至关重要。\n\n一、睡眠环境优化\n1. 室温保持在18-22°C\n2. 使用遮光窗帘和睡眠眼罩\n3. 保持卧室安静\n4. 使用助眠香薰（薰衣草、洋甘菊）\n\n二、寝具选择\n1. 记忆枕：贴合颈椎曲线，分散压力\n2. 护颈枕：分区设计适合不同睡姿\n3. 枕头高度：仰卧约一拳高，侧卧约一拳半\n\n（待补充更多内容...）',
 1, 0, 0, NOW());
