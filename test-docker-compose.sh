#!/bin/bash

# Docker Compose 测试脚本
# 用于测试 docker-compose 构建和启动

set -e  # 遇到错误立即退出

echo "=========================================="
echo "Docker Compose 测试"
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

# 检查 docker-compose.yml 语法
echo "1. 检查 docker-compose.yml 语法..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ docker-compose.yml 语法正确"
else
    echo "❌ docker-compose.yml 语法错误"
    docker-compose config
    exit 1
fi
echo ""

# 构建所有服务（不启动）
echo "2. 构建所有服务镜像..."
if docker-compose build --no-cache 2>&1 | tee /tmp/docker-compose-build.log; then
    echo ""
    echo "✅ 所有服务镜像构建成功"
else
    echo ""
    echo "❌ 镜像构建失败，查看日志: tail -50 /tmp/docker-compose-build.log"
    exit 1
fi
echo ""

# 验证镜像是否创建
echo "3. 验证镜像..."
images=$(docker images | grep staffjoy | awk '{print $1":"$2}' || echo "")
if [ -z "$images" ]; then
    echo "⚠️  未找到 staffjoy 镜像（可能使用了不同的命名）"
else
    echo "✅ 找到以下镜像:"
    echo "$images" | while read img; do
        echo "  - $img"
    done
fi
echo ""

# 检查服务配置
echo "4. 检查服务配置..."
docker-compose config --services | while read service; do
    echo "  ✅ $service"
done
echo ""

echo "=========================================="
echo "测试完成！"
echo "=========================================="
echo ""
echo "下一步操作:"
echo "  1. 启动所有服务: docker-compose up"
echo "  2. 后台启动: docker-compose up -d"
echo "  3. 查看日志: docker-compose logs -f"
echo "  4. 停止服务: docker-compose down"
echo ""

