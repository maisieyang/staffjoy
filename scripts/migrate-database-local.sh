#!/bin/bash

# 本地数据库迁移脚本（使用 Docker PostgreSQL）
# 使用方法: ./migrate-database-local.sh [service-name]

set -e

SERVICE_NAME=${1:-user-service}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=========================================="
echo "本地数据库迁移脚本（Docker PostgreSQL）"
echo "=========================================="
echo "服务: ${SERVICE_NAME}"
echo "=========================================="
echo ""

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker 未运行"
    exit 1
fi

# 检查 PostgreSQL 容器是否运行
if ! docker ps | grep -q postgres; then
    echo "⚠️  PostgreSQL 容器未运行"
    echo "   正在启动 PostgreSQL 容器..."
    
    docker run -d \
        --name staffjoy-postgres \
        -e POSTGRES_DB=staffjoy \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -p 5432:5432 \
        postgres:15-alpine
    
    echo "   等待 PostgreSQL 启动..."
    sleep 5
fi

echo "✅ PostgreSQL 容器运行中"
echo ""

# 设置环境变量
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=staffjoy
export DB_USERNAME=postgres
export DB_PASSWORD=postgres

# 根据服务设置 schema
if [ "${SERVICE_NAME}" = "user-service" ]; then
    export DB_SCHEMA=user_schema
elif [ "${SERVICE_NAME}" = "shift-service" ]; then
    export DB_SCHEMA=shift_schema
else
    export DB_SCHEMA=public
fi

echo "📝 数据库配置:"
echo "   主机: ${DB_HOST}:${DB_PORT}"
echo "   数据库: ${DB_NAME}"
echo "   Schema: ${DB_SCHEMA}"
echo "   用户: ${DB_USERNAME}"
echo ""

# 初始化数据库（创建 schema 和用户）
echo "🔧 初始化数据库..."
docker exec -i staffjoy-postgres psql -U postgres -d staffjoy <<EOF
-- 创建 Schema
CREATE SCHEMA IF NOT EXISTS ${DB_SCHEMA};

-- 创建用户（如果不存在）
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '${SERVICE_NAME}_user') THEN
        CREATE USER ${SERVICE_NAME}_user WITH PASSWORD 'postgres';
    END IF;
END
\$\$;

-- 授予权限
GRANT USAGE ON SCHEMA ${DB_SCHEMA} TO ${SERVICE_NAME}_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${DB_SCHEMA} TO ${SERVICE_NAME}_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${DB_SCHEMA} TO ${SERVICE_NAME}_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA ${DB_SCHEMA} GRANT ALL ON TABLES TO ${SERVICE_NAME}_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA ${DB_SCHEMA} GRANT ALL ON SEQUENCES TO ${SERVICE_NAME}_user;
EOF

echo "✅ 数据库初始化完成"
echo ""

# 执行迁移
cd "${PROJECT_ROOT}/${SERVICE_NAME}"

echo "🚀 开始执行数据库迁移..."
echo ""

mvn flyway:migrate \
    -Dflyway.url="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?currentSchema=${DB_SCHEMA}" \
    -Dflyway.user="${DB_USERNAME}" \
    -Dflyway.password="${DB_PASSWORD}" \
    -Dflyway.locations="classpath:db/migration" \
    -Dflyway.schemas="${DB_SCHEMA}" \
    -Dflyway.baselineOnMigrate=true \
    -Dflyway.validateOnMigrate=true

echo ""
echo "=========================================="
echo "✅ 数据库迁移完成！"
echo "=========================================="

# 显示迁移信息
echo ""
echo "📊 迁移状态："
mvn flyway:info \
    -Dflyway.url="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?currentSchema=${DB_SCHEMA}" \
    -Dflyway.user="${DB_USERNAME}" \
    -Dflyway.password="${DB_PASSWORD}" \
    -Dflyway.schemas="${DB_SCHEMA}"

echo ""
echo "💡 提示:"
echo "   查看数据库: docker exec -it staffjoy-postgres psql -U postgres -d staffjoy"
echo "   停止容器: docker stop staffjoy-postgres"
echo "   删除容器: docker rm staffjoy-postgres"

