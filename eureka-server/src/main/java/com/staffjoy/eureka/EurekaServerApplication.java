package com.staffjoy.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * Eureka 服务发现中心
 * 
 * 这是服务注册中心，所有微服务都会注册到这里
 * 其他服务可以通过服务名而不是硬编码的IP和端口来发现和调用服务
 */
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
        System.out.println("========================================");
        System.out.println("Eureka Server 启动成功！");
        System.out.println("访问: http://localhost:8761");
        System.out.println("========================================");
    }
}

