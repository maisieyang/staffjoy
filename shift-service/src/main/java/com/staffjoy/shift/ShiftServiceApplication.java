package com.staffjoy.shift;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 排班服务主应用类
 * 端口: 8082
 * 已集成 Eureka Client，会自动注册到 Eureka Server
 * 已启用 Feign Client，可以进行服务间通信
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.staffjoy.shift.client")
public class ShiftServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ShiftServiceApplication.class, args);
    }
}

