# Docker Desktop Kubernetes 设置指南

## 📋 启用 Kubernetes

### 步骤 1: 打开 Docker Desktop

启动 Docker Desktop 应用。

### 步骤 2: 进入设置

点击右上角的 **⚙️ Settings（设置）** 图标。

### 步骤 3: 启用 Kubernetes

1. 在左侧菜单选择 **Kubernetes**
2. 勾选 **Enable Kubernetes**
3. 点击 **Apply & Restart**
4. 等待 Kubernetes 启动完成（可能需要几分钟）

### 步骤 4: 验证

Kubernetes 状态应该显示为绿色，表示已启用。

## ✅ 验证 Kubernetes 已启用

在终端运行：

```bash
kubectl cluster-info
kubectl get nodes
```

如果看到节点信息，说明 Kubernetes 已成功启用。

## 🚀 开始部署

启用 Kubernetes 后，运行部署脚本：

```bash
cd k8s/local
./deploy-local.sh
```

## 🐛 常见问题

### Q: Kubernetes 启动失败？

**A:** 
1. 确保 Docker Desktop 有足够的资源（建议至少 4GB 内存）
2. 重启 Docker Desktop
3. 检查系统资源使用情况

### Q: 如何查看 Kubernetes 状态？

**A:** 在 Docker Desktop 的 Kubernetes 设置页面可以看到状态。

### Q: 如何重置 Kubernetes？

**A:** 在 Docker Desktop 的 Kubernetes 设置页面，点击 **Reset Kubernetes Cluster**。

