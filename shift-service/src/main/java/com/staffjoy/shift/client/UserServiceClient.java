package com.staffjoy.shift.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * User Service Feign Client
 * 
 * 用于 shift-service 调用 user-service
 * Feign 会自动从 Eureka 获取 user-service 的地址
 */
@FeignClient(name = "user-service", path = "/api/users")
public interface UserServiceClient {

    /**
     * 根据用户ID获取用户信息
     * 用于验证用户是否存在
     * 
     * @param id 用户ID
     * @return 用户信息（如果存在）
     */
    @GetMapping("/{id}")
    UserResponse getUserById(@PathVariable Long id);

    /**
     * 用户响应DTO（简化版，只包含必要字段）
     */
    class UserResponse {
        private Long id;
        private String username;
        private String email;
        private String name;

        // Getters and Setters
        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}

