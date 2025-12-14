# Flyway 数据库迁移指南

## 📋 概述

本项目使用 **Flyway** 进行数据库版本管理和迁移。Flyway 是一个开源的数据库迁移工具，可以跟踪、管理和应用数据库变更。

## 🎯 为什么使用 Flyway？

- ✅ **版本控制**: 数据库变更像代码一样可以版本控制
- ✅ **可重复性**: 可以在任何环境重复执行迁移
- ✅ **自动化**: 应用启动时自动执行迁移
- ✅ **安全性**: 防止手动修改数据库导致的错误
- ✅ **团队协作**: 多人协作时避免数据库结构冲突

## 📁 目录结构

```
user-service/
└── src/main/resources/
    └── db/migration/
        └── V1__create_users_table.sql

shift-service/
└── src/main/resources/
    └── db/migration/
        ├── V1__create_update_function.sql
        ├── V1__create_companies_table.sql
        └── V2__create_shifts_table.sql
```

## 📝 迁移脚本命名规则

Flyway 使用特定的命名规则来识别和执行迁移脚本：

```
V{version}__{description}.sql
```

**示例：**
- `V1__create_users_table.sql` - 版本 1，创建用户表
- `V2__add_user_index.sql` - 版本 2，添加用户索引
- `V3__alter_users_add_column.sql` - 版本 3，修改用户表添加列

**规则：**
- `V` 或 `v` 开头（大写推荐）
- 版本号：数字，可以包含下划线（如 `V1_1`）
- 两个下划线 `__` 分隔版本号和描述
- 描述：使用下划线分隔单词
- 文件扩展名：`.sql`

## 🚀 使用流程

### 1. 创建迁移脚本

在 `src/main/resources/db/migration/` 目录下创建新的 SQL 文件：

```sql
-- V2__add_user_avatar.sql
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);
```

### 2. 应用启动时自动执行

Spring Boot 启动时会自动执行 Flyway 迁移：

```bash
# 启动应用
mvn spring-boot:run

# 或使用 Docker
docker-compose up user-service
```

### 3. 验证迁移

```bash
# 查看迁移历史（连接到数据库）
psql -h localhost -U postgres -d staffjoy

# 查看 Flyway 历史表
SELECT * FROM flyway_schema_history ORDER BY installed_rank;
```

## 📊 迁移脚本示例

### 创建表

```sql
-- V1__create_users_table.sql
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 添加列

```sql
-- V2__add_user_phone.sql
ALTER TABLE users ADD COLUMN phone_number VARCHAR(50);
```

### 创建索引

```sql
-- V3__add_user_indexes.sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
```

### 修改列

```sql
-- V4__modify_user_email.sql
ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(500);
```

### 数据迁移

```sql
-- V5__migrate_user_data.sql
UPDATE users SET phone_number = CONCAT('+86', phone_number) 
WHERE phone_number IS NOT NULL AND phone_number NOT LIKE '+%';
```

## ⚙️ 配置说明

### application-prod.yml

```yaml
spring:
  flyway:
    enabled: true                    # 启用 Flyway
    baseline-on-migrate: true         # 如果数据库已有表，自动创建基线
    validate-on-migrate: true        # 迁移前验证脚本
    locations: classpath:db/migration # 迁移脚本位置
    schemas: ${DB_SCHEMA}            # 指定 schema
    table: flyway_schema_history      # Flyway 历史表名称
    baseline-version: 0              # 基线版本号
    baseline-description: "Initial baseline" # 基线描述
```

### 开发环境配置

```yaml
# application-dev.yml
spring:
  flyway:
    enabled: false  # 开发环境可以禁用，使用 Hibernate ddl-auto=update
  jpa:
    hibernate:
      ddl-auto: update  # 开发环境自动创建表
```

### 生产环境配置

```yaml
# application-prod.yml
spring:
  flyway:
    enabled: true   # 生产环境必须启用 Flyway
  jpa:
    hibernate:
      ddl-auto: validate  # 生产环境只验证，不自动创建表
```

## 🔧 常用操作

### 手动执行迁移

```bash
# 使用 Maven Flyway 插件
mvn flyway:migrate

# 查看迁移状态
mvn flyway:info

# 验证迁移脚本
mvn flyway:validate

# 修复迁移（如果迁移失败）
mvn flyway:repair
```

### 回滚迁移

Flyway 默认不支持回滚，需要手动创建回滚脚本：

```sql
-- V6__rollback_add_user_avatar.sql
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
```

或者使用 Flyway 的 undo 功能（需要商业版）。

### 基线迁移

如果数据库已有表结构，需要创建基线：

```bash
# 使用 Maven 插件
mvn flyway:baseline -Dflyway.baselineVersion=1 -Dflyway.baselineDescription="Initial baseline"

# 或使用配置
spring:
  flyway:
    baseline-on-migrate: true
    baseline-version: 1
```

## 🐛 故障排查

### 迁移失败

**问题**: 迁移脚本执行失败

**解决**:
1. 检查 SQL 语法错误
2. 查看应用日志
3. 手动执行 SQL 验证
4. 使用 `flyway:repair` 修复

### 版本冲突

**问题**: 迁移脚本版本号冲突

**解决**:
1. 检查是否有重复的版本号
2. 使用下一个可用版本号
3. 确保版本号递增

### Schema 不存在

**问题**: 指定的 schema 不存在

**解决**:
1. 先创建 schema（在 init-schema.sql 中）
2. 或使用默认 schema（public）

## 📚 最佳实践

### 1. 版本号管理

- 使用递增的版本号：V1, V2, V3...
- 可以使用子版本：V1_1, V1_2...
- 不要跳过版本号

### 2. 脚本编写

- 使用 `IF NOT EXISTS` 避免重复创建
- 使用事务（PostgreSQL 默认支持）
- 添加注释说明变更原因
- 测试脚本在空数据库上执行

### 3. 环境管理

- **开发环境**: 可以使用 Hibernate ddl-auto=update
- **测试环境**: 使用 Flyway，测试迁移脚本
- **生产环境**: 必须使用 Flyway，禁用 ddl-auto

### 4. 团队协作

- 迁移脚本提交到 Git
- 合并代码前检查迁移脚本冲突
- 使用 Pull Request 审查迁移脚本

## 🔗 相关文档

- [Flyway 官方文档](https://flywaydb.org/documentation/)
- [Spring Boot Flyway](https://docs.spring.io/spring-boot/docs/current/reference/html/howto.html#howto.data-initialization.migration-tool.flyway)
- [PostgreSQL 设置指南](POSTGRESQL_SETUP.md)

## 📋 迁移脚本清单

### User Service

- ✅ `V1__create_users_table.sql` - 创建用户表

### Shift Service

- ✅ `V1__create_update_function.sql` - 创建更新时间函数
- ✅ `V1__create_companies_table.sql` - 创建公司表
- ✅ `V2__create_shifts_table.sql` - 创建排班表

## 🚀 下一步

创建新的迁移脚本时：

1. 在 `db/migration/` 目录创建新的 SQL 文件
2. 使用正确的命名规则
3. 测试脚本在空数据库上执行
4. 提交到 Git
5. 部署时 Flyway 会自动执行

