-- Flyway Migration Script: Create shifts table
-- Version: V2
-- Description: 创建排班表

CREATE TABLE IF NOT EXISTS shifts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    company_id BIGINT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    stop_time TIMESTAMP NOT NULL,
    published BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键约束：关联到 companies 表
    CONSTRAINT fk_shifts_company 
        FOREIGN KEY (company_id) 
        REFERENCES companies(id) 
        ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_shifts_user_id ON shifts(user_id);
CREATE INDEX IF NOT EXISTS idx_shifts_company_id ON shifts(company_id);
CREATE INDEX IF NOT EXISTS idx_shifts_start_time ON shifts(start_time);
CREATE INDEX IF NOT EXISTS idx_shifts_stop_time ON shifts(stop_time);
CREATE INDEX IF NOT EXISTS idx_shifts_published ON shifts(published);

-- 创建复合索引（用于查询优化）
CREATE INDEX IF NOT EXISTS idx_shifts_company_published ON shifts(company_id, published);
CREATE INDEX IF NOT EXISTS idx_shifts_user_time ON shifts(user_id, start_time, stop_time);

-- 创建更新时间触发器
CREATE TRIGGER update_shifts_updated_at 
    BEFORE UPDATE ON shifts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 创建触发器：当 published 变为 true 时，自动设置 published_at
CREATE OR REPLACE FUNCTION set_published_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.published = TRUE AND OLD.published = FALSE THEN
        NEW.published_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_shifts_published_at 
    BEFORE UPDATE ON shifts 
    FOR EACH ROW 
    EXECUTE FUNCTION set_published_at();

-- 添加检查约束：开始时间必须早于结束时间
ALTER TABLE shifts 
    ADD CONSTRAINT chk_shifts_time_order 
    CHECK (start_time < stop_time);

-- 添加注释
COMMENT ON TABLE shifts IS '排班表';
COMMENT ON COLUMN shifts.id IS '排班ID';
COMMENT ON COLUMN shifts.user_id IS '用户ID（跨服务引用）';
COMMENT ON COLUMN shifts.company_id IS '公司ID（外键关联到 companies 表）';
COMMENT ON COLUMN shifts.start_time IS '开始时间';
COMMENT ON COLUMN shifts.stop_time IS '结束时间';
COMMENT ON COLUMN shifts.published IS '是否已发布';
COMMENT ON COLUMN shifts.published_at IS '发布时间';
COMMENT ON COLUMN shifts.created_at IS '创建时间';
COMMENT ON COLUMN shifts.updated_at IS '更新时间';

