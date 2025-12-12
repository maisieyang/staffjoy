package com.staffjoy.shift;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 排班服务主应用类
 * 端口: 8082
 * 已集成 Eureka Client，会自动注册到 Eureka Server
 * 已启用 Feign Client，可以进行服务间通信
 */
@SpringBootApplication
@EnableEurekaClient
@EnableFeignClients
public class ShiftServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ShiftServiceApplication.class, args);
    }
}

