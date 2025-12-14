# Docker 容器化指南

## 📦 概述

本项目已完全容器化，使用 Docker 和 Docker Compose 来管理和运行所有微服务。

## 🏗️ 架构说明

### Docker 文件结构

```
staffjoy/
├── eureka-server/Dockerfile      # Eureka Server 容器化配置
├── config-server/Dockerfile       # Config Server 容器化配置
├── user-service/Dockerfile        # User Service 容器化配置
├── shift-service/Dockerfile       # Shift Service 容器化配置
├── api-gateway/Dockerfile         # API Gateway 容器化配置
├── docker-compose.yml             # Docker Compose 编排文件
└── .dockerignore                  # Docker 构建忽略文件
```

### 多阶段构建

所有 Dockerfile 都采用**多阶段构建**（Multi-stage Build）模式：

1. **构建阶段**：使用 `maven:3.9-eclipse-temurin-21` 镜像
   - 编译源代码
   - 打包 JAR 文件
   - 利用 Docker 缓存层优化构建速度

2. **运行阶段**：使用 `eclipse-temurin:21-jre-alpine` 镜像
   - 仅包含 JRE（不包含 JDK 和 Maven）
   - Alpine Linux（体积小，约 5MB）
   - 非 root 用户运行（安全最佳实践）

### 服务依赖关系

```
eureka-server (必须先启动)
    ↓
config-server (可选)
    ↓
user-service ──┐
    ↓          │
shift-service ─┼──→ api-gateway
```

## 🚀 快速开始

### 前置要求

- Docker Desktop（Mac/Windows）或 Docker Engine（Linux）
- Docker Compose（通常已包含在 Docker Desktop 中）

### 启动所有服务

```bash
# 在项目根目录下执行

# 1. 构建并启动所有服务（前台运行，可以看到日志）
docker-compose up --build

# 2. 或者后台运行
docker-compose up -d --build

# 3. 查看服务状态
docker-compose ps

# 4. 查看所有服务日志
docker-compose logs -f

# 5. 查看特定服务日志
docker-compose logs -f user-service
docker-compose logs -f eureka-server
```

### 停止服务

```bash
# 停止所有服务（保留容器）
docker-compose stop

# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷
docker-compose down -v
```

## 🔍 验证服务

### 1. 检查服务状态

```bash
# 查看所有容器状态
docker-compose ps

# 应该看到所有服务都是 "Up" 状态
```

### 2. 访问服务

- **Eureka Server**: http://localhost:8761
- **Config Server**: http://localhost:8888
- **API Gateway**: http://localhost:8080
- **User Service**: http://localhost:8081
- **Shift Service**: http://localhost:8082

### 3. 验证服务注册

访问 Eureka Server：http://localhost:8761

你应该能看到以下服务已注册：
- `USER-SERVICE`
- `SHIFT-SERVICE`
- `API-GATEWAY`
- `CONFIG-SERVER`（如果启用）

### 4. 测试 API

```bash
# 通过 API Gateway 创建用户
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "phone": "13800138000"
  }'

# 获取所有用户
curl http://localhost:8080/api/users
```

## 🛠️ 常用命令

### 构建镜像

```bash
# 构建所有服务的镜像
docker-compose build

# 构建特定服务的镜像
docker-compose build user-service

# 强制重新构建（不使用缓存）
docker-compose build --no-cache
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs

# 实时跟踪日志
docker-compose logs -f

# 查看最近 100 行日志
docker-compose logs --tail=100

# 查看特定服务日志
docker-compose logs -f user-service
```

### 进入容器

```bash
# 进入 user-service 容器
docker-compose exec user-service sh

# 进入 eureka-server 容器
docker-compose exec eureka-server sh
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart user-service
```

### 扩展服务实例

```bash
# 启动 3 个 user-service 实例（用于负载均衡测试）
docker-compose up -d --scale user-service=3

# 查看扩展后的服务
docker-compose ps
```

## 🔧 配置说明

### 环境变量

Docker Compose 通过环境变量覆盖服务配置：

- `SPRING_APPLICATION_NAME`: 应用名称
- `EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE`: Eureka Server 地址
- `EUREKA_INSTANCE_PREFER_IP_ADDRESS`: 使用 IP 地址注册
- `EUREKA_INSTANCE_INSTANCE_ID`: 服务实例 ID

### 网络配置

所有服务运行在 `staffjoy-network` 网络中，可以通过服务名互相访问：
- `eureka-server:8761`
- `user-service:8081`
- `shift-service:8082`
- `api-gateway:8080`

### 健康检查

每个服务都配置了健康检查：

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:8081/actuator/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

## 🐛 故障排查

### 服务无法启动

1. **检查端口占用**
   ```bash
   # Mac/Linux
   lsof -i :8080
   
   # 或者使用 Docker
   docker-compose ps
   ```

2. **查看日志**
   ```bash
   docker-compose logs [service-name]
   ```

3. **检查 Eureka Server**
   - 确保 Eureka Server 先启动
   - 访问 http://localhost:8761 确认服务已启动

### 服务无法注册到 Eureka

1. **检查网络连接**
   ```bash
   # 进入容器测试网络
   docker-compose exec user-service wget -O- http://eureka-server:8761
   ```

2. **检查环境变量**
   ```bash
   docker-compose exec user-service env | grep EUREKA
   ```

3. **查看 Eureka 日志**
   ```bash
   docker-compose logs eureka-server
   ```

### 构建失败

1. **清理并重新构建**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up
   ```

2. **检查 Maven 依赖**
   ```bash
   # 在本地先测试构建
   mvn clean package -DskipTests
   ```

## 📊 性能优化

### 1. 使用构建缓存

Dockerfile 已经优化了构建顺序：
- 先复制 `pom.xml` 并下载依赖（利用缓存）
- 再复制源代码并编译

### 2. 多阶段构建

- 构建镜像：包含 Maven 和 JDK（较大）
- 运行镜像：仅包含 JRE（较小）

### 3. Alpine 基础镜像

使用 Alpine Linux 可以显著减小镜像体积：
- 标准 JRE 镜像：~200MB
- Alpine JRE 镜像：~150MB

## 🔐 安全最佳实践

1. **非 root 用户运行**
   - 所有服务都以非 root 用户（spring）运行
   - 降低安全风险

2. **最小权限原则**
   - 只暴露必要的端口
   - 使用健康检查而非直接访问

3. **镜像扫描**
   ```bash
   # 使用 Docker Scout 扫描镜像（如果可用）
   docker scout cves [image-name]
   ```

## 📚 进一步学习

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Spring Boot Docker 指南](https://spring.io/guides/gs/spring-boot-docker/)

## 🎯 下一步

完成容器化后，可以继续：
- Kubernetes 部署（阶段6）
- CI/CD 集成
- 生产环境优化

