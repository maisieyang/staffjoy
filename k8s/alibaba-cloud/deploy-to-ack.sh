#!/bin/bash

# 部署到阿里云 ACK 集群脚本
# 使用方法: ./deploy-to-ack.sh [命名空间] [镜像版本]

set -e

NAMESPACE=${1:-default}
IMAGE_TAG=${2:-latest}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="${SCRIPT_DIR}/.."

echo "=========================================="
echo "部署到阿里云 ACK 集群"
echo "=========================================="
echo "命名空间: ${NAMESPACE}"
echo "镜像版本: ${IMAGE_TAG}"
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
    echo "   请先配置 kubectl 连接到 ACK 集群"
    exit 1
fi

echo "✅ Kubernetes 集群连接正常"
kubectl cluster-info | head -1
echo ""

# 创建命名空间（如果不存在）
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "📦 创建命名空间: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi

# 设置当前命名空间
kubectl config set-context --current --namespace="$NAMESPACE"

# 检查 ACR Secret 是否存在
if ! kubectl get secret acr-secret -n "$NAMESPACE" &> /dev/null; then
    echo "⚠️  警告: ACR Secret 不存在"
    echo "   请先创建 ACR Secret:"
    echo "   kubectl create secret docker-registry acr-secret \\"
    echo "     --docker-server=registry.cn-hangzhou.aliyuncs.com \\"
    echo "     --docker-username=YOUR_USERNAME \\"
    echo "     --docker-password=YOUR_PASSWORD \\"
    echo "     --namespace=${NAMESPACE}"
    echo ""
    read -p "是否继续部署？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🚀 开始部署服务..."
echo ""

# 1. 部署 Eureka Server
echo "1️⃣  部署 Eureka Server..."
kubectl apply -f "${K8S_DIR}/deployments/eureka-server-deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "${K8S_DIR}/services/eureka-server-service.yaml" -n "$NAMESPACE"
echo "   等待 Eureka Server 就绪..."
kubectl wait --for=condition=available --timeout=120s deployment/eureka-server -n "$NAMESPACE" || {
    echo "⚠️  Eureka Server 启动超时，继续部署其他服务..."
}
echo "   ✅ Eureka Server 部署完成"
echo ""

# 2. 部署 Config Server
echo "2️⃣  部署 Config Server..."
kubectl apply -f "${K8S_DIR}/deployments/config-server-deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "${K8S_DIR}/services/config-server-service.yaml" -n "$NAMESPACE"
echo "   ✅ Config Server 部署完成"
echo ""

# 3. 部署 User Service
echo "3️⃣  部署 User Service..."
kubectl apply -f "${K8S_DIR}/deployments/user-service-deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "${K8S_DIR}/services/user-service-service.yaml" -n "$NAMESPACE"
echo "   ✅ User Service 部署完成"
echo ""

# 4. 部署 Shift Service
echo "4️⃣  部署 Shift Service..."
kubectl apply -f "${K8S_DIR}/deployments/shift-service-deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "${K8S_DIR}/services/shift-service-service.yaml" -n "$NAMESPACE"
echo "   ✅ Shift Service 部署完成"
echo ""

# 5. 部署 API Gateway
echo "5️⃣  部署 API Gateway..."
kubectl apply -f "${K8S_DIR}/deployments/api-gateway-deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "${K8S_DIR}/services/api-gateway-service.yaml" -n "$NAMESPACE"
echo "   ✅ API Gateway 部署完成"
echo ""

# 6. 部署 Ingress（如果存在）
if [ -f "${SCRIPT_DIR}/ingress/alb-ingress.yaml" ]; then
    echo "6️⃣  部署 ALB Ingress..."
    kubectl apply -f "${SCRIPT_DIR}/ingress/alb-ingress.yaml" -n "$NAMESPACE" || {
        echo "⚠️  Ingress 部署失败（可能未安装 ALB Ingress Controller）"
    }
    echo ""
fi

# 等待所有服务就绪
echo "⏳ 等待所有服务就绪..."
sleep 15

# 显示部署状态
echo "=========================================="
echo "📊 部署状态"
echo "=========================================="
kubectl get pods -n "$NAMESPACE"
echo ""
kubectl get services -n "$NAMESPACE"
echo ""

# 显示 Ingress 信息
if kubectl get ingress -n "$NAMESPACE" &> /dev/null; then
    echo "=========================================="
    echo "🌐 Ingress 信息"
    echo "=========================================="
    kubectl get ingress -n "$NAMESPACE"
    echo ""
fi

# 显示访问信息
echo "=========================================="
echo "🌐 访问信息"
echo "=========================================="
echo ""
echo "查看服务状态："
echo "  kubectl get pods -n ${NAMESPACE}"
echo "  kubectl get services -n ${NAMESPACE}"
echo ""
echo "查看日志："
echo "  kubectl logs -n ${NAMESPACE} -f deployment/eureka-server"
echo "  kubectl logs -n ${NAMESPACE} -f deployment/user-service"
echo ""
echo "端口转发（本地访问）："
echo "  kubectl port-forward -n ${NAMESPACE} service/api-gateway 8080:8080"
echo "  kubectl port-forward -n ${NAMESPACE} service/eureka-server 8761:8761"
echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo "=========================================="

