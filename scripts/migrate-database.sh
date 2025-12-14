#!/bin/bash

# 数据库迁移脚本
# 使用方法: ./migrate-database.sh [service-name] [environment]
# 示例: ./migrate-database.sh user-service prod

set -e

SERVICE_NAME=${1:-user-service}
ENVIRONMENT=${2:-prod}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=========================================="
echo "数据库迁移脚本"
echo "=========================================="
echo "服务: ${SERVICE_NAME}"
echo "环境: ${ENVIRONMENT}"
echo "=========================================="
echo ""

# 检查服务是否存在
if [ ! -d "${PROJECT_ROOT}/${SERVICE_NAME}" ]; then
    echo "❌ 错误: 服务 ${SERVICE_NAME} 不存在"
    exit 1
fi

# 检查迁移脚本目录
MIGRATION_DIR="${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources/db/migration"
if [ ! -d "${MIGRATION_DIR}" ]; then
    echo "❌ 错误: 迁移脚本目录不存在: ${MIGRATION_DIR}"
    exit 1
fi

echo "📁 迁移脚本目录: ${MIGRATION_DIR}"
echo ""

# 列出迁移脚本
echo "📋 迁移脚本列表:"
ls -1 "${MIGRATION_DIR}"/*.sql 2>/dev/null | xargs -n1 basename || {
    echo "⚠️  未找到迁移脚本"
    exit 1
}
echo ""

# 检查 Maven 是否可用
if ! command -v mvn &> /dev/null; then
    echo "❌ 错误: Maven 未安装或不在 PATH 中"
    exit 1
fi

echo "✅ Maven 可用"
echo ""

# 设置环境变量（从配置文件读取或使用默认值）
if [ "${ENVIRONMENT}" = "prod" ]; then
    echo "📝 使用生产环境配置"
    echo "   请确保已设置以下环境变量："
    echo "   - DB_HOST"
    echo "   - DB_PORT"
    echo "   - DB_NAME"
    echo "   - DB_SCHEMA"
    echo "   - DB_USERNAME"
    echo "   - DB_PASSWORD"
    echo ""
    
    # 检查环境变量
    if [ -z "${DB_HOST}" ] || [ -z "${DB_NAME}" ] || [ -z "${DB_USERNAME}" ]; then
        echo "⚠️  警告: 数据库环境变量未设置"
        echo "   请设置环境变量或使用 application-prod.yml 中的配置"
        echo ""
        read -p "是否继续？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# 切换到服务目录
cd "${PROJECT_ROOT}/${SERVICE_NAME}"

echo "🚀 开始执行数据库迁移..."
echo ""

# 使用 Maven Flyway 插件执行迁移
mvn flyway:migrate \
    -Dflyway.url="jdbc:postgresql://${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-staffjoy}?currentSchema=${DB_SCHEMA:-public}" \
    -Dflyway.user="${DB_USERNAME:-postgres}" \
    -Dflyway.password="${DB_PASSWORD:-postgres}" \
    -Dflyway.locations="classpath:db/migration" \
    -Dflyway.schemas="${DB_SCHEMA:-public}" \
    -Dflyway.baselineOnMigrate=true \
    -Dflyway.validateOnMigrate=true

echo ""
echo "=========================================="
echo "✅ 数据库迁移完成！"
echo "=========================================="

# 显示迁移信息
echo ""
echo "📊 查看迁移状态："
mvn flyway:info \
    -Dflyway.url="jdbc:postgresql://${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-staffjoy}?currentSchema=${DB_SCHEMA:-public}" \
    -Dflyway.user="${DB_USERNAME:-postgres}" \
    -Dflyway.password="${DB_PASSWORD:-postgres}" \
    -Dflyway.schemas="${DB_SCHEMA:-public}"

