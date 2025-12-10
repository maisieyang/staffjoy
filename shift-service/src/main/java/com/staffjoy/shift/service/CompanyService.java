package com.staffjoy.shift.service;

import com.staffjoy.shift.model.Company;
import com.staffjoy.shift.repository.CompanyRepository;
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

    public Company createCompany(Company company) {
        if (companyRepository.existsByName(company.getName())) {
            throw new RuntimeException("公司名称已存在: " + company.getName());
        }
        return companyRepository.save(company);
    }

    @Transactional(readOnly = true)
    public Optional<Company> getCompanyById(Long id) {
        return companyRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<Company> getCompanyByName(String name) {
        return companyRepository.findByName(name);
    }

    @Transactional(readOnly = true)
    public List<Company> getAllCompanies() {
        return companyRepository.findAll();
    }

    public Company updateCompany(Long id, Company companyDetails) {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("公司不存在，ID: " + id));

        if (companyDetails.getName() != null && !companyDetails.getName().equals(company.getName())) {
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

    public void deleteCompany(Long id) {
        if (!companyRepository.existsById(id)) {
            throw new RuntimeException("公司不存在，ID: " + id);
        }
        companyRepository.deleteById(id);
    }
}

