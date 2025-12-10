package com.staffjoy.repository;

import com.staffjoy.model.Company;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 公司数据访问层
 */
@Repository
public interface CompanyRepository extends JpaRepository<Company, Long> {

    /**
     * 根据公司名称查找公司
     */
    Optional<Company> findByName(String name);

    /**
     * 检查公司名称是否存在
     */
    boolean existsByName(String name);
}

