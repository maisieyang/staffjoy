#!/bin/bash

# Staffjoy Kubernetes 部署脚本
# 使用方法: ./deploy.sh [namespace]

set -e  # 遇到错误立即退出

NAMESPACE=${1:-default}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Staffjoy Kubernetes 部署脚本"
echo "命名空间: $NAMESPACE"
echo "=========================================="
echo ""

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ 错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 检查 Kubernetes 集群连接
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 错误: 无法连接到 Kubernetes 集群"
    exit 1
fi

echo "✅ Kubernetes 集群连接正常"
echo ""

# 创建命名空间（如果不存在）
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "📦 创建命名空间: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi

# 设置当前命名空间
kubectl config set-context --current --namespace="$NAMESPACE"

echo "🚀 开始部署服务..."
echo ""

# 1. 部署 Eureka Server
echo "1️⃣  部署 Eureka Server..."
kubectl apply -f "$SCRIPT_DIR/deployments/eureka-server-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/services/eureka-server-service.yaml"
echo "   等待 Eureka Server 就绪..."
kubectl wait --for=condition=available --timeout=120s deployment/eureka-server -n "$NAMESPACE" || {
    echo "⚠️  Eureka Server 启动超时，继续部署其他服务..."
}
echo "   ✅ Eureka Server 部署完成"
echo ""

# 2. 部署 Config Server（可选）
echo "2️⃣  部署 Config Server..."
kubectl apply -f "$SCRIPT_DIR/deployments/config-server-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/services/config-server-service.yaml"
echo "   ✅ Config Server 部署完成"
echo ""

# 3. 部署 User Service
echo "3️⃣  部署 User Service..."
kubectl apply -f "$SCRIPT_DIR/deployments/user-service-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/services/user-service-service.yaml"
echo "   ✅ User Service 部署完成"
echo ""

# 4. 部署 Shift Service
echo "4️⃣  部署 Shift Service..."
kubectl apply -f "$SCRIPT_DIR/deployments/shift-service-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/services/shift-service-service.yaml"
echo "   ✅ Shift Service 部署完成"
echo ""

# 5. 部署 API Gateway
echo "5️⃣  部署 API Gateway..."
kubectl apply -f "$SCRIPT_DIR/deployments/api-gateway-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/services/api-gateway-service.yaml"
echo "   ✅ API Gateway 部署完成"
echo ""

# 6. 部署 Ingress（可选）
echo "6️⃣  部署 Ingress..."
kubectl apply -f "$SCRIPT_DIR/ingress/api-ingress.yaml" || {
    echo "⚠️  Ingress 部署失败（可能未安装 Ingress Controller）"
}
echo ""

# 等待所有服务就绪
echo "⏳ 等待所有服务就绪..."
sleep 10

# 显示部署状态
echo "=========================================="
echo "📊 部署状态"
echo "=========================================="
kubectl get pods -n "$NAMESPACE"
echo ""
kubectl get services -n "$NAMESPACE"
echo ""

# 显示访问信息
echo "=========================================="
echo "🌐 访问信息"
echo "=========================================="
echo ""
echo "端口转发访问："
echo "  kubectl port-forward -n $NAMESPACE service/api-gateway 8080:8080"
echo "  kubectl port-forward -n $NAMESPACE service/eureka-server 8761:8761"
echo ""
echo "查看日志："
echo "  kubectl logs -n $NAMESPACE -f deployment/eureka-server"
echo "  kubectl logs -n $NAMESPACE -f deployment/user-service"
echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo "=========================================="

