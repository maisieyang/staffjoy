# 分层架构详解：Model 层与 Repository 层

## 📚 目录
1. [整体架构概览](#整体架构概览)
2. [Model 层详解](#model-层详解)
3. [Repository 层详解](#repository-层详解)
4. [两层之间的边界和协作](#两层之间的边界和协作)
5. [常见误区和反模式](#常见误区和反模式)
6. [实际案例分析](#实际案例分析)

---

## 整体架构概览

```
┌─────────────────────────────────────────┐
│         Controller 层                    │
│  - 处理 HTTP 请求/响应                   │
│  - 参数验证和转换                        │
│  - 调用 Service 层                       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Service 层                       │
│  - 业务逻辑处理                          │
│  - 事务管理                              │
│  - 调用 Repository 层                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Repository 层                       │
│  - 数据访问接口                          │
│  - 数据库操作                            │
│  - 返回 Model 对象                       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Model 层                         │
│  - 数据模型定义                          │
│  - 数据库表映射                          │
│  - 实体关系定义                          │
└─────────────────────────────────────────┘
```

---

## Model 层详解

### 🎯 核心职责

**Model 层（也叫 Entity 层或 Domain 层）的职责是：**

1. **定义数据结构**：描述业务实体的属性和字段
2. **数据库映射**：通过 JPA 注解映射到数据库表
3. **数据验证**：定义字段的验证规则
4. **实体关系**：定义实体之间的关联关系（一对一、一对多、多对多）

### 📋 Model 层应该包含什么？

#### ✅ 应该包含的内容：

```java
@Entity
@Table(name = "users")
public class User {
    
    // 1. 字段定义（属性）
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // 2. 字段约束和验证
    @NotBlank(message = "用户名不能为空")
    @Column(nullable = false, unique = true)
    private String username;
    
    // 3. 数据库映射配置
    @Column(name = "phone_number")
    private String phoneNumber;
    
    // 4. 生命周期回调（与持久化相关）
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    // 5. 实体关系（可选）
    @OneToMany(mappedBy = "user")
    private List<Shift> shifts;
    
    // 6. 简单的 getter/setter（或使用 Lombok）
    // 7. equals() 和 hashCode()（可选，用于集合操作）
}
```

#### ❌ 不应该包含的内容：

```java
// ❌ 错误示例：业务逻辑不应该在 Model 层
public class User {
    public void sendEmail() {  // ❌ 这是业务逻辑，应该在 Service 层
        // 发送邮件逻辑
    }
    
    public boolean isActive() {  // ❌ 复杂判断应该在 Service 层
        return status.equals("ACTIVE") && lastLogin.isAfter(LocalDateTime.now().minusDays(30));
    }
}

// ✅ 正确示例：简单的属性访问是可以的
public class User {
    public boolean isActive() {  // ✅ 简单的属性判断可以
        return "ACTIVE".equals(status);
    }
}
```

### 🔍 Model 层的边界

**边界原则：**
- ✅ **可以**：定义数据结构、验证规则、数据库映射
- ✅ **可以**：简单的属性访问方法（getter/setter）
- ✅ **可以**：与持久化相关的生命周期回调（@PrePersist, @PreUpdate）
- ❌ **不可以**：复杂的业务逻辑
- ❌ **不可以**：调用其他服务或外部 API
- ❌ **不可以**：数据库查询逻辑（那是 Repository 的职责）

---

## Repository 层详解

### 🎯 核心职责

**Repository 层（数据访问层）的职责是：**

1. **数据访问接口**：定义如何访问数据库
2. **查询方法**：定义各种查询操作
3. **数据持久化**：保存、更新、删除数据
4. **数据检索**：根据条件查找数据

### 📋 Repository 层应该包含什么？

#### ✅ 应该包含的内容：

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // 1. 简单的查询方法（Spring Data JPA 自动实现）
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    
    // 2. 存在性检查
    boolean existsByUsername(String username);
    
    // 3. 计数查询
    long countByStatus(String status);
    
    // 4. 自定义查询（使用 @Query）
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
    
    // 5. 原生 SQL 查询（必要时）
    @Query(value = "SELECT * FROM users WHERE status = ?1", nativeQuery = true)
    List<User> findByStatusNative(String status);
}
```

#### ❌ 不应该包含的内容：

```java
// ❌ 错误示例：业务逻辑不应该在 Repository 层
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // ❌ 业务验证逻辑
    default boolean canCreateUser(User user) {
        if (existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");  // 这是业务逻辑！
        }
        return true;
    }
    
    // ❌ 业务计算
    default double calculateUserScore(Long userId) {
        // 计算用户评分... 这是业务逻辑，应该在 Service 层
    }
}
```

### 🔍 Repository 层的边界

**边界原则：**
- ✅ **可以**：定义查询方法（findBy, existsBy, countBy 等）
- ✅ **可以**：使用 @Query 定义自定义查询
- ✅ **可以**：使用原生 SQL（必要时）
- ✅ **可以**：定义分页和排序查询
- ❌ **不可以**：业务逻辑判断
- ❌ **不可以**：数据转换和格式化
- ❌ **不可以**：调用其他服务
- ❌ **不可以**：事务管理（由 Service 层负责）

---

## 两层之间的边界和协作

### 🔄 数据流向

```
Service 层                    Repository 层                    Model 层
─────────────────            ──────────────────            ────────────────
UserService                  UserRepository                  User
    │                              │                            │
    │ 1. 调用查询方法               │                            │
    ├─────────────────────────────>│                            │
    │                              │ 2. 执行数据库查询           │
    │                              ├───────────────────────────>│
    │                              │ 3. 返回 Model 对象         │
    │                              │<───────────────────────────┤
    │ 4. 接收 Model 对象           │                            │
    │<─────────────────────────────┤                            │
    │                              │                            │
    │ 5. 处理业务逻辑               │                            │
    │ 6. 修改 Model 对象           │                            │
    │                              │                            │
    │ 7. 调用保存方法               │                            │
    ├─────────────────────────────>│                            │
    │                              │ 8. 持久化到数据库           │
    │                              ├───────────────────────────>│
```

### 🎯 关键边界规则

#### 1. **Model 是数据载体，Repository 是数据访问**

```java
// ✅ 正确：Repository 返回 Model 对象
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findById(Long id);  // 返回 User 对象
}

// ❌ 错误：Repository 不应该返回 DTO 或其他对象
public interface UserRepository extends JpaRepository<User, Long> {
    UserDTO findById(Long id);  // ❌ 数据转换应该在 Service 层
}
```

#### 2. **Repository 只关心"如何查询"，不关心"为什么查询"**

```java
// ✅ 正确：Repository 只定义查询方法
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);  // 只关心如何查询
}

// Service 层决定为什么查询
public class UserService {
    public void sendPasswordResetEmail(String email) {
        User user = userRepository.findByEmail(email)  // 为什么查询：为了发送重置邮件
                .orElseThrow(() -> new UserNotFoundException());
        // 业务逻辑...
    }
}
```

#### 3. **Model 定义数据结构，Repository 操作这些结构**

```java
// Model 层：定义 User 有什么字段
@Entity
public class User {
    private String email;  // 定义字段
}

// Repository 层：基于这些字段进行查询
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);  // 基于 email 字段查询
}
```

---

## 常见误区和反模式

### ❌ 误区 1：在 Model 中写业务逻辑

```java
// ❌ 错误
@Entity
public class User {
    public void activate() {
        if (this.status.equals("SUSPENDED")) {
            throw new IllegalStateException("被暂停的用户不能激活");
        }
        this.status = "ACTIVE";
        // 发送通知邮件...  ❌ 这应该在 Service 层
    }
}

// ✅ 正确
@Entity
public class User {
    private String status;
    // 只定义数据，不包含业务逻辑
}

// Service 层处理业务逻辑
@Service
public class UserService {
    public void activateUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException());
        
        if ("SUSPENDED".equals(user.getStatus())) {
            throw new IllegalStateException("被暂停的用户不能激活");
        }
        
        user.setStatus("ACTIVE");
        userRepository.save(user);
        emailService.sendActivationEmail(user);  // 业务逻辑在 Service 层
    }
}
```

### ❌ 误区 2：在 Repository 中写业务逻辑

```java
// ❌ 错误
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    default User createUserWithValidation(User user) {
        if (existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");  // ❌ 业务逻辑
        }
        return save(user);
    }
}

// ✅ 正确
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByUsername(String username);  // 只提供查询能力
    // 业务验证在 Service 层
}

@Service
public class UserService {
    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");  // ✅ 业务逻辑在这里
        }
        return userRepository.save(user);
    }
}
```

### ❌ 误区 3：Model 和 Repository 职责混淆

```java
// ❌ 错误：在 Model 中直接访问数据库
@Entity
public class User {
    @Autowired
    private UserRepository userRepository;  // ❌ Model 不应该依赖 Repository
    
    public User findRelatedUser() {
        return userRepository.findById(this.relatedUserId).orElse(null);
    }
}

// ✅ 正确：通过 Service 层协调
@Service
public class UserService {
    public User getRelatedUser(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();
        return userRepository.findById(user.getRelatedUserId()).orElse(null);
    }
}
```

---

## 实际案例分析

### 📝 案例 1：用户注册流程

让我们看看一个完整的用户注册流程，各层如何协作：

```java
// ========== Model 层 ==========
@Entity
public class User {
    @Id
    @GeneratedValue
    private Long id;
    
    @NotBlank
    @Column(unique = true)
    private String username;
    
    @Email
    @Column(unique = true)
    private String email;
    
    // 只定义数据结构，没有业务逻辑
}

// ========== Repository 层 ==========
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // 只提供数据访问能力
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    Optional<User> findByEmail(String email);
}

// ========== Service 层 ==========
@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    public User registerUser(User user) {
        // 业务逻辑 1：验证用户名唯一性
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new BusinessException("用户名已存在");
        }
        
        // 业务逻辑 2：验证邮箱唯一性
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new BusinessException("邮箱已被注册");
        }
        
        // 业务逻辑 3：保存用户
        User savedUser = userRepository.save(user);
        
        // 业务逻辑 4：发送欢迎邮件
        emailService.sendWelcomeEmail(savedUser);
        
        return savedUser;
    }
}

// ========== Controller 层 ==========
@RestController
public class UserController {
    private final UserService userService;
    
    @PostMapping("/users")
    public ResponseEntity<User> register(@Valid @RequestBody User user) {
        User registeredUser = userService.registerUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(registeredUser);
    }
}
```

**各层职责总结：**
- **Model**：定义用户有哪些字段（username, email）
- **Repository**：提供查询能力（existsByUsername, existsByEmail, save）
- **Service**：协调 Repository 和业务逻辑（验证、保存、发邮件）
- **Controller**：处理 HTTP 请求，调用 Service

### 📝 案例 2：查询活跃用户

```java
// ========== Model 层 ==========
@Entity
public class User {
    private LocalDateTime lastLoginAt;
    private String status;
    
    // ✅ 可以：简单的属性判断
    public boolean hasLoggedIn() {
        return lastLoginAt != null;
    }
}

// ========== Repository 层 ==========
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // ✅ 可以：基于字段的查询
    List<User> findByStatus(String status);
    List<User> findByLastLoginAtAfter(LocalDateTime date);
    
    // ✅ 可以：组合查询
    @Query("SELECT u FROM User u WHERE u.status = 'ACTIVE' AND u.lastLoginAt > :date")
    List<User> findActiveUsersAfter(@Param("date") LocalDateTime date);
}

// ========== Service 层 ==========
@Service
public class UserService {
    public List<User> getActiveUsers(int days) {
        // 业务逻辑：定义什么是"活跃用户"
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(days);
        
        // 使用 Repository 查询
        return userRepository.findActiveUsersAfter(cutoffDate);
    }
}
```

**关键点：**
- **Model**：定义字段和简单属性访问
- **Repository**：提供基于字段的查询能力
- **Service**：定义业务规则（"活跃用户"的定义）

---

## 🎓 总结：记住这些原则

### Model 层的原则
1. ✅ **只定义数据结构**：字段、验证规则、数据库映射
2. ✅ **可以包含简单的属性访问方法**
3. ❌ **不包含业务逻辑**
4. ❌ **不依赖其他层**（特别是 Repository 和 Service）

### Repository 层的原则
1. ✅ **只提供数据访问能力**：查询、保存、删除
2. ✅ **只关心"如何查询"，不关心"为什么查询"**
3. ❌ **不包含业务逻辑**
4. ❌ **不进行数据转换**（返回 Model 对象，不返回 DTO）

### 边界判断技巧
当你不确定代码应该放在哪一层时，问自己：

1. **这段代码是在操作数据库吗？**
   - 是 → Repository 层
   - 否 → 继续判断

2. **这段代码是在定义数据结构吗？**
   - 是 → Model 层
   - 否 → 继续判断

3. **这段代码包含业务规则或业务逻辑吗？**
   - 是 → Service 层
   - 否 → 可能是 Controller 层

---

**记住：清晰的边界让代码更容易理解、测试和维护！** 🎯

