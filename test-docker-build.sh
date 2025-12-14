#!/bin/bash

# Docker 构建测试脚本
# 用于测试所有服务的 Docker 构建

set -e  # 遇到错误立即退出

echo "=========================================="
echo "Docker 构建测试"
echo "=========================================="
echo ""

# 检查 Docker 是否运行
if ! docker ps > /dev/null 2>&1; then
    echo "❌ 错误: Docker daemon 未运行"
    echo "请先启动 Docker Desktop，然后重新运行此脚本"
    exit 1
fi

echo "✅ Docker daemon 正在运行"
echo ""

# 测试单个服务的 Dockerfile 构建
test_build() {
    local service=$1
    local dockerfile=$2
    
    echo "----------------------------------------"
    echo "测试构建: $service"
    echo "Dockerfile: $dockerfile"
    echo "----------------------------------------"
    
    if docker build -f "$dockerfile" -t "staffjoy-$service:test" . > /tmp/docker-build-$service.log 2>&1; then
        echo "✅ $service 构建成功"
        # 清理测试镜像
        docker rmi "staffjoy-$service:test" > /dev/null 2>&1 || true
        return 0
    else
        echo "❌ $service 构建失败"
        echo "查看日志: tail -50 /tmp/docker-build-$service.log"
        return 1
    fi
}

# 测试所有服务的构建
echo "开始测试各个服务的 Dockerfile 构建..."
echo ""

failed_services=()

# 测试 Eureka Server
if ! test_build "eureka-server" "eureka-server/Dockerfile"; then
    failed_services+=("eureka-server")
fi

# 测试 Config Server
if ! test_build "config-server" "config-server/Dockerfile"; then
    failed_services+=("config-server")
fi

# 测试 User Service
if ! test_build "user-service" "user-service/Dockerfile"; then
    failed_services+=("user-service")
fi

# 测试 Shift Service
if ! test_build "shift-service" "shift-service/Dockerfile"; then
    failed_services+=("shift-service")
fi

# 测试 API Gateway
if ! test_build "api-gateway" "api-gateway/Dockerfile"; then
    failed_services+=("api-gateway")
fi

echo ""
echo "=========================================="
echo "构建测试结果"
echo "=========================================="

if [ ${#failed_services[@]} -eq 0 ]; then
    echo "✅ 所有服务构建成功！"
    echo ""
    echo "下一步: 运行 docker-compose up --build 启动所有服务"
else
    echo "❌ 以下服务构建失败:"
    for service in "${failed_services[@]}"; do
        echo "  - $service"
    done
    echo ""
    echo "查看详细日志:"
    for service in "${failed_services[@]}"; do
        echo "  tail -50 /tmp/docker-build-$service.log"
    done
    exit 1
fi

