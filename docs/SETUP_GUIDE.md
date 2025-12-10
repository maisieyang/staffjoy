# 环境配置指南

## 📋 前置要求

运行这个 Spring Boot 项目需要：
1. **JDK 17** 或更高版本（推荐 **Java 21 LTS** - 最新长期支持版本）
2. **Maven 3.8+**（推荐 **Maven 3.9.x** - 最新稳定版本）

### 📊 当前主流版本（2024-2025）

| 工具 | 最低版本 | 推荐版本 | 最新版本 |
|------|---------|---------|---------|
| **Java** | JDK 17 | **JDK 21 LTS** | JDK 21 LTS |
| **Maven** | 3.8.0 | **3.9.x** | 3.9.6+ |

**说明：**
- **Java 21**：2023年9月发布的 LTS 版本，包含虚拟线程、模式匹配等新特性
- **Java 17**：2021年发布的 LTS 版本，目前企业级应用广泛使用
- **Maven 3.9.x**：支持 Java 21，提供更好的性能和安全性

---

## 🍎 macOS 安装指南

### 方法 1：使用 Homebrew（推荐）

#### 1. 安装 Homebrew（如果还没有）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. 安装 Java（推荐 Java 21）

```bash
# 方式 A：安装 Java 21 LTS（推荐，最新长期支持版本）
brew install openjdk@21

# 设置 JAVA_HOME（添加到 ~/.zshrc 或 ~/.bash_profile）
echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@21"' >> ~/.zshrc

# 重新加载配置
source ~/.zshrc

# 方式 B：如果需要 Java 17（备选）
# brew install openjdk@17
# echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
# echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
# source ~/.zshrc
```

#### 3. 安装 Maven

```bash
brew install maven
```

#### 4. 验证安装

```bash
# 检查 Java 版本（应该是 21 或 17）
java -version
# 应该显示：openjdk version "21.x.x" 或 "17.x.x"

# 检查 Maven 版本（应该是 3.9.x 或 3.8.x）
mvn -version
# 应该显示 Maven 3.9.x 或更高版本
```

---

### 方法 2：使用 SDKMAN（推荐用于多版本管理）

#### 1. 安装 SDKMAN

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

#### 2. 安装 Java 和 Maven

```bash
# 安装 Java 21 LTS（推荐）
sdk install java 21.0.1-tem

# 或者安装 Java 17 LTS（备选）
# sdk install java 17.0.9-tem

# 安装 Maven（最新版本）
sdk install maven

# 验证
java -version
mvn -version
```

---

### 方法 3：手动安装

#### 1. 安装 Java

1. 访问 [Eclipse Temurin (Adoptium)](https://adoptium.net/) 或 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
2. 下载 macOS 版本的 **JDK 21 LTS**（推荐）或 JDK 17 LTS
3. 安装后，设置环境变量：

```bash
# 编辑 ~/.zshrc
nano ~/.zshrc

# 添加以下内容（根据实际安装路径调整，Java 21 示例）
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# 保存后重新加载
source ~/.zshrc
```

#### 2. 安装 Maven

1. 访问 [Maven 官网](https://maven.apache.org/download.cgi)
2. 下载 **apache-maven-3.9.6-bin.tar.gz**（最新稳定版）
3. 解压到 `/usr/local/` 或 `~/tools/`
4. 设置环境变量：

```bash
# 编辑 ~/.zshrc
nano ~/.zshrc

# 添加以下内容（根据实际路径调整）
export MAVEN_HOME=/usr/local/apache-maven-3.9.6
export PATH=$MAVEN_HOME/bin:$PATH

# 保存后重新加载
source ~/.zshrc
```

---

## ✅ 验证安装

运行以下命令验证：

```bash
# 检查 Java（推荐 Java 21）
java -version
# 应该显示：openjdk version "21.x.x" 或 "17.x.x"

# 检查 Java 编译器
javac -version
# 应该显示：javac 21.x.x 或 17.x.x

# 检查 Maven（推荐 3.9.x）
mvn -version
# 应该显示 Maven 3.9.x 和 Java 版本信息
# 例如：Apache Maven 3.9.6
#      Java version: 21.0.1
```

---

## 🚀 运行项目

安装完成后，在项目目录下运行：

```bash
# 进入项目目录
cd /Users/yangxiyue/project/sringBoot

# 方式 1：直接运行（推荐）
mvn spring-boot:run

# 方式 2：先编译再运行
mvn clean package
java -jar target/staffjoy-app-1.0.0-SNAPSHOT.jar
```

---

## 🔧 常见问题

### 问题 1：`java: command not found`

**解决方案：**
- 检查 JAVA_HOME 是否正确设置
- 运行 `echo $JAVA_HOME` 查看路径
- 确保 `$JAVA_HOME/bin` 在 PATH 中

### 问题 2：`mvn: command not found`

**解决方案：**
- 检查 Maven 是否正确安装
- 确保 Maven 的 bin 目录在 PATH 中
- 运行 `which mvn` 查看 Maven 位置

### 问题 3：Java 版本不匹配

**解决方案：**
- 项目需要 Java 17，如果安装了其他版本，需要切换
- 使用 `sdkman` 可以轻松管理多个 Java 版本
- 或者修改 `pom.xml` 中的 `<java.version>`（不推荐）

### 问题 4：Maven 下载依赖慢

**解决方案：**
配置国内镜像（编辑 `~/.m2/settings.xml`）：

```xml
<settings>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
```

---

## 📝 快速检查清单

在运行项目前，确保：

- [ ] Java 21 或 Java 17 已安装（`java -version` 显示 21.x.x 或 17.x.x）
- [ ] Maven 3.9.x 或 3.8.x 已安装（`mvn -version` 显示版本信息）
- [ ] 环境变量已正确配置
- [ ] 网络连接正常（Maven 需要下载依赖）

## 🆕 Java 21 新特性（推荐使用）

Java 21 作为最新 LTS 版本，包含以下重要特性：

- **虚拟线程（Virtual Threads）**：大幅提升并发性能
- **模式匹配增强**：更简洁的代码
- **Record 模式**：更好的数据类支持
- **性能优化**：GC 和 JIT 编译器改进
- **更好的安全性**：最新的安全补丁

Spring Boot 3.2.0 完全支持 Java 21，可以充分利用这些新特性。

---

安装完成后，告诉我，我会帮你运行项目！🎉

