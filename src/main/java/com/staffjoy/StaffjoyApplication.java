package com.staffjoy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Staffjoy 应用主入口
 * 
 * @SpringBootApplication 注解包含了：
 * - @Configuration: 标识这是一个配置类
 * - @EnableAutoConfiguration: 启用Spring Boot的自动配置
 * - @ComponentScan: 自动扫描组件
 */
@SpringBootApplication
public class StaffjoyApplication {

    public static void main(String[] args) {
        SpringApplication.run(StaffjoyApplication.class, args);
        System.out.println("========================================");
        System.out.println("Staffjoy 应用启动成功！");
        System.out.println("访问: http://localhost:8080");
        System.out.println("========================================");
    }
}

