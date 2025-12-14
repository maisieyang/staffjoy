#!/bin/bash

# 构建并加载镜像到本地 Kubernetes 集群（Minikube/Kind）

set -e

K8S_TYPE="${1:-minikube}"  # minikube 或 kind
IMAGE_TAG="${2:-latest}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=========================================="
echo "构建并加载镜像到 ${K8S_TYPE}"
echo "=========================================="
echo "项目根目录: ${PROJECT_ROOT}"
echo "镜像标签: ${IMAGE_TAG}"
echo "=========================================="
echo ""

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker 未运行或无法访问"
    exit 1
fi

# 检查 Kubernetes 工具
case "$K8S_TYPE" in
    minikube)
        if ! command -v minikube &> /dev/null; then
            echo "❌ 错误: minikube 未安装"
            exit 1
        fi
        if ! minikube status &> /dev/null; then
            echo "⚠️  警告: Minikube 集群未运行"
            echo "   正在启动 Minikube..."
            minikube start
        fi
        echo "✅ Minikube 集群运行正常"
        ;;
    kind)
        if ! command -v kind &> /dev/null; then
            echo "❌ 错误: kind 未安装"
            exit 1
        fi
        if ! kubectl cluster-info --context kind-staffjoy &> /dev/null 2>&1; then
            echo "⚠️  警告: Kind 集群未创建或未运行"
            echo "   请先创建集群: kind create cluster --name staffjoy"
            exit 1
        fi
        echo "✅ Kind 集群运行正常"
        ;;
    *)
        echo "❌ 错误: 不支持的 Kubernetes 类型: ${K8S_TYPE}"
        echo "   支持的类型: minikube, kind"
        exit 1
        ;;
esac

echo ""

# 定义服务列表
SERVICES=(
    "eureka-server"
    "config-server"
    "user-service"
    "shift-service"
    "api-gateway"
)

# 构建并加载镜像
for service in "${SERVICES[@]}"; do
    echo "📦 构建 ${service}..."
    
    IMAGE_NAME="staffjoy-${service}:${IMAGE_TAG}"
    
    # 构建镜像
    docker build \
        -f "${PROJECT_ROOT}/${service}/Dockerfile" \
        -t "${IMAGE_NAME}" \
        -t "staffjoy-${service}:latest" \
        "${PROJECT_ROOT}"
    
    echo "   ✅ 构建完成: ${IMAGE_NAME}"
    
    # 加载镜像到 Kubernetes
    echo "   📤 加载镜像到 ${K8S_TYPE}..."
    case "$K8S_TYPE" in
        minikube)
            minikube image load "${IMAGE_NAME}"
            minikube image load "staffjoy-${service}:latest"
            ;;
        kind)
            kind load docker-image "${IMAGE_NAME}" --name staffjoy
            kind load docker-image "staffjoy-${service}:latest" --name staffjoy
            ;;
    esac
    
    echo "   ✅ 加载完成"
    echo ""
done

echo "=========================================="
echo "✅ 所有镜像构建和加载完成！"
echo "=========================================="
echo ""
echo "镜像列表："
case "$K8S_TYPE" in
    minikube)
        minikube image ls | grep staffjoy || echo "（使用 minikube ssh 'docker images' 查看）"
        ;;
    kind)
        docker images | grep staffjoy | head -10
        ;;
esac
echo ""

