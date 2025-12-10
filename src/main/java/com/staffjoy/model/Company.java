package com.staffjoy.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 公司实体类
 * 代表系统中的公司/组织
 */
@Entity
@Table(name = "companies")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Company {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "公司名称不能为空")
    @Column(nullable = false, unique = true)
    private String name;

    @Column(name = "legal_name")
    private String legalName; // 法定名称

    @Column(columnDefinition = "TEXT")
    private String description; // 公司描述

    @Column(name = "website")
    private String website; // 公司网站

    @Column(name = "phone_number")
    private String phoneNumber; // 联系电话

    @Column(name = "address")
    private String address; // 公司地址

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 一对多关系：一个公司有多个用户（员工）
     * mappedBy 表示关系由 User 实体中的 company 字段维护
     * cascade = CascadeType.ALL 表示级联操作（删除公司时删除所有用户）
     */
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<User> users = new ArrayList<>();

    /**
     * 一对多关系：一个公司有多个排班
     */
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Shift> shifts = new ArrayList<>();

    /**
     * 在保存前自动设置创建时间
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    /**
     * 在更新前自动设置更新时间
     */
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

