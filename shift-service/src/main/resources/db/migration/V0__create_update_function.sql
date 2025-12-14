-- Flyway Migration Script: Create update_updated_at_column function
-- Version: V1
-- Description: 创建更新时间触发器函数（必须在创建表之前）

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 添加注释
COMMENT ON FUNCTION update_updated_at_column() IS '自动更新 updated_at 字段的触发器函数';

