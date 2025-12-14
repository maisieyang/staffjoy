# PostgreSQL 数据库配置

## 📋 概述

本目录包含 PostgreSQL 数据库的 Kubernetes 配置和初始化脚本。

## 📁 文件说明

- `init-schema.sql` - 数据库初始化脚本（创建 Schema 和用户）
- `postgresql-statefulset.yaml` - Kubernetes StatefulSet 配置（自建 PostgreSQL）
- `README.md` - 本文档

## 🚀 快速开始

### 方案 1: 使用云托管 PostgreSQL（推荐生产环境）

#### 步骤 1: 创建云数据库实例

**阿里云 RDS PostgreSQL:**

```bash
aliyun rds CreateDBInstance \
  --Engine PostgreSQL \
  --EngineVersion 15.0 \
  --DBInstanceClass pg.n2.medium.1 \
  --DBInstanceStorage 20 \
  --DBInstanceDescription "Staffjoy PostgreSQL"
```

#### 步骤 2: 初始化数据库

```bash
# 连接到数据库
psql -h rm-xxxxx.pg.rds.aliyuncs.com -U postgres -d postgres

# 创建数据库
CREATE DATABASE staffjoy;

# 连接到新数据库
\c staffjoy

# 执行初始化脚本
\i init-schema.sql
```

#### 步骤 3: 配置白名单

在 RDS 控制台添加 K8s 节点 IP 到白名单。

#### 步骤 4: 创建 Secret

```bash
# 更新 k8s/secrets/postgresql-secret.yaml 中的数据库地址和密码
kubectl apply -f ../secrets/postgresql-secret.yaml
```

#### 步骤 5: 部署应用

```bash
# 使用 PostgreSQL 版本的 Deployment
kubectl apply -f ../deployments/user-service-deployment-postgresql.yaml
kubectl apply -f ../deployments/shift-service-deployment-postgresql.yaml
```

### 方案 2: Kubernetes StatefulSet（自建 PostgreSQL）

#### 步骤 1: 创建 Secret

```bash
kubectl apply -f ../secrets/postgresql-secret.yaml
```

#### 步骤 2: 部署 PostgreSQL

```bash
kubectl apply -f postgresql-statefulset.yaml
```

#### 步骤 3: 等待 PostgreSQL 就绪

```bash
kubectl wait --for=condition=ready pod -l app=postgresql --timeout=120s
```

#### 步骤 4: 初始化数据库

```bash
# 获取 PostgreSQL Pod 名称
POD_NAME=$(kubectl get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}')

# 复制初始化脚本到 Pod
kubectl cp init-schema.sql $POD_NAME:/tmp/init-schema.sql

# 执行初始化脚本
kubectl exec -it $POD_NAME -- psql -U postgres -d staffjoy -f /tmp/init-schema.sql
```

#### 步骤 5: 部署应用

```bash
# 更新 Secret 中的 db-host 为 postgresql（Service 名称）
kubectl apply -f ../secrets/postgresql-secret.yaml

# 部署应用
kubectl apply -f ../deployments/user-service-deployment-postgresql.yaml
kubectl apply -f ../deployments/shift-service-deployment-postgresql.yaml
```

## 🔍 验证

### 检查 PostgreSQL 状态

```bash
# 查看 Pod
kubectl get pods -l app=postgresql

# 查看日志
kubectl logs -l app=postgresql

# 测试连接
kubectl exec -it <postgresql-pod> -- psql -U postgres -d staffjoy
```

### 检查应用连接

```bash
# 查看应用日志
kubectl logs -f deployment/user-service | grep -i database
kubectl logs -f deployment/shift-service | grep -i database

# 检查健康状态
kubectl get pods -l app=user-service
kubectl get pods -l app=shift-service
```

## 🔧 配置说明

### Schema 设计

- **user_schema**: User Service 数据
- **shift_schema**: Shift Service 数据

### 用户权限

- **user_service_user**: 只能访问 user_schema
- **shift_service_user**: 只能访问 shift_schema

### 连接池配置

生产环境推荐配置（在 application-prod.yml 中）：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
```

## 🔒 安全建议

1. **使用 Secret 管理密码**：不要将密码硬编码在配置文件中
2. **网络隔离**：使用 VPC 内网访问数据库
3. **SSL 连接**：生产环境启用 SSL/TLS
4. **最小权限**：每个服务使用独立用户，只授予必要权限
5. **定期轮换密码**：定期更新数据库密码

## 📚 相关文档

- [PostgreSQL 设置指南](../../docs/POSTGRESQL_SETUP.md)
- [云数据库策略](../../docs/CLOUD_DATABASE_STRATEGY.md)

