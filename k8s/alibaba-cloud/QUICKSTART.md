# 阿里云部署快速开始

本文档提供最简化的部署步骤，帮助您快速将应用部署到阿里云 ACK。

## ⚡ 5分钟快速部署

### 前置条件检查清单

- [ ] 已创建阿里云账号
- [ ] 已开通 ACK（容器服务 Kubernetes 版）
- [ ] 已开通 ACR（容器镜像服务）
- [ ] 已创建 ACK 集群
- [ ] 已安装并配置 kubectl
- [ ] 已安装 Docker

### 步骤 1: 配置环境变量

```bash
# 设置 ACR 配置（请根据实际情况修改）
export ACR_REGISTRY="registry.cn-hangzhou.aliyuncs.com"  # 修改为你的地域
export ACR_NAMESPACE="staffjoy"  # 修改为你的 ACR 命名空间
export ACR_USERNAME="your-username"  # 你的 ACR 用户名
export ACR_PASSWORD="your-password"  # 你的 ACR 密码
export IMAGE_TAG="v1.0.0"  # 镜像版本
```

### 步骤 2: 登录 ACR

```bash
docker login ${ACR_REGISTRY} -u ${ACR_USERNAME} -p ${ACR_PASSWORD}
```

### 步骤 3: 构建并推送镜像

```bash
cd k8s/alibaba-cloud
./build-and-push-images.sh ${IMAGE_TAG}
```

### 步骤 4: 配置 ACK 集群访问

```bash
# 在 ACK 控制台获取连接命令，类似：
aliyun cs GET /k8s/clusters/YOUR_CLUSTER_ID/user_config --region cn-hangzhou | jq -r '.config' | base64 -d > ~/.kube/config

# 验证连接
kubectl cluster-info
```

### 步骤 5: 创建镜像拉取密钥

```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=${ACR_REGISTRY} \
  --docker-username=${ACR_USERNAME} \
  --docker-password=${ACR_PASSWORD} \
  --docker-email=your-email@example.com \
  --namespace=default
```

### 步骤 6: 更新部署配置

```bash
# 更新所有 Deployment 文件中的镜像地址
./update-image-references.sh ${IMAGE_TAG}
```

### 步骤 7: 部署到 ACK

```bash
# 一键部署
./deploy-to-ack.sh default ${IMAGE_TAG}
```

### 步骤 8: 验证部署

```bash
# 查看 Pod 状态
kubectl get pods

# 查看服务
kubectl get services

# 查看日志
kubectl logs -f deployment/eureka-server
```

## 🎯 一键部署脚本（完整流程）

如果您想一次性完成所有步骤，可以使用以下脚本：

```bash
#!/bin/bash
# 一键部署脚本

# 1. 配置变量
export ACR_REGISTRY="registry.cn-hangzhou.aliyuncs.com"
export ACR_NAMESPACE="staffjoy"
export ACR_USERNAME="your-username"
export ACR_PASSWORD="your-password"
export IMAGE_TAG="v1.0.0"

# 2. 登录 ACR
docker login ${ACR_REGISTRY} -u ${ACR_USERNAME} -p ${ACR_PASSWORD}

# 3. 构建并推送镜像
cd k8s/alibaba-cloud
./build-and-push-images.sh ${IMAGE_TAG}

# 4. 更新镜像地址
./update-image-references.sh ${IMAGE_TAG}

# 5. 创建 Secret（如果不存在）
kubectl create secret docker-registry acr-secret \
  --docker-server=${ACR_REGISTRY} \
  --docker-username=${ACR_USERNAME} \
  --docker-password=${ACR_PASSWORD} \
  --docker-email=your-email@example.com \
  --namespace=default \
  --dry-run=client -o yaml | kubectl apply -f -

# 6. 部署到 ACK
./deploy-to-ack.sh default ${IMAGE_TAG}
```

## 📝 常见问题

### Q1: 如何选择 ACR 地域？

**A:** 选择与 ACK 集群相同的地域，以减少网络延迟和流量费用。

### Q2: 如何获取 ACR 用户名和密码？

**A:** 
1. 登录 [ACR 控制台](https://cr.console.aliyun.com/)
2. 进入 **访问凭证** → **设置固定密码**
3. 设置密码后即可使用

### Q3: 如何获取 ACK 集群连接信息？

**A:**
1. 登录 [ACK 控制台](https://cs.console.aliyun.com/)
2. 选择你的集群 → **连接信息**
3. 复制 `kubectl` 连接命令并执行

### Q4: 镜像推送失败怎么办？

**A:** 
- 检查是否已登录 ACR：`docker login ${ACR_REGISTRY}`
- 检查命名空间是否存在
- 检查网络连接

### Q5: Pod 无法启动，提示镜像拉取失败？

**A:**
- 检查 ACR Secret 是否存在：`kubectl get secret acr-secret`
- 检查镜像地址是否正确
- 检查 Secret 中的用户名密码是否正确

## 🔗 相关链接

- [详细部署文档](README.md)
- [阿里云 ACK 文档](https://help.aliyun.com/product/85222.html)
- [阿里云 ACR 文档](https://help.aliyun.com/product/60716.html)

