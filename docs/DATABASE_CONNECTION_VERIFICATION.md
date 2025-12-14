# 数据库连接验证指南

## 📋 当前状态

### ✅ 已完成

1. **数据库迁移脚本**
   - ✅ User Service: V1__create_users_table.sql
   - ✅ Shift Service: V0__create_update_function.sql, V1__create_companies_table.sql, V2__create_shifts_table.sql

2. **Flyway 配置**
   - ✅ 已添加 Flyway 依赖
   - ✅ 已配置 application-prod.yml 和 application-local.yml
   - ✅ 迁移脚本已创建

3. **PostgreSQL 配置**
   - ✅ 已添加 PostgreSQL 依赖
   - ✅ 已创建本地配置文件（application-local.yml）
   - ✅ 已创建数据库初始化脚本

### ⚠️ 待完成

1. **启动 Docker Desktop**
   - Docker 当前未运行
   - 需要启动 Docker Desktop 才能使用 PostgreSQL 容器

2. **启动 PostgreSQL 容器**
   - 容器已创建但未运行
   - 需要启动容器

3. **启动应用并验证**
   - 应用需要连接到 PostgreSQL
   - 验证数据持久化

## 🚀 操作步骤

### 步骤 1: 启动 Docker Desktop

1. 打开 Docker Desktop 应用
2. 等待 Docker 完全启动（状态栏显示绿色）

### 步骤 2: 启动 PostgreSQL 容器

```bash
cd staffjoy
./scripts/start-postgres.sh
```

或手动启动：

```bash
docker start staffjoy-postgres
# 或创建新容器
docker run -d \
  --name staffjoy-postgres \
  -e POSTGRES_DB=staffjoy \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine
```

### 步骤 3: 初始化数据库（如果尚未执行）

```bash
docker exec -i staffjoy-postgres psql -U postgres -d staffjoy <<EOF
-- 创建更新函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
\$\$ language 'plpgsql';

-- 创建 User Service Schema
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE USER user_service_user WITH PASSWORD 'postgres';
GRANT USAGE ON SCHEMA user_schema TO user_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema GRANT ALL ON TABLES TO user_service_user;

-- 创建 Shift Service Schema
CREATE SCHEMA IF NOT EXISTS shift_schema;
CREATE USER shift_service_user WITH PASSWORD 'postgres';
GRANT USAGE ON SCHEMA shift_schema TO shift_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema GRANT ALL ON TABLES TO shift_service_user;
EOF
```

### 步骤 4: 执行数据库迁移

```bash
# User Service
cd user-service
mvn flyway:migrate \
  -Dflyway.url="jdbc:postgresql://localhost:5433/staffjoy?currentSchema=user_schema" \
  -Dflyway.user="postgres" \
  -Dflyway.password="postgres" \
  -Dflyway.schemas="user_schema"

# Shift Service
cd ../shift-service
mvn flyway:migrate \
  -Dflyway.url="jdbc:postgresql://localhost:5433/staffjoy?currentSchema=shift_schema" \
  -Dflyway.user="postgres" \
  -Dflyway.password="postgres" \
  -Dflyway.schemas="shift_schema"
```

### 步骤 5: 启动应用

```bash
# User Service（使用 local profile）
cd user-service
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run

# Shift Service（使用 local profile）
cd ../shift-service
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run
```

### 步骤 6: 验证数据库连接

```bash
# 1. 检查健康状态
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# 2. 创建测试数据
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","name":"Test User"}'

# 3. 验证数据保存到数据库
docker exec -it staffjoy-postgres psql -U postgres -d staffjoy -c "SELECT * FROM user_schema.users;"
```

## 🔍 验证清单

- [ ] Docker Desktop 已启动
- [ ] PostgreSQL 容器运行中
- [ ] 数据库 Schema 已创建
- [ ] Flyway 迁移已执行
- [ ] 应用启动成功
- [ ] 健康检查返回 UP
- [ ] API 可以创建数据
- [ ] 数据保存到 PostgreSQL（不是 H2）

## 🐛 常见问题

### Q: Docker 未运行

**A:** 启动 Docker Desktop，等待完全启动后再继续。

### Q: 端口 5433 被占用

**A:** 
```bash
# 检查占用
lsof -i :5433

# 停止容器
docker stop staffjoy-postgres

# 使用其他端口
docker run -p 5434:5432 ...
```

### Q: 应用无法连接数据库

**A:** 
1. 检查 PostgreSQL 容器是否运行：`docker ps | grep postgres`
2. 检查端口映射：`docker port staffjoy-postgres`
3. 测试连接：`psql -h localhost -p 5433 -U postgres -d staffjoy`

### Q: Flyway 迁移失败

**A:**
1. 检查数据库连接配置
2. 检查迁移脚本语法
3. 查看详细错误：`mvn flyway:migrate -X`

## 📚 相关文档

- [PostgreSQL 设置指南](POSTGRESQL_SETUP.md)
- [Flyway 迁移指南](FLYWAY_MIGRATION_GUIDE.md)
- [数据库策略文档](CLOUD_DATABASE_STRATEGY.md)

