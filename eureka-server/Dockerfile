# Eureka Server Dockerfile
# 多阶段构建：先构建，再运行

# 阶段1：构建阶段
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# 复制父 POM 和所有模块的 POM（Maven 需要所有模块的 POM 来解析依赖）
COPY pom.xml .
COPY eureka-server/pom.xml ./eureka-server/
COPY config-server/pom.xml ./config-server/
COPY user-service/pom.xml ./user-service/
COPY shift-service/pom.xml ./shift-service/
COPY api-gateway/pom.xml ./api-gateway/

# 下载依赖（利用 Docker 缓存）
RUN mvn dependency:go-offline -f pom.xml -pl eureka-server -am

# 复制源代码
COPY eureka-server/src ./eureka-server/src

# 构建应用
RUN mvn clean package -f pom.xml -pl eureka-server -DskipTests

# 阶段2：运行阶段
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# 安装 wget 用于健康检查
RUN apk add --no-cache wget

# 创建非 root 用户
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# 从构建阶段复制 JAR 文件
COPY --from=build /app/eureka-server/target/eureka-server-*.jar app.jar

# 暴露端口
EXPOSE 8761

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]

