package com.staffjoy.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.config.server.EnableConfigServer;

/**
 * Spring Cloud Config Server
 * 
 * 配置中心，集中管理所有微服务的配置
 * 支持从本地文件系统或 Git 仓库读取配置
 */
@SpringBootApplication
@EnableConfigServer
@EnableDiscoveryClient
public class ConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
        System.out.println("========================================");
        System.out.println("Config Server 启动成功！");
        System.out.println("访问: http://localhost:8888");
        System.out.println("========================================");
    }
}

