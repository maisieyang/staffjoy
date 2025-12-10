package com.staffjoy.repository;

import com.staffjoy.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 用户数据访问层
 * 
 * JpaRepository 提供了基本的CRUD操作：
 * - save(): 保存或更新
 * - findById(): 根据ID查找
 * - findAll(): 查找所有
 * - deleteById(): 根据ID删除
 * 
 * 我们还可以定义自定义查询方法
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * 根据用户名查找用户
     * Spring Data JPA 会自动实现这个方法
     */
    Optional<User> findByUsername(String username);

    /**
     * 根据邮箱查找用户
     */
    Optional<User> findByEmail(String email);

    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(String username);

    /**
     * 检查邮箱是否存在
     */
    boolean existsByEmail(String email);
}

