package com.staffjoy.service;

import com.staffjoy.model.Company;
import com.staffjoy.repository.CompanyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * 公司业务逻辑层
 */
@Service
@Transactional
public class CompanyService {

    private final CompanyRepository companyRepository;

    @Autowired
    public CompanyService(CompanyRepository companyRepository) {
        this.companyRepository = companyRepository;
    }

    /**
     * 创建新公司
     */
    public Company createCompany(Company company) {
        // 检查公司名称是否已存在
        if (companyRepository.existsByName(company.getName())) {
            throw new RuntimeException("公司名称已存在: " + company.getName());
        }

        return companyRepository.save(company);
    }

    /**
     * 根据ID获取公司
     */
    @Transactional(readOnly = true)
    public Optional<Company> getCompanyById(Long id) {
        return companyRepository.findById(id);
    }

    /**
     * 根据名称获取公司
     */
    @Transactional(readOnly = true)
    public Optional<Company> getCompanyByName(String name) {
        return companyRepository.findByName(name);
    }

    /**
     * 获取所有公司
     */
    @Transactional(readOnly = true)
    public List<Company> getAllCompanies() {
        return companyRepository.findAll();
    }

    /**
     * 更新公司信息
     */
    public Company updateCompany(Long id, Company companyDetails) {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("公司不存在，ID: " + id));

        // 更新字段
        if (companyDetails.getName() != null && !companyDetails.getName().equals(company.getName())) {
            // 检查新名称是否已被其他公司使用
            if (companyRepository.existsByName(companyDetails.getName())) {
                throw new RuntimeException("公司名称已被使用: " + companyDetails.getName());
            }
            company.setName(companyDetails.getName());
        }
        if (companyDetails.getLegalName() != null) {
            company.setLegalName(companyDetails.getLegalName());
        }
        if (companyDetails.getDescription() != null) {
            company.setDescription(companyDetails.getDescription());
        }
        if (companyDetails.getWebsite() != null) {
            company.setWebsite(companyDetails.getWebsite());
        }
        if (companyDetails.getPhoneNumber() != null) {
            company.setPhoneNumber(companyDetails.getPhoneNumber());
        }
        if (companyDetails.getAddress() != null) {
            company.setAddress(companyDetails.getAddress());
        }

        return companyRepository.save(company);
    }

    /**
     * 删除公司
     */
    public void deleteCompany(Long id) {
        if (!companyRepository.existsById(id)) {
            throw new RuntimeException("公司不存在，ID: " + id);
        }
        companyRepository.deleteById(id);
    }
}

