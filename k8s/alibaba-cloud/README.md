# 阿里云 ACK 部署指南

本文档介绍如何将 Staffjoy 微服务应用部署到**阿里云 ACK (Alibaba Cloud Container Service for Kubernetes) 集群**。

> 💡 **说明：** 这是针对阿里云 ACK 的特定配置，使用了阿里云 ACR（镜像仓库）和 ALB Ingress（负载均衡）。  
> 如果您需要部署到其他 Kubernetes 环境（本地、Google GKE、AWS EKS 等），请参考：[通用 Kubernetes 部署指南](../README.md)  
> 想了解两种部署方式的区别？请查看：[部署方式对比](../DEPLOYMENT_COMPARISON.md)

## 📋 前置要求

1. **阿里云账号**
   - 已开通容器服务 ACK
   - 已开通容器镜像服务 ACR

2. **ACK 集群**
   - 已创建 Kubernetes 集群（推荐托管版）
   - 已配置 kubectl 连接到集群

3. **ACR 镜像仓库**
   - 已创建命名空间（Namespace）
   - 已配置镜像仓库访问凭证

## 🏗️ 架构概览

```
阿里云 ACK 集群
├── Eureka Server (服务发现)
├── Config Server (配置中心)
├── User Service (用户服务)
├── Shift Service (排班服务)
└── API Gateway (API 网关)
    └── ALB Ingress (阿里云应用型负载均衡)
```

## 🚀 部署步骤

### 步骤 1: 配置 ACR 镜像仓库

#### 1.1 创建 ACR 命名空间

1. 登录 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 选择 **命名空间** → **创建命名空间**
3. 输入命名空间名称（如：`staffjoy`）
4. 选择地域（建议与 ACK 集群在同一地域）

#### 1.2 配置镜像仓库访问凭证

```bash
# 方式1：使用阿里云 CLI 配置（推荐）
aliyun configure set \
  --profile default \
  --mode AK \
  --region cn-hangzhou \
  --access-key-id YOUR_ACCESS_KEY_ID \
  --access-key-secret YOUR_ACCESS_KEY_SECRET

# 方式2：使用 Docker 登录
# 获取登录命令：ACR 控制台 → 访问凭证 → 设置固定密码 → 复制登录命令
docker login --username=YOUR_USERNAME registry.cn-hangzhou.aliyuncs.com
```

### 步骤 2: 构建并推送镜像到 ACR

#### 2.1 设置镜像仓库地址

```bash
# 设置变量（请根据实际情况修改）
export ACR_REGISTRY="registry.cn-hangzhou.aliyuncs.com"  # 根据地域修改
export ACR_NAMESPACE="staffjoy"  # 你的 ACR 命名空间
export IMAGE_TAG="v1.0.0"  # 镜像版本标签

# 完整的镜像地址格式：${ACR_REGISTRY}/${ACR_NAMESPACE}/服务名:${IMAGE_TAG}
```

#### 2.2 构建和推送镜像

使用提供的脚本自动构建和推送：

```bash
cd k8s/alibaba-cloud
chmod +x build-and-push-images.sh
./build-and-push-images.sh
```

或者手动执行：

```bash
# 1. 构建镜像
docker build -f eureka-server/Dockerfile -t ${ACR_REGISTRY}/${ACR_NAMESPACE}/eureka-server:${IMAGE_TAG} .
docker build -f config-server/Dockerfile -t ${ACR_REGISTRY}/${ACR_NAMESPACE}/config-server:${IMAGE_TAG} .
docker build -f user-service/Dockerfile -t ${ACR_REGISTRY}/${ACR_NAMESPACE}/user-service:${IMAGE_TAG} .
docker build -f shift-service/Dockerfile -t ${ACR_REGISTRY}/${ACR_NAMESPACE}/shift-service:${IMAGE_TAG} .
docker build -f api-gateway/Dockerfile -t ${ACR_REGISTRY}/${ACR_NAMESPACE}/api-gateway:${IMAGE_TAG} .

# 2. 推送镜像
docker push ${ACR_REGISTRY}/${ACR_NAMESPACE}/eureka-server:${IMAGE_TAG}
docker push ${ACR_REGISTRY}/${ACR_NAMESPACE}/config-server:${IMAGE_TAG}
docker push ${ACR_REGISTRY}/${ACR_NAMESPACE}/user-service:${IMAGE_TAG}
docker push ${ACR_REGISTRY}/${ACR_NAMESPACE}/shift-service:${IMAGE_TAG}
docker push ${ACR_REGISTRY}/${ACR_NAMESPACE}/api-gateway:${IMAGE_TAG}
```

### 步骤 3: 配置 ACK 集群访问

#### 3.1 获取集群凭证

1. 登录 [ACK 控制台](https://cs.console.aliyun.com/)
2. 选择你的集群 → **连接信息**
3. 复制 `kubectl` 连接命令并执行

```bash
# 示例（请使用控制台提供的实际命令）
aliyun cs GET /k8s/clusters/YOUR_CLUSTER_ID/user_config --region cn-hangzhou | jq -r '.config' | base64 -d > ~/.kube/config
```

#### 3.2 验证连接

```bash
kubectl cluster-info
kubectl get nodes
```

### 步骤 4: 配置镜像拉取密钥

ACK 需要从 ACR 拉取镜像，需要配置镜像拉取密钥：

```bash
# 创建 Secret（用于拉取私有镜像）
kubectl create secret docker-registry acr-secret \
  --docker-server=${ACR_REGISTRY} \
  --docker-username=YOUR_ACR_USERNAME \
  --docker-password=YOUR_ACR_PASSWORD \
  --docker-email=your-email@example.com \
  --namespace=default

# 如果使用命名空间
kubectl create secret docker-registry acr-secret \
  --docker-server=${ACR_REGISTRY} \
  --docker-username=YOUR_ACR_USERNAME \
  --docker-password=YOUR_ACR_PASSWORD \
  --docker-email=your-email@example.com \
  --namespace=staffjoy
```

### 步骤 5: 更新部署配置

#### 5.1 更新镜像地址

使用提供的脚本自动更新：

```bash
cd k8s/alibaba-cloud
chmod +x update-image-references.sh
./update-image-references.sh
```

脚本会将所有 Deployment 中的镜像地址更新为 ACR 地址。

#### 5.2 配置镜像拉取密钥

所有 Deployment 需要添加 `imagePullSecrets`：

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: acr-secret
      containers:
      - name: eureka-server
        image: registry.cn-hangzhou.aliyuncs.com/staffjoy/eureka-server:v1.0.0
        imagePullPolicy: Always
```

### 步骤 6: 部署到 ACK

#### 6.1 使用部署脚本

```bash
cd k8s/alibaba-cloud
chmod +x deploy-to-ack.sh
./deploy-to-ack.sh
```

#### 6.2 手动部署

```bash
# 1. 创建命名空间（可选）
kubectl create namespace staffjoy

# 2. 部署 Eureka Server
kubectl apply -f deployments/eureka-server-deployment.yaml
kubectl apply -f services/eureka-server-service.yaml

# 3. 等待 Eureka Server 就绪
kubectl wait --for=condition=available --timeout=120s deployment/eureka-server

# 4. 部署其他服务
kubectl apply -f deployments/config-server-deployment.yaml
kubectl apply -f services/config-server-service.yaml

kubectl apply -f deployments/user-service-deployment.yaml
kubectl apply -f services/user-service-service.yaml

kubectl apply -f deployments/shift-service-deployment.yaml
kubectl apply -f services/shift-service-service.yaml

kubectl apply -f deployments/api-gateway-deployment.yaml
kubectl apply -f services/api-gateway-service.yaml

# 5. 部署 Ingress（使用阿里云 ALB）
kubectl apply -f ingress/alb-ingress.yaml
```

### 步骤 7: 配置 Ingress（外部访问）

#### 7.1 使用阿里云 ALB Ingress

阿里云 ACK 支持 ALB Ingress Controller，提供应用型负载均衡。

```bash
# 部署 ALB Ingress
kubectl apply -f ingress/alb-ingress.yaml
```

#### 7.2 获取访问地址

```bash
# 查看 Ingress 状态
kubectl get ingress api-ingress

# 获取 ALB 地址
kubectl describe ingress api-ingress | grep Address
```

### 步骤 8: 验证部署

```bash
# 查看所有 Pod 状态
kubectl get pods -o wide

# 查看服务状态
kubectl get services

# 查看 Ingress
kubectl get ingress

# 查看日志
kubectl logs -f deployment/eureka-server
kubectl logs -f deployment/user-service
```

## 🔧 配置说明

### 镜像地址格式

```
registry.cn-<地域>.aliyuncs.com/<命名空间>/<服务名>:<版本>
```

示例：
```
registry.cn-hangzhou.aliyuncs.com/staffjoy/eureka-server:v1.0.0
```

### 地域选择

| 地域代码 | 地域名称 |
|---------|---------|
| cn-hangzhou | 华东1（杭州）|
| cn-shanghai | 华东2（上海）|
| cn-beijing | 华北2（北京）|
| cn-shenzhen | 华南1（深圳）|

**建议：** ACR 命名空间和 ACK 集群选择同一地域，以减少网络延迟和流量费用。

### 镜像拉取策略

生产环境使用 `Always`，确保每次拉取最新镜像：

```yaml
imagePullPolicy: Always
```

### 资源配置

根据实际负载调整资源限制：

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 💰 成本优化建议

1. **选择合适的地域**：选择离用户最近的地域
2. **使用抢占式实例**：开发/测试环境可使用抢占式 ECS
3. **合理设置副本数**：根据实际负载调整
4. **使用弹性伸缩**：配置 HPA 自动扩缩容
5. **镜像优化**：使用多阶段构建减小镜像体积

## 🔒 安全建议

1. **使用私有镜像仓库**：不要使用公开镜像
2. **配置网络策略**：使用 NetworkPolicy 限制 Pod 间通信
3. **使用 RBAC**：配置适当的角色和权限
4. **启用 TLS**：所有外部通信使用 HTTPS
5. **定期更新镜像**：及时修复安全漏洞

## 🐛 故障排查

### 镜像拉取失败

```bash
# 检查 Secret 是否存在
kubectl get secret acr-secret

# 检查 Pod 事件
kubectl describe pod <pod-name>

# 手动测试镜像拉取
docker pull registry.cn-hangzhou.aliyuncs.com/staffjoy/eureka-server:v1.0.0
```

### Pod 无法启动

```bash
# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>

# 检查事件
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 服务无法访问

```bash
# 检查 Service 端点
kubectl get endpoints <service-name>

# 检查 Ingress
kubectl describe ingress api-ingress

# 测试服务连通性
kubectl exec -it <pod-name> -- curl http://service-name:port/actuator/health
```

## 📚 相关文档

- [阿里云 ACK 文档](https://help.aliyun.com/product/85222.html)
- [阿里云 ACR 文档](https://help.aliyun.com/product/60716.html)
- [ALB Ingress Controller](https://help.aliyun.com/document_detail/200300.html)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)

## 🔄 更新部署

```bash
# 1. 构建新版本镜像
./build-and-push-images.sh

# 2. 更新镜像版本
export IMAGE_TAG="v1.0.1"
./update-image-references.sh

# 3. 滚动更新
kubectl set image deployment/user-service user-service=registry.cn-hangzhou.aliyuncs.com/staffjoy/user-service:v1.0.1

# 4. 查看更新状态
kubectl rollout status deployment/user-service
```

## 🗑️ 清理资源

```bash
# 删除所有部署
kubectl delete -f deployments/
kubectl delete -f services/
kubectl delete -f ingress/

# 删除 Secret
kubectl delete secret acr-secret

# 删除命名空间（会删除命名空间内所有资源）
kubectl delete namespace staffjoy
```

