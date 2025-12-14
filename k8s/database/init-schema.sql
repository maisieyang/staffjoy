-- PostgreSQL 数据库初始化脚本
-- 用于创建 Schema 和用户

-- ============================================
-- User Service Schema
-- ============================================
CREATE SCHEMA IF NOT EXISTS user_schema;

-- 创建用户（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'user_service_user') THEN
        CREATE USER user_service_user WITH PASSWORD 'change-me-in-production';
    END IF;
END
$$;

-- 授予权限
GRANT USAGE ON SCHEMA user_schema TO user_service_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA user_schema TO user_service_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA user_schema TO user_service_user;

-- 设置默认权限（未来创建的表自动授权）
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
    GRANT ALL ON TABLES TO user_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
    GRANT ALL ON SEQUENCES TO user_service_user;

-- ============================================
-- Shift Service Schema
-- ============================================
CREATE SCHEMA IF NOT EXISTS shift_schema;

-- 创建用户（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'shift_service_user') THEN
        CREATE USER shift_service_user WITH PASSWORD 'change-me-in-production';
    END IF;
END
$$;

-- 授予权限
GRANT USAGE ON SCHEMA shift_schema TO shift_service_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA shift_schema TO shift_service_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA shift_schema TO shift_service_user;

-- 设置默认权限
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
    GRANT ALL ON TABLES TO shift_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
    GRANT ALL ON SEQUENCES TO shift_service_user;

-- ============================================
-- 验证
-- ============================================
-- 列出所有用户
\du

-- 列出所有 schema
\dn

-- 显示当前数据库
SELECT current_database();

