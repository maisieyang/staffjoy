#!/bin/bash

# 阿里云 ACR 镜像构建和推送脚本
# 使用方法: ./build-and-push-images.sh [版本标签]

set -e

# 配置变量（请根据实际情况修改）
ACR_REGISTRY="${ACR_REGISTRY:-registry.cn-hangzhou.aliyuncs.com}"
ACR_NAMESPACE="${ACR_NAMESPACE:-staffjoy}"
IMAGE_TAG="${1:-latest}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=========================================="
echo "阿里云 ACR 镜像构建和推送"
echo "=========================================="
echo "镜像仓库: ${ACR_REGISTRY}"
echo "命名空间: ${ACR_NAMESPACE}"
echo "版本标签: ${IMAGE_TAG}"
echo "=========================================="
echo ""

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker 未运行或无法访问"
    exit 1
fi

# 检查是否已登录 ACR
if ! docker info | grep -q "${ACR_REGISTRY}"; then
    echo "⚠️  警告: 可能未登录到 ACR，请先执行："
    echo "   docker login ${ACR_REGISTRY}"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 定义服务列表
SERVICES=(
    "eureka-server"
    "config-server"
    "user-service"
    "shift-service"
    "api-gateway"
)

# 构建和推送镜像
for service in "${SERVICES[@]}"; do
    echo "📦 构建 ${service}..."
    
    IMAGE_NAME="${ACR_REGISTRY}/${ACR_NAMESPACE}/${service}:${IMAGE_TAG}"
    
    # 构建镜像
    docker build \
        -f "${PROJECT_ROOT}/${service}/Dockerfile" \
        -t "${IMAGE_NAME}" \
        -t "${ACR_REGISTRY}/${ACR_NAMESPACE}/${service}:latest" \
        "${PROJECT_ROOT}"
    
    echo "   ✅ 构建完成: ${IMAGE_NAME}"
    
    # 推送镜像
    echo "   📤 推送镜像..."
    docker push "${IMAGE_NAME}"
    docker push "${ACR_REGISTRY}/${ACR_NAMESPACE}/${service}:latest"
    
    echo "   ✅ 推送完成: ${IMAGE_NAME}"
    echo ""
done

echo "=========================================="
echo "✅ 所有镜像构建和推送完成！"
echo "=========================================="
echo ""
echo "镜像列表："
for service in "${SERVICES[@]}"; do
    echo "  - ${ACR_REGISTRY}/${ACR_NAMESPACE}/${service}:${IMAGE_TAG}"
done
echo ""

