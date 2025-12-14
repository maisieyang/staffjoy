# PostgreSQL 云原生数据库实施方案

## 📋 方案概述

选择 **PostgreSQL** 作为云原生数据库，原因：
- ✅ 功能强大（JSON、全文搜索、数组等）
- ✅ 性能优秀
- ✅ ACID 事务支持
- ✅ 丰富的扩展生态
- ✅ 云服务商广泛支持

## 🏗️ 架构设计

### 推荐架构：单数据库实例（当前项目规模）

```
┌─────────────────┐
│  User Service   │──┐
└─────────────────┘  │
                     ├──► PostgreSQL (云托管)
┌─────────────────┐  │     主从高可用
│ Shift Service   │──┘     自动备份
└─────────────────┘
```

**数据库设计：**
- **数据库名**: `staffjoy`
- **Schema 分离**: 
  - `user_schema` - 用户服务数据
  - `shift_schema` - 排班服务数据
- **用户权限**: 每个服务使用独立用户，只访问自己的 schema

## ☁️ 云服务商 PostgreSQL 方案

### 阿里云 RDS PostgreSQL

**特点：**
- 高可用版（一主一备）
- 自动备份（保留 7-30 天）
- 读写分离（只读实例）
- 监控告警
- 白名单安全控制

**创建实例：**
```bash
# 使用阿里云 CLI
aliyun rds CreateDBInstance \
  --Engine PostgreSQL \
  --EngineVersion 15.0 \
  --DBInstanceClass pg.n2.medium.1 \
  --DBInstanceStorage 20 \
  --DBInstanceDescription "Staffjoy PostgreSQL" \
  --PayType PostPaid
```

**连接信息格式：**
```
主机: rm-xxxxx.pg.rds.aliyuncs.com
端口: 5432
数据库: staffjoy
```

### AWS RDS PostgreSQL

**特点：**
- Multi-AZ 高可用
- 自动备份
- 只读副本
- 性能洞察

**连接信息格式：**
```
主机: staffjoy-db.xxxxx.us-east-1.rds.amazonaws.com
端口: 5432
数据库: staffjoy
```

### Google Cloud SQL PostgreSQL

**特点：**
- 完全托管
- 自动备份
- 高可用配置
- 与 GKE 集成好

## 🔧 项目配置

### 1. 添加 PostgreSQL 依赖

**pom.xml** (user-service 和 shift-service)

```xml
<!-- PostgreSQL Database -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### 2. 应用配置

#### 开发环境（H2）

```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:h2:mem:userdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: update
```

#### 生产环境（PostgreSQL）

```yaml
# application-prod.yml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?currentSchema=${DB_SCHEMA}
    driver-class-name: org.postgresql.Driver
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
  jpa:
    hibernate:
      ddl-auto: validate  # 生产环境使用 validate
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    properties:
      hibernate:
        default_schema: ${DB_SCHEMA}
        format_sql: false  # 生产环境关闭 SQL 格式化
        show_sql: false    # 生产环境关闭 SQL 日志
```

### 3. Schema 设计

#### User Service Schema

```sql
-- 创建 Schema
CREATE SCHEMA IF NOT EXISTS user_schema;

-- 创建用户
CREATE USER user_service_user WITH PASSWORD 'secure-password';

-- 授予权限
GRANT USAGE ON SCHEMA user_schema TO user_service_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA user_schema TO user_service_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA user_schema TO user_service_user;

-- 设置默认权限（未来创建的表自动授权）
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
  GRANT ALL ON TABLES TO user_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
  GRANT ALL ON SEQUENCES TO user_service_user;
```

#### Shift Service Schema

```sql
-- 创建 Schema
CREATE SCHEMA IF NOT EXISTS shift_schema;

-- 创建用户
CREATE USER shift_service_user WITH PASSWORD 'secure-password';

-- 授予权限
GRANT USAGE ON SCHEMA shift_schema TO shift_service_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA shift_schema TO shift_service_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA shift_schema TO shift_service_user;

-- 设置默认权限
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
  GRANT ALL ON TABLES TO shift_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
  GRANT ALL ON SEQUENCES TO shift_service_user;
```

## 🐳 Kubernetes 配置

### 方案 A: 使用云托管 PostgreSQL（推荐）

#### 1. 创建 Secret

```yaml
# k8s/secrets/postgresql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secret
  labels:
    app: staffjoy
type: Opaque
stringData:
  # PostgreSQL 连接信息
  db-host: "rm-xxxxx.pg.rds.aliyuncs.com"
  db-port: "5432"
  db-name: "staffjoy"
  # User Service
  user-db-schema: "user_schema"
  user-db-username: "user_service_user"
  user-db-password: "secure-password"
  # Shift Service
  shift-db-schema: "shift_schema"
  shift-db-username: "shift_service_user"
  shift-db-password: "secure-password"
```

#### 2. 更新 Deployment

**User Service Deployment:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  template:
    spec:
      containers:
      - name: user-service
        env:
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_NAME)?currentSchema=$(DB_SCHEMA)"
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: db-host
        - name: DB_PORT
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: db-port
        - name: DB_NAME
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: db-name
        - name: DB_SCHEMA
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: user-db-schema
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: user-db-username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: user-db-password
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
```

### 方案 B: Kubernetes StatefulSet（自建 PostgreSQL）

#### PostgreSQL StatefulSet

```yaml
# k8s/database/postgresql-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgresql
spec:
  serviceName: postgresql
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: "staffjoy"
        - name: POSTGRES_USER
          value: "postgres"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: postgres-password
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        ports:
        - containerPort: 5432
          name: postgresql
        volumeMounts:
        - name: postgresql-data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
  volumeClaimTemplates:
  - metadata:
      name: postgresql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
    protocol: TCP
  selector:
    app: postgresql
```

## 📊 数据库初始化脚本

### 初始化脚本

```sql
-- k8s/database/init-schema.sql
-- PostgreSQL 初始化脚本

-- 创建数据库（如果不存在）
-- 注意：RDS 通常需要手动创建数据库

-- 创建 User Service Schema
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE USER user_service_user WITH PASSWORD 'change-me-in-production';
GRANT USAGE ON SCHEMA user_schema TO user_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
  GRANT ALL ON TABLES TO user_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema 
  GRANT ALL ON SEQUENCES TO user_service_user;

-- 创建 Shift Service Schema
CREATE SCHEMA IF NOT EXISTS shift_schema;
CREATE USER shift_service_user WITH PASSWORD 'change-me-in-production';
GRANT USAGE ON SCHEMA shift_schema TO shift_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
  GRANT ALL ON TABLES TO shift_service_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA shift_schema 
  GRANT ALL ON SEQUENCES TO shift_service_user;

-- 验证
\du  -- 列出所有用户
\dn  -- 列出所有 schema
```

## 🔄 迁移方案

### 从 H2 迁移到 PostgreSQL

#### 步骤 1: 导出 H2 数据（如果已有数据）

```bash
# 使用 H2 控制台导出
# http://localhost:8081/h2-console
# 执行 SQL 导出为 CSV 或 SQL 脚本
```

#### 步骤 2: 创建 PostgreSQL 数据库和 Schema

```bash
# 连接到 PostgreSQL
psql -h rm-xxxxx.pg.rds.aliyuncs.com -U postgres -d postgres

# 执行初始化脚本
\i k8s/database/init-schema.sql
```

#### 步骤 3: 更新应用配置

```yaml
# application-prod.yml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?currentSchema=${DB_SCHEMA}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update  # 首次迁移使用 update，之后改为 validate
    database-platform: org.hibernate.dialect.PostgreSQLDialect
```

#### 步骤 4: 使用 Flyway 或 Liquibase 管理迁移（推荐）

**添加 Flyway 依赖：**

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

**创建迁移脚本：**

```sql
-- db/migration/V1__create_user_table.sql
CREATE TABLE user_schema.users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔒 安全最佳实践

### 1. 使用 Secret 管理密码

```bash
# 创建 Secret
kubectl create secret generic postgresql-secret \
  --from-literal=user-db-password='secure-password' \
  --from-literal=shift-db-password='secure-password' \
  --namespace=production
```

### 2. 网络隔离

- 使用 VPC 内网访问数据库
- 配置安全组/防火墙规则
- 限制数据库访问 IP（K8s 节点 IP）

### 3. SSL/TLS 连接

```yaml
spring:
  datasource:
    url: jdbc:postgresql://...?ssl=true&sslmode=require
```

### 4. 连接池配置

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
```

## 📈 监控和运维

### 健康检查

```yaml
# Spring Boot Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  health:
    db:
      enabled: true
```

### 监控指标

- **连接数**: 当前连接数、最大连接数
- **查询性能**: 慢查询、QPS
- **资源使用**: CPU、内存、磁盘
- **复制延迟**: 主从复制延迟（如果使用）

### 备份策略

1. **自动备份**: 云服务商自动备份（每日）
2. **手动备份**: 重要操作前手动备份
3. **备份保留**: 保留 7-30 天
4. **跨区域备份**: 灾难恢复

## 💰 成本估算（阿里云）

| 规格 | CPU | 内存 | 存储 | 月费用（约） |
|-----|-----|------|------|------------|
| pg.n2.medium.1 | 2核 | 4GB | 20GB | ¥300-500 |
| pg.n2.large.1 | 4核 | 8GB | 50GB | ¥600-800 |
| pg.n2.xlarge.1 | 8核 | 16GB | 100GB | ¥1200-1500 |

## 🚀 快速开始

### 1. 创建云数据库实例

```bash
# 阿里云 RDS PostgreSQL
aliyun rds CreateDBInstance \
  --Engine PostgreSQL \
  --EngineVersion 15.0 \
  --DBInstanceClass pg.n2.medium.1 \
  --DBInstanceStorage 20
```

### 2. 初始化数据库

```bash
# 连接到数据库
psql -h rm-xxxxx.pg.rds.aliyuncs.com -U postgres

# 执行初始化脚本
\i k8s/database/init-schema.sql
```

### 3. 创建 Kubernetes Secret

```bash
kubectl apply -f k8s/secrets/postgresql-secret.yaml
```

### 4. 更新应用配置

```bash
# 更新 Deployment 使用 PostgreSQL
kubectl apply -f k8s/deployments/user-service-deployment.yaml
kubectl apply -f k8s/deployments/shift-service-deployment.yaml
```

## 📚 相关文档

- [PostgreSQL 官方文档](https://www.postgresql.org/docs/)
- [Spring Boot PostgreSQL](https://spring.io/guides/gs/accessing-data-postgresql/)
- [阿里云 RDS PostgreSQL](https://help.aliyun.com/product/26090.html)
- [HikariCP 配置](https://github.com/brettwooldridge/HikariCP)

