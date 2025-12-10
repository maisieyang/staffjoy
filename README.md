# Staffjoy 学习项目

这是一个从零开始学习 Spring Boot、微服务和 Kubernetes 的项目。我们将逐步构建一个类似 Staffjoy 的员工排班应用。

## 📚 学习路径

### 阶段1：基础 Spring Boot 单体应用 ✅
- [x] 创建 Spring Boot 项目
- [x] 实现用户管理功能（CRUD）
- [x] 使用 H2 内存数据库
- [x] RESTful API 设计

### 阶段2：数据库和业务逻辑（待完成）
- [ ] 添加 MySQL 数据库支持
- [ ] 实现排班（Shift）功能
- [ ] 实现公司（Company）功能
- [ ] 添加数据关联关系

### 阶段3：微服务拆分（待完成）
- [ ] 拆分为用户服务（User Service）
- [ ] 拆分为排班服务（Shift Service）
- [ ] 创建 API 网关（API Gateway）

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
- JDK 17 或更高版本
- Maven 3.6 或更高版本

### 运行应用

```bash
# 编译项目
mvn clean compile

# 运行应用
mvn spring-boot:run

# 或者打包后运行
mvn clean package
java -jar target/staffjoy-app-1.0.0-SNAPSHOT.jar
```

### 访问应用

- 应用地址: http://localhost:8080
- H2 数据库控制台: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:staffjoydb`
  - 用户名: `sa`
  - 密码: (留空)

## 📡 API 端点

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
staffjoy-app/
├── src/
│   ├── main/
│   │   ├── java/com/staffjoy/
│   │   │   ├── StaffjoyApplication.java    # 主应用类
│   │   │   ├── controller/                 # REST 控制器
│   │   │   │   └── UserController.java
│   │   │   ├── service/                    # 业务逻辑层
│   │   │   │   └── UserService.java
│   │   │   ├── repository/                 # 数据访问层
│   │   │   │   └── UserRepository.java
│   │   │   └── model/                      # 实体类
│   │   │       └── User.java
│   │   └── resources/
│   │       └── application.yml             # 配置文件
│   └── test/                               # 测试代码
├── pom.xml                                 # Maven 配置
└── README.md                               # 项目说明
```

## 🎯 当前阶段说明

**阶段1：基础单体应用**

我们已经完成了：
1. ✅ Spring Boot 项目基础结构
2. ✅ 用户实体（User）和数据模型
3. ✅ 数据访问层（Repository）
4. ✅ 业务逻辑层（Service）
5. ✅ REST API 控制器（Controller）
6. ✅ H2 内存数据库配置

**核心概念学习：**
- **@Entity**: JPA 实体注解，映射数据库表
- **@Repository**: 数据访问层注解
- **@Service**: 业务逻辑层注解
- **@RestController**: REST API 控制器注解
- **JpaRepository**: Spring Data JPA 提供的接口，自动实现 CRUD 操作
- **依赖注入**: 使用 @Autowired 注入依赖

## 📖 下一步学习

完成阶段1后，我们将进入阶段2：
- 添加更多业务实体（Company, Shift, Schedule）
- 实现实体间的关联关系
- 添加更复杂的业务逻辑
- 切换到 MySQL 数据库

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

**祝你学习愉快！** 🎉

