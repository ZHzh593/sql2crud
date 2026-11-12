-- ============================================================
--  论文管理系统 · 建库脚本（MySQL 5.7 / 8.x）
--  执行：mysql -uroot -proot < sql/paper.sql
-- ============================================================

DROP DATABASE IF EXISTS paper_db;
CREATE DATABASE paper_db DEFAULT CHARACTER SET utf8mb4;
USE paper_db;

-- 公共代码表（论文类型）
DROP TABLE IF EXISTS t_code;
CREATE TABLE t_code (
    id        BIGINT      NOT NULL AUTO_INCREMENT COMMENT '代码id',
    code_name VARCHAR(50) NOT NULL COMMENT '代码名称（论文类型）',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 用户表
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
    id            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '用户id',
    user_code     VARCHAR(50) NOT NULL COMMENT '用户账号',
    user_name     VARCHAR(50) NOT NULL COMMENT '用户名称',
    user_password VARCHAR(50) NOT NULL COMMENT '用户密码',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_code (user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 论文表
DROP TABLE IF EXISTS t_paper;
CREATE TABLE t_paper (
    id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '论文id',
    title         VARCHAR(100) NOT NULL COMMENT '论文题目',
    type          BIGINT       NOT NULL COMMENT '论文类型（t_code.id）',
    paper_summary VARCHAR(255) NOT NULL COMMENT '论文摘要',
    paper_path    VARCHAR(255) NOT NULL COMMENT '文件路径',
    created_by    BIGINT                DEFAULT NULL COMMENT '作者（t_user.id）',
    creation_date DATETIME              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_by     BIGINT                DEFAULT NULL COMMENT '修改人',
    modify_date   DATETIME              DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_paper_title (title),
    KEY idx_paper_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 测试数据：公共代码 3 条、用户 1 条、论文 2 条（方便看分页/隔行变色）
INSERT INTO t_code (code_name) VALUES ('毕业论文'), ('课程论文'), ('期刊论文');

INSERT INTO t_user (user_code, user_name, user_password) VALUES ('admin', '管理员', '123456');

INSERT INTO t_paper (title, type, paper_summary, paper_path, created_by) VALUES
('基于SSM的论文管理系统', 1, '讨论 SSM 分层与实现', '/uploads/paper/demo1.pdf', 1),
('Vue3 前端开发实践',     2, '组合式 API 的使用',     '/uploads/paper/demo2.pdf', 1);

SELECT '用户' AS 表名, COUNT(*) AS 条数 FROM t_user
UNION ALL SELECT '公共代码', COUNT(*) FROM t_code
UNION ALL SELECT '论文', COUNT(*) FROM t_paper;
