# DBeaver 连接 PostgreSQL 配置指南

本指南将帮助你在 DBeaver 中配置 PostgreSQL 数据库连接，以便可视化查看和管理 Staffjoy 项目的数据库。

## 📋 前置条件

1. **DBeaver 已安装**
   - 下载地址：https://dbeaver.io/download/
   - 支持 Windows、macOS、Linux

2. **PostgreSQL 容器正在运行**
   ```bash
   # 检查容器状态
   docker ps | grep staffjoy-postgres
   
   # 如果未运行，启动容器
   ./scripts/start-postgres.sh
   ```

## 🔧 连接配置步骤

### 步骤 1: 创建新连接

1. 打开 DBeaver
2. 点击菜单栏：**Database** → **New Database Connection**
   - 或使用快捷键：`Cmd+Shift+N` (macOS) / `Ctrl+Shift+N` (Windows/Linux)
3. 在连接类型选择界面，搜索并选择 **PostgreSQL**

### 步骤 2: 配置连接参数

#### 基本连接信息

| 参数 | 值 | 说明 |
|------|-----|------|
| **Host** | `localhost` | 数据库主机地址 |
| **Port** | `5433` | 数据库端口（注意：不是默认的 5432） |
| **Database** | `staffjoy` | 数据库名称 |
| **Username** | `postgres` | 数据库用户名 |
| **Password** | `postgres` | 数据库密码 |

#### 详细配置步骤

1. **Main 标签页**
   ```
   Host:     localhost
   Port:     5433
   Database: staffjoy
   Username: postgres
   Password: postgres
   ```

2. **Driver properties 标签页**（可选）
   - 通常使用默认设置即可
   - 如果需要，可以设置：
     - `connectTimeout`: `10`
     - `socketTimeout`: `30`

3. **SSL 标签页**
   - 本地开发环境通常不需要 SSL
   - 保持默认设置（SSL Mode: `disable`）

### 步骤 3: 测试连接

1. 点击 **Test Connection** 按钮
2. 如果是首次使用，DBeaver 可能会提示下载 PostgreSQL 驱动
   - 点击 **Download** 下载驱动
   - 等待下载完成
3. 如果连接成功，会显示 "Connected" 消息
4. 点击 **Finish** 完成配置

### 步骤 4: 查看数据库结构

连接成功后，你可以在 DBeaver 的数据库导航器中看到：

```
📁 staffjoy (PostgreSQL)
  ├── 📁 Schemas
  │   ├── 📁 public
  │   ├── 📁 user_schema          ← User Service 的 Schema
  │   │   ├── 📁 Tables
  │   │   │   ├── users
  │   │   │   └── flyway_schema_history
  │   │   └── 📁 Functions
  │   └── 📁 shift_schema         ← Shift Service 的 Schema
  │       ├── 📁 Tables
  │       │   ├── companies
  │       │   ├── shifts
  │       │   └── flyway_schema_history
  │       └── 📁 Functions
  │           └── update_updated_at_column()
```

## 📊 常用操作

### 查看表数据

1. 展开 **Schemas** → **user_schema** → **Tables**
2. 右键点击 **users** 表
3. 选择 **View Data** → **All Rows**
   - 或使用快捷键：`F4`

### 执行 SQL 查询

1. 右键点击数据库连接
2. 选择 **SQL Editor** → **New SQL Script**
3. 输入 SQL 查询，例如：
   ```sql
   -- 查看所有用户
   SELECT * FROM user_schema.users;
   
   -- 查看所有公司
   SELECT * FROM shift_schema.companies;
   
   -- 查看所有排班
   SELECT 
       s.id,
       s.user_id,
       s.start_time,
       s.stop_time,
       c.name as company_name
   FROM shift_schema.shifts s
   JOIN shift_schema.companies c ON s.company_id = c.id;
   ```
4. 点击 **Execute SQL Script** (F5) 或 **Execute SQL Statement** (Ctrl+Enter)

### 查看表结构

1. 右键点击表名（如 `users`）
2. 选择 **View DDL** 查看表定义
3. 或选择 **Properties** 查看表属性

### 查看索引

1. 展开表 → **Indexes**
2. 可以看到所有索引，例如：
   - `idx_users_username`
   - `idx_users_email`

### 查看 Flyway 迁移历史

```sql
-- User Service 迁移历史
SELECT * FROM user_schema.flyway_schema_history 
ORDER BY installed_rank;

-- Shift Service 迁移历史
SELECT * FROM shift_schema.flyway_schema_history 
ORDER BY installed_rank;
```

## 🔍 数据库探索技巧

### 1. 查看所有 Schema

```sql
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
ORDER BY schema_name;
```

### 2. 查看 Schema 中的所有表

```sql
-- User Schema 的表
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'user_schema'
ORDER BY table_name;

-- Shift Schema 的表
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'shift_schema'
ORDER BY table_name;
```

### 3. 查看表的列信息

```sql
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'user_schema' 
  AND table_name = 'users'
ORDER BY ordinal_position;
```

### 4. 查看外键关系

```sql
SELECT
    tc.table_schema, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_schema, tc.table_name;
```

## 🎨 DBeaver 界面定制

### 显示行号

1. **Window** → **Preferences** (macOS: **DBeaver** → **Preferences**)
2. **General** → **Editors** → **Text Editors**
3. 勾选 **Show line numbers**

### 自定义 SQL 格式

1. **Window** → **Preferences**
2. **SQL Editor** → **Format**
3. 可以调整：
   - 关键字大小写（UPPER/lower/Capitalize）
   - 缩进方式
   - 换行规则

### 数据网格设置

1. **Window** → **Preferences**
2. **Data Editor** → **Presentation**
3. 可以设置：
   - 最大显示行数
   - 日期时间格式
   - 数字格式

## 🐛 常见问题

### Q: 连接失败 "Connection refused"

**A:** 检查以下几点：
1. PostgreSQL 容器是否运行：`docker ps | grep postgres`
2. 端口是否正确：`5433`（不是 `5432`）
3. Docker Desktop 是否运行

### Q: 认证失败 "password authentication failed"

**A:** 
- 确认用户名和密码都是 `postgres`
- 如果修改过密码，使用新密码

### Q: 找不到数据库 "database does not exist"

**A:**
- 确认数据库名称是 `staffjoy`（不是 `postgres`）
- 如果数据库不存在，运行初始化脚本：
  ```bash
  ./scripts/migrate-database-local.sh
  ```

### Q: 看不到 Schema

**A:**
1. 右键点击数据库连接
2. 选择 **Refresh**
3. 或展开 **Schemas** 节点查看

### Q: 驱动下载失败

**A:**
1. 手动下载 PostgreSQL JDBC 驱动：
   - 下载地址：https://jdbc.postgresql.org/download/
   - 版本：建议使用 42.x 版本
2. 在连接配置中：
   - 点击 **Edit Driver Settings**
   - 点击 **Add File**
   - 选择下载的驱动 JAR 文件

## 📚 有用的 SQL 查询模板

### 数据统计

```sql
-- 统计各 Schema 的表数量
SELECT 
    table_schema,
    COUNT(*) as table_count
FROM information_schema.tables
WHERE table_schema IN ('user_schema', 'shift_schema')
GROUP BY table_schema;

-- 统计各表的数据量
SELECT 
    'user_schema.users' as table_name,
    COUNT(*) as row_count
FROM user_schema.users
UNION ALL
SELECT 
    'shift_schema.companies',
    COUNT(*)
FROM shift_schema.companies
UNION ALL
SELECT 
    'shift_schema.shifts',
    COUNT(*)
FROM shift_schema.shifts;
```

### 查看最近创建的数据

```sql
-- 最近创建的用户
SELECT id, username, email, created_at
FROM user_schema.users
ORDER BY created_at DESC
LIMIT 10;

-- 最近创建的公司
SELECT id, name, legal_name, created_at
FROM shift_schema.companies
ORDER BY created_at DESC
LIMIT 10;
```

### 数据完整性检查

```sql
-- 检查是否有孤立的外键引用
SELECT s.id, s.user_id, s.company_id
FROM shift_schema.shifts s
LEFT JOIN shift_schema.companies c ON s.company_id = c.id
WHERE c.id IS NULL;
```

## 🔐 安全建议

### 生产环境

在生产环境中，建议：

1. **使用强密码**
   - 不要使用默认密码 `postgres`
   - 使用复杂的密码策略

2. **启用 SSL**
   - 在 DBeaver 连接配置中启用 SSL
   - 配置 SSL Mode 为 `require` 或 `verify-full`

3. **限制访问**
   - 使用防火墙规则限制数据库访问
   - 只允许必要的 IP 地址连接

4. **使用只读用户**
   - 创建只读用户用于查询
   - 避免在生产环境使用管理员账户

## 📖 相关文档

- [PostgreSQL 设置指南](POSTGRESQL_SETUP.md)
- [数据库连接验证指南](DATABASE_CONNECTION_VERIFICATION.md)
- [Flyway 迁移指南](FLYWAY_MIGRATION_GUIDE.md)

## 💡 提示

- 使用 **Ctrl+Space** (Windows/Linux) 或 **Cmd+Space** (macOS) 可以自动补全 SQL 关键字和表名
- 使用 **Ctrl+Enter** (Windows/Linux) 或 **Cmd+Enter** (macOS) 执行当前 SQL 语句
- 在 SQL 编辑器中，可以使用 **Ctrl+/** (Windows/Linux) 或 **Cmd+/** (macOS) 注释/取消注释代码

