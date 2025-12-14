# 云原生数据库方案设计

## 📊 当前状态分析

### 现状

- **数据库类型**: H2 内存数据库
- **使用场景**: 开发/测试环境
- **数据持久化**: ❌ 无（重启后数据丢失）
- **高可用**: ❌ 不支持
- **服务**: 
  - `user-service`: `jdbc:h2:mem:userdb`
  - `shift-service`: `jdbc:h2:mem:shiftdb`

### 问题

1. **数据持久化**: H2 内存数据库重启后数据丢失
2. **生产环境**: 不适合生产环境使用
3. **高可用**: 不支持主从复制、故障转移
4. **性能**: 内存限制，无法处理大规模数据
5. **备份恢复**: 无备份机制

## 🎯 云原生数据库方案

### 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|-----|------|------|---------|
| **云托管数据库** | 高可用、自动备份、监控完善、运维简单 | 成本较高、供应商锁定 | 生产环境推荐 |
| **Kubernetes StatefulSet** | 灵活、可移植、成本可控 | 需要自行运维、配置复杂 | 开发/测试环境 |
| **外部数据库服务** | 简单、快速 | 需要网络配置、可能延迟 | 混合云场景 |

## 🏗️ 架构设计方案

### 方案 1: 单数据库实例（推荐用于中小型项目）

```
┌─────────────────┐
│  User Service   │──┐
└─────────────────┘  │
                     ├──► MySQL/PostgreSQL (单实例)
┌─────────────────┐  │      (云托管数据库)
│ Shift Service   │──┘
└─────────────────┘
```

**特点：**
- ✅ 简单易维护
- ✅ 成本较低
- ✅ 适合中小型项目
- ⚠️ 单点故障风险

### 方案 2: 服务独立数据库（推荐用于大型项目）

```
┌─────────────────┐
│  User Service   │──► MySQL/PostgreSQL (user-db)
└─────────────────┘
                     
┌─────────────────┐
│ Shift Service   │──► MySQL/PostgreSQL (shift-db)
└─────────────────┘
```

**特点：**
- ✅ 服务解耦
- ✅ 独立扩展
- ✅ 故障隔离
- ⚠️ 成本较高
- ⚠️ 跨服务查询复杂

### 方案 3: 读写分离 + 主从复制

```
┌─────────────────┐
│  User Service   │──┐
└─────────────────┘  │
                     ├──► Master DB (写)
┌─────────────────┐  │      │
│ Shift Service   │──┘      │
└─────────────────┘         │
                            ▼
                     Slave DB (读)
```

**特点：**
- ✅ 高可用
- ✅ 读写分离提升性能
- ✅ 自动故障转移
- ⚠️ 配置复杂
- ⚠️ 数据一致性需要考虑

## ☁️ 云服务商数据库方案

### 阿里云

#### RDS MySQL

**特点：**
- 高可用版（主从架构）
- 自动备份和恢复
- 监控告警
- 读写分离
- 白名单安全控制

**配置示例：**
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://rm-xxxxx.mysql.rds.aliyuncs.com:3306/staffjoy?useSSL=true&serverTimezone=Asia/Shanghai
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
```

#### PolarDB（推荐）

**特点：**
- 云原生数据库
- 计算存储分离
- 自动扩缩容
- 兼容 MySQL/PostgreSQL
- 更高性能

### AWS

#### RDS MySQL/PostgreSQL

**特点：**
- Multi-AZ 高可用
- 自动备份
- 只读副本
- 性能洞察

**配置示例：**
```yaml
spring:
  datasource:
    url: jdbc:mysql://staffjoy-db.xxxxx.us-east-1.rds.amazonaws.com:3306/staffjoy
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

### Google Cloud

#### Cloud SQL

**特点：**
- 完全托管
- 自动备份
- 高可用配置
- 读写副本

**配置示例：**
```yaml
spring:
  datasource:
    url: jdbc:mysql:///staffjoy?cloudSqlInstance=PROJECT_ID:REGION:INSTANCE_NAME&socketFactory=com.google.cloud.sql.mysql.SocketFactory
```

### 腾讯云

#### TencentDB for MySQL

**特点：**
- 主从高可用
- 自动备份
- 监控告警
- 读写分离

## 🐳 Kubernetes 集成方案

### 方案 A: 使用云托管数据库（推荐）

**优点：**
- 无需在 K8s 中管理数据库
- 高可用和备份由云服务商负责
- 性能优化和监控完善

**配置步骤：**

1. **创建云数据库实例**
   ```bash
   # 阿里云示例
   aliyun rds CreateDBInstance \
     --Engine MySQL \
     --EngineVersion 8.0 \
     --DBInstanceClass mysql.n2.medium.1 \
     --DBInstanceStorage 20
   ```

2. **配置白名单**
   - 添加 K8s 节点 IP 到数据库白名单
   - 或使用 VPC 内网访问

3. **创建 Secret**
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: database-secret
   type: Opaque
   stringData:
     database-url: "jdbc:mysql://rm-xxxxx.mysql.rds.aliyuncs.com:3306/staffjoy"
     database-username: "staffjoy_user"
     database-password: "secure-password"
   ```

4. **更新 Deployment**
   ```yaml
   env:
   - name: SPRING_DATASOURCE_URL
     valueFrom:
       secretKeyRef:
         name: database-secret
         key: database-url
   - name: SPRING_DATASOURCE_USERNAME
     valueFrom:
       secretKeyRef:
         name: database-secret
         key: database-username
   - name: SPRING_DATASOURCE_PASSWORD
     valueFrom:
       secretKeyRef:
         name: database-secret
         key: database-password
   ```

### 方案 B: Kubernetes StatefulSet（自建数据库）

**适用场景：**
- 开发/测试环境
- 需要完全控制数据库
- 成本敏感

**配置示例：**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        - name: MYSQL_DATABASE
          value: "staffjoy"
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
```

## 🔧 配置管理策略

### 环境分离

```yaml
# application-dev.yml (开发环境)
spring:
  datasource:
    url: jdbc:h2:mem:userdb  # H2 内存数据库

# application-test.yml (测试环境)
spring:
  datasource:
    url: jdbc:mysql://test-db:3306/staffjoy

# application-prod.yml (生产环境)
spring:
  datasource:
    url: ${DB_URL}  # 从环境变量或 Secret 读取
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

### 使用 ConfigMap 和 Secret

```yaml
# ConfigMap (非敏感配置)
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
data:
  database-name: "staffjoy"
  connection-timeout: "30000"
  max-pool-size: "20"

# Secret (敏感信息)
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
type: Opaque
stringData:
  database-url: "jdbc:mysql://..."
  database-username: "user"
  database-password: "password"
```

## 📈 连接池配置

### HikariCP（Spring Boot 默认）

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20        # 最大连接数
      minimum-idle: 5               # 最小空闲连接
      connection-timeout: 30000     # 连接超时（毫秒）
      idle-timeout: 600000          # 空闲连接超时
      max-lifetime: 1800000          # 连接最大生命周期
      leak-detection-threshold: 60000 # 连接泄漏检测
```

### 连接池大小计算

```
连接池大小 = ((核心数 * 2) + 有效磁盘数)
```

**示例：**
- 4 核 CPU，1 个磁盘：`(4 * 2) + 1 = 9`
- 建议范围：10-20 个连接

## 🔒 安全最佳实践

### 1. 使用 Secret 管理密码

```bash
# 创建 Secret
kubectl create secret generic database-secret \
  --from-literal=password='secure-password' \
  --namespace=production

# 使用 Sealed Secrets（推荐）
# 加密 Secret，可以安全地提交到 Git
```

### 2. 网络隔离

- 使用 VPC 内网访问数据库
- 配置安全组/防火墙规则
- 限制数据库访问 IP

### 3. SSL/TLS 连接

```yaml
spring:
  datasource:
    url: jdbc:mysql://...?useSSL=true&requireSSL=true
```

### 4. 最小权限原则

- 为每个服务创建独立的数据库用户
- 只授予必要的权限
- 定期轮换密码

## 📊 监控和运维

### 健康检查

```yaml
# Kubernetes Liveness Probe
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD"
  initialDelaySeconds: 30
  periodSeconds: 10

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

## 🚀 迁移方案

### 从 H2 迁移到云数据库

#### 步骤 1: 准备数据库

```sql
-- 创建数据库
CREATE DATABASE staffjoy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER 'staffjoy_user'@'%' IDENTIFIED BY 'secure-password';
GRANT ALL PRIVILEGES ON staffjoy.* TO 'staffjoy_user'@'%';
FLUSH PRIVILEGES;
```

#### 步骤 2: 导出 H2 数据（如果已有数据）

```bash
# 使用 H2 控制台导出数据
# http://localhost:8081/h2-console
# 执行 SQL 导出
```

#### 步骤 3: 更新配置

```yaml
# application-prod.yml
spring:
  datasource:
    url: jdbc:mysql://rm-xxxxx.mysql.rds.aliyuncs.com:3306/staffjoy
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate  # 生产环境使用 validate，不使用 update
    database-platform: org.hibernate.dialect.MySQLDialect
```

#### 步骤 4: 添加 MySQL 依赖

```xml
<!-- pom.xml -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <scope>runtime</scope>
</dependency>
```

#### 步骤 5: 执行迁移

```bash
# 使用 Flyway 或 Liquibase 进行数据库迁移
# 或使用 Hibernate ddl-auto=update（仅开发环境）
```

## 💰 成本估算

### 阿里云 RDS MySQL

| 规格 | CPU | 内存 | 存储 | 月费用（约） |
|-----|-----|------|------|------------|
| mysql.n2.medium.1 | 2核 | 4GB | 20GB | ¥300-500 |
| mysql.n2.large.1 | 4核 | 8GB | 50GB | ¥600-800 |
| mysql.n2.xlarge.1 | 8核 | 16GB | 100GB | ¥1200-1500 |

### 自建数据库（Kubernetes）

- **ECS 成本**: ¥200-500/月
- **存储成本**: ¥50-100/月
- **运维成本**: 时间成本

## 📋 推荐方案

### 开发环境
- ✅ **H2 内存数据库**（当前方案）
- 快速启动，无需额外配置

### 测试环境
- ✅ **Kubernetes StatefulSet + MySQL**
- 或使用云数据库低配版本

### 生产环境
- ✅ **云托管数据库（RDS/PolarDB）**
- 高可用配置
- 自动备份
- 监控告警

## 🔗 相关文档

- [Spring Boot 数据库配置](https://spring.io/guides/gs/accessing-data-mysql/)
- [HikariCP 配置](https://github.com/brettwooldridge/HikariCP)
- [阿里云 RDS 文档](https://help.aliyun.com/product/26090.html)
- [Kubernetes StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

