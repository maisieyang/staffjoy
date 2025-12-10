package com.staffjoy.shift.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 排班实体类
 * 微服务架构中，移除了对 User 的直接 JPA 关联
 * 使用 userId 作为外键引用（跨服务引用）
 */
@Entity
@Table(name = "shifts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Shift {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 用户ID（跨服务引用，不建立 JPA 关联）
     * User 实体在 user-service 中
     */
    @Column(name = "user_id", nullable = false)
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /**
     * 多对一关系：多个排班属于一个公司
     * 在同一服务内，可以保留 JPA 关联
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    @NotNull(message = "公司不能为空")
    private Company company;

    @Column(name = "start_time", nullable = false)
    @NotNull(message = "开始时间不能为空")
    private LocalDateTime startTime;

    @Column(name = "stop_time", nullable = false)
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime stopTime;

    @Column(name = "published", nullable = false)
    private Boolean published = false;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (published && publishedAt == null) {
            publishedAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (published && publishedAt == null) {
            publishedAt = LocalDateTime.now();
        }
    }
}

