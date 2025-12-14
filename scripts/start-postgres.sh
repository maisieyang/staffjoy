#!/bin/bash

# 启动 PostgreSQL 容器脚本

set -e

CONTAINER_NAME="staffjoy-postgres"
PORT=5433

echo "=========================================="
echo "启动 PostgreSQL 容器"
echo "=========================================="
echo ""

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker 未运行"
    echo "   请先启动 Docker Desktop"
    exit 1
fi

echo "✅ Docker 正在运行"
echo ""

# 检查容器是否已存在
if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "📦 容器已存在，检查状态..."
    if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "✅ 容器正在运行"
    else
        echo "🔄 启动容器..."
        docker start ${CONTAINER_NAME}
        sleep 3
    fi
else
    echo "📦 创建新容器..."
    docker run -d \
        --name ${CONTAINER_NAME} \
        -e POSTGRES_DB=staffjoy \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -p ${PORT}:5432 \
        postgres:15-alpine
    
    echo "⏳ 等待 PostgreSQL 启动..."
    sleep 5
fi

# 验证连接
echo ""
echo "🔍 验证数据库连接..."
if docker exec ${CONTAINER_NAME} psql -U postgres -d staffjoy -c "SELECT version();" &> /dev/null; then
    echo "✅ PostgreSQL 连接成功"
else
    echo "⚠️  等待 PostgreSQL 完全启动..."
    sleep 5
    docker exec ${CONTAINER_NAME} psql -U postgres -d staffjoy -c "SELECT version();" &> /dev/null && echo "✅ PostgreSQL 连接成功"
fi

echo ""
echo "=========================================="
echo "✅ PostgreSQL 已就绪"
echo "=========================================="
echo ""
echo "连接信息："
echo "  主机: localhost"
echo "  端口: ${PORT}"
echo "  数据库: staffjoy"
echo "  用户: postgres"
echo "  密码: postgres"
echo ""
echo "连接命令："
echo "  psql -h localhost -p ${PORT} -U postgres -d staffjoy"
echo "  或"
echo "  docker exec -it ${CONTAINER_NAME} psql -U postgres -d staffjoy"
echo ""

