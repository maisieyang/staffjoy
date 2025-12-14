#!/bin/bash

# 更新 Kubernetes 部署文件中的镜像地址
# 使用方法: ./update-image-references.sh [版本标签]

set -e

# 配置变量
ACR_REGISTRY="${ACR_REGISTRY:-registry.cn-hangzhou.aliyuncs.com}"
ACR_NAMESPACE="${ACR_NAMESPACE:-staffjoy}"
IMAGE_TAG="${1:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENTS_DIR="${SCRIPT_DIR}/../deployments"

echo "=========================================="
echo "更新 Kubernetes 部署文件镜像地址"
echo "=========================================="
echo "镜像仓库: ${ACR_REGISTRY}"
echo "命名空间: ${ACR_NAMESPACE}"
echo "版本标签: ${IMAGE_TAG}"
echo "=========================================="
echo ""

# 备份原始文件
BACKUP_DIR="${SCRIPT_DIR}/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "${BACKUP_DIR}"
cp -r "${DEPLOYMENTS_DIR}" "${BACKUP_DIR}/"
echo "📦 已备份原始文件到: ${BACKUP_DIR}"
echo ""

# 更新每个部署文件
for deployment_file in "${DEPLOYMENTS_DIR}"/*.yaml; do
    if [ ! -f "$deployment_file" ]; then
        continue
    fi
    
    filename=$(basename "$deployment_file")
    echo "📝 更新: ${filename}"
    
    # 提取服务名（从文件名中）
    service_name=$(echo "$filename" | sed 's/-deployment.yaml//')
    
    # 构建新的镜像地址
    new_image="${ACR_REGISTRY}/${ACR_NAMESPACE}/${service_name}:${IMAGE_TAG}"
    
    # 使用 sed 更新镜像地址（匹配 image: 行）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|image:.*${service_name}.*|image: ${new_image}|g" "$deployment_file"
        sed -i '' "s|imagePullPolicy:.*|imagePullPolicy: Always|g" "$deployment_file"
    else
        # Linux
        sed -i "s|image:.*${service_name}.*|image: ${new_image}|g" "$deployment_file"
        sed -i "s|imagePullPolicy:.*|imagePullPolicy: Always|g" "$deployment_file"
    fi
    
    # 检查是否需要添加 imagePullSecrets
    if ! grep -q "imagePullSecrets:" "$deployment_file"; then
        # 在 spec.template.spec 下添加 imagePullSecrets
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/spec:/a\
      imagePullSecrets:\
      - name: acr-secret
' "$deployment_file"
        else
            sed -i '/spec:/a\      imagePullSecrets:\n      - name: acr-secret' "$deployment_file"
        fi
    fi
    
    echo "   ✅ 已更新镜像: ${new_image}"
done

echo ""
echo "=========================================="
echo "✅ 所有部署文件已更新！"
echo "=========================================="
echo ""
echo "更新后的镜像地址："
for deployment_file in "${DEPLOYMENTS_DIR}"/*.yaml; do
    if [ -f "$deployment_file" ]; then
        service_name=$(basename "$deployment_file" | sed 's/-deployment.yaml//')
        echo "  - ${service_name}: ${ACR_REGISTRY}/${ACR_NAMESPACE}/${service_name}:${IMAGE_TAG}"
    fi
done
echo ""
echo "⚠️  注意: 请确保已创建 ACR Secret:"
echo "   kubectl create secret docker-registry acr-secret \\"
echo "     --docker-server=${ACR_REGISTRY} \\"
echo "     --docker-username=YOUR_USERNAME \\"
echo "     --docker-password=YOUR_PASSWORD \\"
echo "     --namespace=default"
echo ""

