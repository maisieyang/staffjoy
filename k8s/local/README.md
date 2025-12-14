# Kubernetes 本地部署指南

本文档介绍如何在本地 Kubernetes 环境中部署 Staffjoy 微服务应用。

## 📋 前置要求

1. **Docker** 已安装并运行
2. **kubectl** 已安装
3. **本地 Kubernetes 集群**（三选一）：
   - Minikube（推荐）
   - Kind
   - Docker Desktop Kubernetes

## 🚀 快速开始

### 方式 1: 使用 Minikube（推荐）

#### 1.1 安装 Minikube

**macOS:**
```bash
brew install minikube
```

**Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Windows:**
```powershell
# 使用 Chocolatey
choco install minikube
```

#### 1.2 启动 Minikube

```bash
# 启动 Minikube 集群
minikube start

# 验证集群状态
minikube status
kubectl get nodes
```

#### 1.3 构建并加载镜像

```bash
# 使用提供的脚本
cd k8s/local
chmod +x build-and-load-images.sh
./build-and-load-images.sh minikube
```

### 方式 2: 使用 Kind

#### 2.1 安装 Kind

**macOS:**
```bash
brew install kind
```

**Linux/Windows:**
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### 2.2 创建 Kind 集群

```bash
# 创建集群
kind create cluster --name staffjoy

# 验证
kubectl cluster-info --context kind-staffjoy
```

#### 2.3 构建并加载镜像

```bash
cd k8s/local
./build-and-load-images.sh kind
```

### 方式 3: 使用 Docker Desktop Kubernetes

#### 3.1 启用 Kubernetes

1. 打开 Docker Desktop
2. 进入 **Settings** → **Kubernetes**
3. 勾选 **Enable Kubernetes**
4. 点击 **Apply & Restart**

#### 3.2 验证

```bash
kubectl cluster-info
kubectl get nodes
```

#### 3.3 构建镜像（无需加载）

```bash
# Docker Desktop 可以直接使用本地镜像
cd k8s/local
./build-images.sh
```

## 📦 部署步骤

### 步骤 1: 构建 Docker 镜像

```bash
cd k8s/local
chmod +x build-images.sh
./build-images.sh
```

### 步骤 2: 加载镜像到 Kubernetes（Minikube/Kind）

```bash
# Minikube
./build-and-load-images.sh minikube

# Kind
./build-and-load-images.sh kind

# Docker Desktop（无需加载，直接使用本地镜像）
```

### 步骤 3: 部署服务

使用一键部署脚本：

```bash
cd k8s/local
chmod +x deploy-local.sh
./deploy-local.sh
```

或手动部署：

```bash
cd k8s

# 1. 部署 Eureka Server
kubectl apply -f deployments/eureka-server-deployment.yaml
kubectl apply -f services/eureka-server-service.yaml

# 等待 Eureka Server 就绪
kubectl wait --for=condition=available --timeout=120s deployment/eureka-server

# 2. 部署 Config Server
kubectl apply -f deployments/config-server-deployment.yaml
kubectl apply -f services/config-server-service.yaml

# 3. 部署 User Service
kubectl apply -f deployments/user-service-deployment.yaml
kubectl apply -f services/user-service-service.yaml

# 4. 部署 Shift Service
kubectl apply -f deployments/shift-service-deployment.yaml
kubectl apply -f services/shift-service-service.yaml

# 5. 部署 API Gateway
kubectl apply -f deployments/api-gateway-deployment.yaml
kubectl apply -f services/api-gateway-service.yaml
```

### 步骤 4: 验证部署

```bash
# 查看所有 Pod 状态
kubectl get pods

# 查看服务
kubectl get services

# 查看日志
kubectl logs -f deployment/eureka-server
```

### 步骤 5: 访问服务

#### 使用端口转发

```bash
# API Gateway
kubectl port-forward service/api-gateway 8080:8080

# Eureka Dashboard
kubectl port-forward service/eureka-server 8761:8761

# User Service
kubectl port-forward service/user-service 8081:8081

# Shift Service
kubectl port-forward service/shift-service 8082:8082
```

#### 使用 Minikube Service（仅 Minikube）

```bash
# 暴露服务到本地
minikube service api-gateway
minikube service eureka-server
```

#### 访问地址

- **API Gateway**: http://localhost:8080
- **Eureka Dashboard**: http://localhost:8761
- **User Service**: http://localhost:8081
- **Shift Service**: http://localhost:8082

## 🔧 配置说明

### 镜像拉取策略

本地部署使用 `IfNotPresent`，优先使用本地镜像：

```yaml
imagePullPolicy: IfNotPresent
```

### 资源限制

本地部署可以设置较小的资源限制：

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 副本数

本地部署可以设置为 1 个副本：

```yaml
replicas: 1
```

## 🐛 故障排查

### Pod 无法启动

```bash
# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>

# 检查事件
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 镜像拉取失败

```bash
# 检查镜像是否存在
docker images | grep staffjoy

# Minikube: 重新加载镜像
minikube image load staffjoy-eureka-server:latest

# Kind: 重新加载镜像
kind load docker-image staffjoy-eureka-server:latest --name staffjoy
```

### 服务无法访问

```bash
# 检查 Service 端点
kubectl get endpoints <service-name>

# 测试服务连通性
kubectl exec -it <pod-name> -- curl http://service-name:port/actuator/health
```

### Minikube 问题

```bash
# 重启 Minikube
minikube stop
minikube start

# 删除并重新创建
minikube delete
minikube start
```

### Kind 问题

```bash
# 删除并重新创建集群
kind delete cluster --name staffjoy
kind create cluster --name staffjoy
```

## 🧹 清理资源

```bash
# 删除所有部署
kubectl delete -f k8s/deployments/
kubectl delete -f k8s/services/

# 删除所有资源（包括 ConfigMap、Secret 等）
kubectl delete all --all

# Minikube: 停止集群
minikube stop

# Kind: 删除集群
kind delete cluster --name staffjoy
```

## 📚 相关文档

- [通用 Kubernetes 部署指南](../README.md)
- [Minikube 文档](https://minikube.sigs.k8s.io/docs/)
- [Kind 文档](https://kind.sigs.k8s.io/)
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)

