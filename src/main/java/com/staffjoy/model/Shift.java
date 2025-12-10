package com.staffjoy.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 排班实体类
 * 代表员工的排班记录
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
     * 多对一关系：多个排班属于一个用户（员工）
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @NotNull(message = "用户不能为空")
    private User user;

    /**
     * 多对一关系：多个排班属于一个公司
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    @NotNull(message = "公司不能为空")
    private Company company;

    @Column(name = "start_time", nullable = false)
    @NotNull(message = "开始时间不能为空")
    private LocalDateTime startTime; // 排班开始时间

    @Column(name = "stop_time", nullable = false)
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime stopTime; // 排班结束时间

    @Column(name = "published", nullable = false)
    private Boolean published = false; // 是否已发布

    @Column(name = "published_at")
    private LocalDateTime publishedAt; // 发布时间

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 在保存前自动设置创建时间
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (published && publishedAt == null) {
            publishedAt = LocalDateTime.now();
        }
    }

    /**
     * 在更新前自动设置更新时间
     */
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (published && publishedAt == null) {
            publishedAt = LocalDateTime.now();
        }
    }
}

