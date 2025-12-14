# Kubernetes 部署指南（通用）

本文档介绍如何将 Staffjoy 微服务应用部署到**标准 Kubernetes 集群**（适用于任何 Kubernetes 环境）。

> 💡 **说明：** 这是通用 Kubernetes 部署配置，可部署到任何 Kubernetes 集群（本地、Google GKE、AWS EKS、Azure AKS、阿里云 ACK 等）。  
> 如果您要部署到**阿里云 ACK**，请参考：[阿里云 ACK 部署指南](alibaba-cloud/README.md)

## 📋 前置要求

1. **Kubernetes 集群**
   - 本地开发：Minikube、Kind、Docker Desktop Kubernetes
   - 云服务商：Google GKE、AWS EKS、Azure AKS、阿里云 ACK、腾讯云 TKE 等
   - 自建集群：任何标准 Kubernetes 集群

2. **kubectl** 命令行工具已安装并配置

3. **Docker 镜像**
   - 所有服务的 Docker 镜像已构建并推送到镜像仓库
   - 本地开发可以使用本地镜像

## 📁 文件结构

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
└── README.md            # 本文档
```

## 🚀 快速开始

### 1. 构建并推送 Docker 镜像

```bash
# 构建所有镜像
docker build -f eureka-server/Dockerfile -t staffjoy-eureka-server:latest .
docker build -f config-server/Dockerfile -t staffjoy-config-server:latest .
docker build -f user-service/Dockerfile -t staffjoy-user-service:latest .
docker build -f shift-service/Dockerfile -t staffjoy-shift-service:latest .
docker build -f api-gateway/Dockerfile -t staffjoy-api-gateway:latest .

# 如果使用远程镜像仓库，需要先打标签并推送
# docker tag staffjoy-eureka-server:latest your-registry/staffjoy-eureka-server:latest
# docker push your-registry/staffjoy-eureka-server:latest
```

### 2. 使用本地镜像（Minikube/Kind）

```bash
# Minikube
minikube image load staffjoy-eureka-server:latest
minikube image load staffjoy-config-server:latest
minikube image load staffjoy-user-service:latest
minikube image load staffjoy-shift-service:latest
minikube image load staffjoy-api-gateway:latest

# Kind
kind load docker-image staffjoy-eureka-server:latest
kind load docker-image staffjoy-config-server:latest
kind load docker-image staffjoy-user-service:latest
kind load docker-image staffjoy-shift-service:latest
kind load docker-image staffjoy-api-gateway:latest
```

### 3. 部署顺序

**重要：** 必须按照以下顺序部署，因为服务之间有依赖关系。

```bash
# 1. 部署 Eureka Server（服务发现中心，必须先启动）
kubectl apply -f deployments/eureka-server-deployment.yaml
kubectl apply -f services/eureka-server-service.yaml

# 等待 Eureka Server 就绪
kubectl wait --for=condition=available --timeout=120s deployment/eureka-server

# 2. 部署 Config Server（配置中心，可选）
kubectl apply -f deployments/config-server-deployment.yaml
kubectl apply -f services/config-server-service.yaml

# 3. 部署业务服务（User Service 和 Shift Service）
kubectl apply -f deployments/user-service-deployment.yaml
kubectl apply -f services/user-service-service.yaml

kubectl apply -f deployments/shift-service-deployment.yaml
kubectl apply -f services/shift-service-service.yaml

# 4. 部署 API Gateway（最后部署，依赖所有服务）
kubectl apply -f deployments/api-gateway-deployment.yaml
kubectl apply -f services/api-gateway-service.yaml

# 5. 部署 Ingress（可选，用于外部访问）
kubectl apply -f ingress/api-ingress.yaml
```

### 4. 一键部署脚本

使用提供的部署脚本：

```bash
# 赋予执行权限
chmod +x deploy.sh

# 执行部署
./deploy.sh
```

## 🔍 验证部署

### 检查 Pod 状态

```bash
kubectl get pods
# 应该看到所有 Pod 都是 Running 状态

kubectl get pods -l app=eureka-server
kubectl get pods -l app=user-service
kubectl get pods -l app=shift-service
kubectl get pods -l app=api-gateway
```

### 检查 Service

```bash
kubectl get services
# 应该看到所有 Service 都已创建
```

### 检查日志

```bash
# 查看特定服务的日志
kubectl logs -f deployment/eureka-server
kubectl logs -f deployment/user-service
kubectl logs -f deployment/shift-service
kubectl logs -f deployment/api-gateway
```

### 访问服务

```bash
# 端口转发（本地访问）
kubectl port-forward service/api-gateway 8080:8080
kubectl port-forward service/eureka-server 8761:8761

# 访问 API Gateway
curl http://localhost:8080/api/users

# 访问 Eureka Dashboard
open http://localhost:8761
```

## 🔧 配置说明

### Deployment 配置要点

- **副本数**：生产环境建议至少 2 个副本以实现高可用
- **资源限制**：根据实际负载调整 CPU 和内存限制
- **健康检查**：配置了 liveness 和 readiness 探针
- **镜像拉取策略**：本地开发使用 `IfNotPresent`，生产环境使用 `Always`

### Service 配置

- **类型**：内部服务使用 `ClusterIP`，API Gateway 使用 `LoadBalancer`（或通过 Ingress）
- **端口映射**：保持与容器端口一致

### ConfigMap 和 Secret

- **ConfigMap**：存储非敏感配置
- **Secret**：存储敏感信息（数据库密码等）
- **注意**：生产环境建议使用更安全的密钥管理方案（如 HashiCorp Vault）

### Ingress 配置

- **域名**：生产环境需要配置实际域名和 TLS 证书
- **路径路由**：API Gateway 作为统一入口，Eureka Dashboard 可选暴露

## 📊 生产环境建议

### 1. 高可用配置

- **Eureka Server**：配置多实例（至少 2 个）实现高可用
- **业务服务**：至少 2 个副本，使用 HPA（Horizontal Pod Autoscaler）自动扩缩容
- **数据库**：使用外部数据库（MySQL/PostgreSQL），配置主从复制

### 2. 监控和日志

- **监控**：集成 Prometheus + Grafana
- **日志**：使用 ELK Stack 或 Loki + Grafana
- **追踪**：集成分布式追踪系统（Jaeger、Zipkin）

### 3. 安全

- **网络策略**：配置 NetworkPolicy 限制 Pod 间通信
- **RBAC**：配置适当的角色和权限
- **TLS**：所有外部通信使用 HTTPS
- **密钥管理**：使用专业的密钥管理服务

### 4. 资源管理

- **资源配额**：配置 ResourceQuota 和 LimitRange
- **节点选择**：使用 nodeSelector 或 affinity 规则
- **持久化存储**：数据库使用 PersistentVolume

## 🛠️ 故障排查

### Pod 无法启动

```bash
# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看 Pod 日志
kubectl logs <pod-name>

# 检查事件
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 服务无法访问

```bash
# 检查 Service 端点
kubectl get endpoints <service-name>

# 测试服务连通性（在 Pod 内）
kubectl exec -it <pod-name> -- wget -O- http://service-name:port/actuator/health
```

### 镜像拉取失败

```bash
# 检查镜像是否存在
docker images | grep staffjoy

# 检查镜像拉取策略
kubectl get deployment <deployment-name> -o yaml | grep imagePullPolicy
```

## 📚 相关文档

- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Spring Cloud Kubernetes](https://spring.io/projects/spring-cloud-kubernetes)
- [项目 Docker 指南](../docs/DOCKER_GUIDE.md)

## 🔄 更新部署

```bash
# 更新镜像后，重新部署
kubectl set image deployment/user-service user-service=staffjoy-user-service:v2.0

# 或者重新应用配置文件
kubectl apply -f deployments/user-service-deployment.yaml

# 查看滚动更新状态
kubectl rollout status deployment/user-service
```

## 🗑️ 清理资源

```bash
# 删除所有资源
kubectl delete -f deployments/
kubectl delete -f services/
kubectl delete -f ingress/
kubectl delete -f configmaps/
kubectl delete -f secrets/

# 或者使用命名空间隔离
kubectl delete namespace staffjoy
```

