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

### 阶段4：服务发现和配置（待完成）
- [ ] 集成 Eureka 服务发现
- [ ] 配置中心（Spring Cloud Config）
- [ ] 服务间通信（Feign/RestTemplate）

### 阶段5：容器化（待完成）
- [ ] Docker 化所有服务
- [ ] Docker Compose 本地开发环境

### 阶段6：Kubernetes 部署（待完成）
- [ ] K8s Deployment 配置
- [ ] Service 和 Ingress 配置
- [ ] ConfigMap 和 Secret
- [ ] 生产环境部署

## 🚀 快速开始

### 前置要求
- JDK 21 或更高版本
- Maven 3.8 或更高版本

### 📖 架构说明

**想了解微服务架构的详细说明？** 请查看：[微服务架构说明文档](docs/MICROSERVICES_ARCHITECTURE.md)

该文档详细解释了：
- 项目结构和各模块关系
- 服务间的协作方式
- 启动顺序和步骤
- 数据流示例
- 关键概念理解

### 微服务架构

项目已拆分为多个微服务：

```
staffjoy/
├── user-service/      # 用户服务 (端口: 8081)
├── shift-service/     # 排班服务 (端口: 8082)
└── api-gateway/       # API 网关 (端口: 8080)
```

### 运行应用

#### 方式1：分别运行各个服务（推荐用于开发）

```bash
# 1. 编译整个项目
mvn clean install

# 2. 启动用户服务
cd user-service
mvn spring-boot:run
# 服务将在 http://localhost:8081 启动

# 3. 启动排班服务（新终端窗口）
cd shift-service
mvn spring-boot:run
# 服务将在 http://localhost:8082 启动

# 4. 启动 API 网关（新终端窗口）
cd api-gateway
mvn spring-boot:run
# 网关将在 http://localhost:8080 启动
```

#### 方式2：使用 Maven 并行运行（需要多个终端）

```bash
# 在项目根目录下，分别在不同终端运行：
mvn -pl user-service spring-boot:run
mvn -pl shift-service spring-boot:run
mvn -pl api-gateway spring-boot:run
```

### 访问应用

- **API 网关**: http://localhost:8080（统一入口）
- **用户服务**: http://localhost:8081
- **排班服务**: http://localhost:8082

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

## 📖 下一步学习

完成阶段3后，我们将进入阶段4：
- 集成 Eureka 服务发现
- 配置中心（Spring Cloud Config）
- 服务间通信（Feign/RestTemplate）

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



