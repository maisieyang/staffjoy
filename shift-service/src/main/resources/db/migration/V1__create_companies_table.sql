-- Flyway Migration Script: Create companies table
-- Version: V1
-- Description: 创建公司表

CREATE TABLE IF NOT EXISTS companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    legal_name VARCHAR(255),
    description TEXT,
    website VARCHAR(255),
    phone_number VARCHAR(50),
    address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_companies_name ON companies(name);

-- 创建更新时间触发器
CREATE TRIGGER update_companies_updated_at 
    BEFORE UPDATE ON companies 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 添加注释
COMMENT ON TABLE companies IS '公司表';
COMMENT ON COLUMN companies.id IS '公司ID';
COMMENT ON COLUMN companies.name IS '公司名称（唯一）';
COMMENT ON COLUMN companies.legal_name IS '法人名称';
COMMENT ON COLUMN companies.description IS '公司描述';
COMMENT ON COLUMN companies.website IS '网站地址';
COMMENT ON COLUMN companies.phone_number IS '电话号码';
COMMENT ON COLUMN companies.address IS '公司地址';
COMMENT ON COLUMN companies.created_at IS '创建时间';
COMMENT ON COLUMN companies.updated_at IS '更新时间';

