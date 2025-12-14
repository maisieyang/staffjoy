#!/bin/bash

# 构建本地 Docker 镜像脚本

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE_TAG="${1:-latest}"

echo "=========================================="
echo "构建本地 Docker 镜像"
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

echo "✅ Docker 运行正常"
echo ""

# 定义服务列表
SERVICES=(
    "eureka-server"
    "config-server"
    "user-service"
    "shift-service"
    "api-gateway"
)

# 构建镜像
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
    echo ""
done

echo "=========================================="
echo "✅ 所有镜像构建完成！"
echo "=========================================="
echo ""
echo "镜像列表："
docker images | grep staffjoy | head -10
echo ""

