package com.staffjoy.shift;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 排班服务主应用类
 * 端口: 8082
 */
@SpringBootApplication
public class ShiftServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ShiftServiceApplication.class, args);
    }
}

