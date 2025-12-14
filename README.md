# Staffjoy 学习项目

这是一个从零开始学习 Spring Boot、微服务和 Kubernetes 的项目。我们将逐步构建一个类似 Staffjoy 的员工排班应用。

## 📚 学习路径

### 阶段1：基础 Spring Boot 单体应用 ✅
- [x] 创建 Spring Boot 项目
- [x] 实现用户管理功能（CRUD）
- [x] 使用 H2 内存数据库
- [x] RESTful API 设计

### 阶段2：数据库和业务逻辑 ✅
- [x] 添加 MySQL 数据库支持
- [x] 实现排班（Shift）功能
- [x] 实现公司（Company）功能
- [x] 添加数据关联关系

### 阶段3：微服务拆分 ✅
- [x] 拆分为用户服务（User Service）
- [x] 拆分为排班服务（Shift Service）
- [x] 创建 API 网关（API Gateway）

### 阶段4：服务发现和配置 ✅
- [x] 集成 Eureka 服务发现
- [x] 配置中心（Spring Cloud Config）
- [x] 服务间通信（Feign Client）

### 阶段5：容器化 ✅
- [x] Docker 化所有服务
- [x] Docker Compose 本地开发环境

### 阶段6：Kubernetes 部署 ✅
- [x] K8s Deployment 配置
- [x] Service 和 Ingress 配置
- [x] ConfigMap 和 Secret
- [x] 生产环境部署配置

## 🚀 快速开始

### 前置要求
- JDK 21 或更高版本
- Maven 3.8 或更高版本
- Docker 和 Docker Compose（用于容器化部署）

### 📖 架构说明

**想了解微服务架构的详细说明？** 请查看：
- [微服务架构说明文档](docs/MICROSERVICES_ARCHITECTURE.md)
- [服务注册发现与配置中心：第一性原理解析](docs/SERVICE_DISCOVERY_AND_CONFIG.md) ⭐
- [HTTP vs RPC：跨微服务调用的第一性原理解析](docs/HTTP_VS_RPC.md) ⭐
- [Docker 容器化指南](docs/DOCKER_GUIDE.md) 🐳
- [Kubernetes 部署指南（通用）](k8s/README.md) ☸️
- [阿里云 ACK 部署指南](k8s/alibaba-cloud/README.md) ☁️
- [部署方式对比说明](k8s/DEPLOYMENT_COMPARISON.md) 📊 **新增**

**文档内容：**
- 项目结构和各模块关系
- 服务间的协作方式
- 启动顺序和步骤
- 数据流示例
- **服务注册发现和配置中心解决的问题（第一性原理）**
- **实现方案对比和项目中的具体实现**
- **HTTP 和 RPC 的本质区别和选择原则**
- **Docker 容器化实践和最佳实践**
- **Kubernetes 部署配置和生产环境最佳实践**

### 微服务架构

项目已拆分为多个微服务：

```
staffjoy/
├── user-service/      # 用户服务 (端口: 8081)
├── shift-service/     # 排班服务 (端口: 8082)
└── api-gateway/       # API 网关 (端口: 8080)
```

### 运行应用

**重要：启动顺序很重要！**

#### 方式1：使用 Docker Compose（推荐，最简单）🐳

这是最简单的方式，一键启动所有服务：

```bash
# 1. 确保 Docker 和 Docker Compose 已安装并运行
docker --version
docker-compose --version

# 2. 在项目根目录下构建并启动所有服务
docker-compose up --build

# 或者后台运行
docker-compose up -d --build

# 3. 查看服务状态
docker-compose ps

# 4. 查看日志
docker-compose logs -f [service-name]  # 例如：docker-compose logs -f user-service

# 5. 停止所有服务
docker-compose down

# 6. 停止并删除所有数据（包括卷）
docker-compose down -v
```

**Docker Compose 会自动处理：**
- ✅ 服务启动顺序（Eureka → Config → Services → Gateway）
- ✅ 服务间网络通信
- ✅ 健康检查
- ✅ 服务发现配置

**访问地址（与本地运行相同）：**
- Eureka Server: http://localhost:8761
- Config Server: http://localhost:8888
- API Gateway: http://localhost:8080
- User Service: http://localhost:8081
- Shift Service: http://localhost:8082

#### 方式2：分别运行各个服务（推荐用于开发）

```bash
# 1. 编译整个项目
mvn clean install

# 2. 启动 Eureka Server（服务发现中心）- 必须先启动
cd eureka-server
mvn spring-boot:run
# 服务将在 http://localhost:8761 启动
# 等待看到 "Started EurekaServerApplication" 日志

# 3. 启动 Config Server（配置中心，可选）- 新终端窗口
cd config-server
mvn spring-boot:run
# 服务将在 http://localhost:8888 启动
# 注意：Config Server 是可选的，默认使用本地配置

# 4. 启动用户服务 - 新终端窗口
cd user-service
mvn spring-boot:run
# 服务将在 http://localhost:8081 启动
# 会自动注册到 Eureka Server

# 5. 启动排班服务 - 新终端窗口
cd shift-service
mvn spring-boot:run
# 服务将在 http://localhost:8082 启动
# 会自动注册到 Eureka Server

# 6. 启动 API 网关 - 新终端窗口
cd api-gateway
mvn spring-boot:run
# 网关将在 http://localhost:8080 启动
# 会自动注册到 Eureka Server，并使用服务发现路由
```

#### 方式3：使用 Maven 并行运行（需要多个终端）

```bash
# 在项目根目录下，分别在不同终端运行：
# 终端1：Eureka Server（必须先启动）
mvn -pl eureka-server spring-boot:run

# 终端2：Config Server（可选）
mvn -pl config-server spring-boot:run

# 终端3：User Service
mvn -pl user-service spring-boot:run

# 终端4：Shift Service
mvn -pl shift-service spring-boot:run

# 终端5：API Gateway
mvn -pl api-gateway spring-boot:run
```

### 访问应用

- **Eureka Server**: http://localhost:8761（服务注册中心，查看所有注册的服务）
- **Config Server**: http://localhost:8888（配置中心，查看配置信息）
- **API 网关**: http://localhost:8080（统一入口）
- **用户服务**: http://localhost:8081（直接访问）
- **排班服务**: http://localhost:8082（直接访问）

#### 验证服务发现

访问 Eureka Server 控制台：http://localhost:8761

你应该能看到以下服务已注册：
- `USER-SERVICE` (用户服务)
- `SHIFT-SERVICE` (排班服务)
- `API-GATEWAY` (API 网关)

#### H2 数据库控制台

- **用户服务数据库**: http://localhost:8081/h2-console
  - JDBC URL: `jdbc:h2:mem:userdb`
  - 用户名: `sa`
  - 密码: (留空)

- **排班服务数据库**: http://localhost:8082/h2-console
  - JDBC URL: `jdbc:h2:mem:shiftdb`
  - 用户名: `sa`
  - 密码: (留空)

## 📡 API 端点

### 公司管理 API

#### 获取所有公司
```bash
GET http://localhost:8080/api/companies
```

#### 获取指定公司
```bash
GET http://localhost:8080/api/companies/{id}
```

#### 创建公司
```bash
POST http://localhost:8080/api/companies
Content-Type: application/json

{
  "name": "示例公司",
  "legalName": "示例科技有限公司",
  "description": "这是一家示例公司",
  "website": "https://example.com",
  "phoneNumber": "400-123-4567",
  "address": "北京市朝阳区示例街道123号"
}
```

#### 更新公司
```bash
PUT http://localhost:8080/api/companies/{id}
Content-Type: application/json

{
  "name": "更新后的公司名称",
  "description": "更新后的描述"
}
```

#### 删除公司
```bash
DELETE http://localhost:8080/api/companies/{id}
```

### 排班管理 API

#### 获取所有排班
```bash
GET http://localhost:8080/api/shifts
```

#### 获取指定排班
```bash
GET http://localhost:8080/api/shifts/{id}
```

#### 获取指定用户的所有排班
```bash
GET http://localhost:8080/api/shifts/user/{userId}
```

#### 获取指定公司的所有排班
```bash
GET http://localhost:8080/api/shifts/company/{companyId}
```

#### 获取指定时间范围内的排班
```bash
GET http://localhost:8080/api/shifts/between?startTime=2024-01-01T00:00:00&stopTime=2024-01-31T23:59:59
```

#### 创建排班
```bash
POST http://localhost:8080/api/shifts
Content-Type: application/json

{
  "user": {
    "id": 1
  },
  "company": {
    "id": 1
  },
  "startTime": "2024-01-15T09:00:00",
  "stopTime": "2024-01-15T17:00:00",
  "published": false
}
```

#### 更新排班
```bash
PUT http://localhost:8080/api/shifts/{id}
Content-Type: application/json

{
  "startTime": "2024-01-15T10:00:00",
  "stopTime": "2024-01-15T18:00:00",
  "published": true
}
```

#### 删除排班
```bash
DELETE http://localhost:8080/api/shifts/{id}
```

### 用户管理 API

#### 获取所有用户
```bash
GET http://localhost:8080/api/users
```

#### 获取指定用户
```bash
GET http://localhost:8080/api/users/{id}
```

#### 创建用户
```bash
POST http://localhost:8080/api/users
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "name": "John Doe",
  "phoneNumber": "13800138000"
}
```

#### 更新用户
```bash
PUT http://localhost:8080/api/users/{id}
Content-Type: application/json

{
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

#### 删除用户
```bash
DELETE http://localhost:8080/api/users/{id}
```

#### 健康检查
```bash
GET http://localhost:8080/api/users/health
```

## 🧪 测试 API

使用 curl 或 Postman 测试：

```bash
# 创建用户
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "email": "test@example.com",
    "name": "Test User",
    "phoneNumber": "13800138000"
  }'

# 获取所有用户
curl http://localhost:8080/api/users

# 获取指定用户（替换 {id} 为实际ID）
curl http://localhost:8080/api/users/1
```

## 📁 项目结构

```
staffjoy/
├── pom.xml                                 # 父 POM（多模块管理）
├── user-service/                           # 用户服务模块
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/staffjoy/user/
│       │   ├── UserServiceApplication.java
│       │   ├── controller/
│       │   │   └── UserController.java
│       │   ├── service/
│       │   │   └── UserService.java
│       │   ├── repository/
│       │   │   └── UserRepository.java
│       │   └── model/
│       │       └── User.java
│       └── resources/
│           └── application.yml
├── shift-service/                          # 排班服务模块
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/staffjoy/shift/
│       │   ├── ShiftServiceApplication.java
│       │   ├── controller/
│       │   │   ├── CompanyController.java
│       │   │   └── ShiftController.java
│       │   ├── service/
│       │   │   ├── CompanyService.java
│       │   │   └── ShiftService.java
│       │   ├── repository/
│       │   │   ├── CompanyRepository.java
│       │   │   └── ShiftRepository.java
│       │   └── model/
│       │       ├── Company.java
│       │       └── Shift.java
│       └── resources/
│           └── application.yml
└── api-gateway/                            # API 网关模块
    ├── pom.xml
    └── src/main/
        ├── java/com/staffjoy/gateway/
        │   └── ApiGatewayApplication.java
        └── resources/
            └── application.yml
```

## 🎯 当前阶段说明

**阶段1：基础单体应用** ✅

我们已经完成了：
1. ✅ Spring Boot 项目基础结构
2. ✅ 用户实体（User）和数据模型
3. ✅ 数据访问层（Repository）
4. ✅ 业务逻辑层（Service）
5. ✅ REST API 控制器（Controller）
6. ✅ H2 内存数据库配置

**阶段2：数据库和业务逻辑** ✅

我们已经完成了：
1. ✅ 添加 MySQL 数据库支持（pom.xml 和 application.yml 已配置）
2. ✅ 公司实体（Company）及完整的 CRUD 功能
3. ✅ 排班实体（Shift）及完整的 CRUD 功能
4. ✅ 实体间的关联关系：
   - User ↔ Company（多对一：多个用户属于一个公司）
   - User ↔ Shift（一对多：一个用户有多个排班）
   - Company ↔ Shift（一对多：一个公司有多个排班）
5. ✅ 复杂的查询功能（按用户、公司、时间范围查询排班）

**阶段3：微服务拆分** ✅

我们已经完成了：
1. ✅ 将单体应用拆分为多模块 Maven 项目
2. ✅ 创建用户服务（user-service，端口 8081）
   - 独立的数据库（userdb）
   - 移除了对 Company 和 Shift 的直接 JPA 关联
   - 使用 companyId 作为外键引用（跨服务引用）
3. ✅ 创建排班服务（shift-service，端口 8082）
   - 独立的数据库（shiftdb）
   - 包含 Company 和 Shift 实体
   - 移除了对 User 的直接 JPA 关联，使用 userId 引用
4. ✅ 创建 API 网关（api-gateway，端口 8080）
   - 使用 Spring Cloud Gateway
   - 统一入口，路由到各个微服务
   - 配置了 CORS 支持

**微服务架构特点：**
- **服务独立**: 每个服务有独立的数据库和端口
- **跨服务引用**: 通过 ID 引用其他服务的实体，不建立 JPA 关联
- **API 网关**: 统一入口，简化客户端调用
- **服务解耦**: 服务之间通过 HTTP API 通信

**核心概念学习：**
- **微服务架构**: 将单体应用拆分为多个独立服务
- **API 网关**: 统一入口，路由和负载均衡
- **服务间通信**: 通过 REST API 进行服务间调用
- **数据隔离**: 每个服务拥有独立的数据库
- **跨服务引用**: 使用 ID 而非 JPA 关联

**阶段4：服务发现和配置** ✅

我们已经完成了：
1. ✅ 创建 Eureka Server（eureka-server，端口 8761）
   - 服务注册中心
   - 所有微服务自动注册到这里
   - 提供服务发现功能

2. ✅ 集成 Eureka Client
   - user-service、shift-service、api-gateway 都已集成
   - 服务启动后自动注册到 Eureka Server
   - API Gateway 使用服务发现动态路由（`lb://service-name`）

3. ✅ 实现服务间通信（Feign Client）
   - shift-service 使用 Feign Client 调用 user-service
   - 验证用户是否存在（创建排班时）
   - 自动从 Eureka 获取服务地址

4. ✅ 创建 Config Server（config-server，端口 8888）
   - 集中管理所有微服务的配置
   - 支持从本地文件系统读取配置
   - 各服务可配置为 Config Client（可选）

**服务发现架构特点：**
- **动态服务发现**: 服务通过服务名而非硬编码地址通信
- **负载均衡**: Gateway 使用 `lb://` 前缀自动负载均衡
- **服务注册**: 服务启动时自动注册，下线时自动注销
- **健康检查**: Eureka 定期检查服务健康状态

**服务间通信特点：**
- **Feign Client**: 声明式 HTTP 客户端，简化服务调用
- **自动服务发现**: Feign 自动从 Eureka 获取服务地址
- **类型安全**: 使用接口定义，编译时检查

**配置中心特点：**
- **集中管理**: 所有配置集中在 Config Server
- **环境隔离**: 支持不同环境（dev、test、prod）的配置
- **动态刷新**: 支持配置热更新（需要配合 Spring Cloud Bus）

### 阶段5：容器化 ✅

我们已经完成了：
1. ✅ 为所有服务创建 Dockerfile
   - 使用多阶段构建（构建阶段 + 运行阶段）
   - 基于 Eclipse Temurin 21 JRE（Alpine 镜像，体积小）
   - 非 root 用户运行（安全最佳实践）

2. ✅ 创建 Docker Compose 配置
   - 一键启动所有服务
   - 自动处理服务依赖和启动顺序
   - 配置服务间网络通信
   - 健康检查机制

3. ✅ 容器化架构特点
   - **隔离性**: 每个服务运行在独立容器中
   - **可移植性**: 一次构建，到处运行
   - **可扩展性**: 轻松扩展服务实例数量
   - **环境一致性**: 开发、测试、生产环境一致

**Docker 文件结构：**
```
staffjoy/
├── eureka-server/Dockerfile
├── config-server/Dockerfile
├── user-service/Dockerfile
├── shift-service/Dockerfile
├── api-gateway/Dockerfile
├── docker-compose.yml          # Docker Compose 编排文件
└── .dockerignore               # Docker 构建忽略文件
```

**使用 Docker Compose 启动：**
```bash
# 构建并启动所有服务
docker-compose up --build

# 后台运行
docker-compose up -d --build

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f [service-name]

# 停止所有服务
docker-compose down
```

### 阶段6：Kubernetes 部署 ✅

我们已经完成了：
1. ✅ 创建 Kubernetes Deployment 配置
   - 为所有服务创建了 Deployment 配置
   - 配置了资源限制、健康检查、副本数等
   - 支持多副本部署以实现高可用

2. ✅ 创建 Service 和 Ingress 配置
   - 为所有服务创建了 Service（ClusterIP）
   - API Gateway 使用 LoadBalancer 类型
   - 配置了 Ingress 用于外部访问

3. ✅ 创建 ConfigMap 和 Secret
   - ConfigMap 存储非敏感配置
   - Secret 存储敏感信息（数据库密码等）
   - 支持配置与代码分离

4. ✅ 生产环境部署配置
   - 提供了完整的部署文档和脚本
   - 包含高可用、监控、安全等最佳实践建议

**Kubernetes 文件结构：**
```
k8s/
├── deployments/          # Deployment 配置
│   ├── eureka-server-deployment.yaml
│   ├── config-server-deployment.yaml
│   ├── user-service-deployment.yaml
│   ├── shift-service-deployment.yaml
│   └── api-gateway-deployment.yaml
├── services/            # Service 配置
│   ├── eureka-server-service.yaml
│   ├── config-server-service.yaml
│   ├── user-service-service.yaml
│   ├── shift-service-service.yaml
│   └── api-gateway-service.yaml
├── configmaps/          # ConfigMap 配置
│   ├── eureka-config.yaml
│   ├── user-service-config.yaml
│   ├── shift-service-config.yaml
│   └── api-gateway-config.yaml
├── secrets/             # Secret 配置
│   └── database-secret.yaml
├── ingress/             # Ingress 配置
│   └── api-ingress.yaml
├── deploy.sh            # 一键部署脚本
└── README.md            # Kubernetes 部署文档
```

**使用 Kubernetes 部署：**
```bash
# 方式1：使用部署脚本（推荐）
cd k8s
./deploy.sh

# 方式2：手动部署
# 1. 部署 Eureka Server
kubectl apply -f deployments/eureka-server-deployment.yaml
kubectl apply -f services/eureka-server-service.yaml

# 2. 部署其他服务（按顺序）
kubectl apply -f deployments/config-server-deployment.yaml
kubectl apply -f deployments/user-service-deployment.yaml
kubectl apply -f deployments/shift-service-deployment.yaml
kubectl apply -f deployments/api-gateway-deployment.yaml

# 3. 部署 Ingress
kubectl apply -f ingress/api-ingress.yaml

# 查看部署状态
kubectl get pods
kubectl get services
```

**Kubernetes 部署特点：**
- **高可用性**: 支持多副本部署，自动故障恢复
- **自动扩缩容**: 可根据负载自动调整 Pod 数量
- **服务发现**: 通过 Service 实现服务间通信
- **配置管理**: ConfigMap 和 Secret 实现配置与代码分离
- **负载均衡**: Service 自动实现负载均衡
- **滚动更新**: 支持零停机更新

详细部署指南请参考：[Kubernetes 部署文档](k8s/README.md)

## 📖 下一步学习

完成阶段6后，可以考虑以下进阶内容：
- 监控和日志（Prometheus + Grafana）
- 分布式追踪（Jaeger、Zipkin）
- CI/CD 流水线（Jenkins、GitLab CI、GitHub Actions）
- 服务网格（Istio、Linkerd）
- 云原生数据库（云数据库服务）

## 🤝 学习建议

1. **理解每一层的作用**：
   - Controller: 处理 HTTP 请求
   - Service: 业务逻辑处理
   - Repository: 数据访问
   - Model: 数据模型

2. **尝试修改代码**：
   - 添加新的字段
   - 修改验证规则
   - 添加新的 API 端点

3. **观察日志**：
   - 查看 SQL 语句
   - 理解 Spring Boot 的自动配置

4. **使用 H2 控制台**：
   - 查看数据库表结构
   - 直接查询数据

## 📝 注意事项

- 当前使用 H2 内存数据库，重启应用后数据会丢失
- 这是学习项目，生产环境需要添加更多安全措施
- 错误处理可以进一步完善（使用全局异常处理）

---



