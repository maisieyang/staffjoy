#!/bin/bash

# Staffjoy 微服务启动脚本
# 按正确顺序启动所有服务

echo "=========================================="
echo "Staffjoy 微服务启动脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查端口是否被占用
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}警告: 端口 $1 已被占用${NC}"
        return 1
    else
        return 0
    fi
}

# 启动服务函数
start_service() {
    local service_name=$1
    local port=$2
    local log_file="/tmp/${service_name}.log"
    
    echo -e "${GREEN}启动 $service_name (端口: $port)...${NC}"
    
    if check_port $port; then
        cd $service_name
        nohup mvn spring-boot:run > $log_file 2>&1 &
        echo "  PID: $!"
        echo "  日志: $log_file"
        cd ..
        sleep 3
    else
        echo -e "${YELLOW}跳过 $service_name (端口被占用)${NC}"
    fi
}

# 等待服务启动
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_attempts=30
    local attempt=0
    
    echo -e "${YELLOW}等待 $service_name 启动...${NC}"
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:$port >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name 已启动${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 2
    done
    
    echo -e "${YELLOW}⚠ $service_name 启动超时，请检查日志${NC}"
    return 1
}

echo "步骤 1/5: 启动 Eureka Server (服务发现中心)"
start_service "eureka-server" 8761
wait_for_service "Eureka Server" 8761

echo ""
echo "步骤 2/5: 启动 Config Server (配置中心)"
start_service "config-server" 8888
wait_for_service "Config Server" 8888

echo ""
echo "步骤 3/5: 启动 User Service"
start_service "user-service" 8081
wait_for_service "User Service" 8081

echo ""
echo "步骤 4/5: 启动 Shift Service"
start_service "shift-service" 8082
wait_for_service "Shift Service" 8082

echo ""
echo "步骤 5/5: 启动 API Gateway"
start_service "api-gateway" 8080
wait_for_service "API Gateway" 8080

echo ""
echo "=========================================="
echo "所有服务启动完成！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  🌐 Eureka Server:    http://localhost:8761"
echo "  ⚙️  Config Server:    http://localhost:8888"
echo "  🚪 API Gateway:      http://localhost:8080"
echo "  👤 User Service:     http://localhost:8081"
echo "  📅 Shift Service:    http://localhost:8082"
echo ""
echo "查看日志："
echo "  tail -f /tmp/eureka-server.log"
echo "  tail -f /tmp/config-server.log"
echo "  tail -f /tmp/user-service.log"
echo "  tail -f /tmp/shift-service.log"
echo "  tail -f /tmp/api-gateway.log"
echo ""
echo "停止所有服务："
echo "  pkill -f 'spring-boot:run'"
echo ""

