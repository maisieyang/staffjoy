package com.staffjoy.shift.service;

import com.staffjoy.shift.model.Company;
import com.staffjoy.shift.model.Shift;
import com.staffjoy.shift.repository.CompanyRepository;
import com.staffjoy.shift.repository.ShiftRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 排班业务逻辑层
 * 注意：在微服务架构中，不能直接验证 User 是否存在
 * 需要通过服务间通信（如 Feign）来验证，这里先简化处理
 */
@Service
@Transactional
public class ShiftService {

    private final ShiftRepository shiftRepository;
    private final CompanyRepository companyRepository;

    @Autowired
    public ShiftService(ShiftRepository shiftRepository,
                       CompanyRepository companyRepository) {
        this.shiftRepository = shiftRepository;
        this.companyRepository = companyRepository;
    }

    /**
     * 创建新排班
     */
    public Shift createShift(Shift shift) {
        // 验证公司是否存在
        Company company = companyRepository.findById(shift.getCompany().getId())
                .orElseThrow(() -> new RuntimeException("公司不存在，ID: " + shift.getCompany().getId()));

        // 验证时间逻辑
        if (shift.getStartTime().isAfter(shift.getStopTime()) || 
            shift.getStartTime().isEqual(shift.getStopTime())) {
            throw new RuntimeException("开始时间必须早于结束时间");
        }

        // 设置关联关系
        shift.setCompany(company);
        // userId 已经通过请求体设置，不需要验证（在微服务中，可以通过服务间通信验证）

        return shiftRepository.save(shift);
    }

    @Transactional(readOnly = true)
    public Optional<Shift> getShiftById(Long id) {
        return shiftRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public List<Shift> getAllShifts() {
        return shiftRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Shift> getShiftsByUserId(Long userId) {
        return shiftRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<Shift> getShiftsByCompanyId(Long companyId) {
        return shiftRepository.findByCompanyId(companyId);
    }

    @Transactional(readOnly = true)
    public List<Shift> getShiftsBetween(LocalDateTime startTime, LocalDateTime stopTime) {
        return shiftRepository.findShiftsBetween(startTime, stopTime);
    }

    public Shift updateShift(Long id, Shift shiftDetails) {
        Shift shift = shiftRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("排班不存在，ID: " + id));

        // 更新用户ID（如果提供）
        if (shiftDetails.getUserId() != null) {
            shift.setUserId(shiftDetails.getUserId());
        }

        // 更新公司（如果提供）
        if (shiftDetails.getCompany() != null && shiftDetails.getCompany().getId() != null) {
            Company company = companyRepository.findById(shiftDetails.getCompany().getId())
                    .orElseThrow(() -> new RuntimeException("公司不存在，ID: " + shiftDetails.getCompany().getId()));
            shift.setCompany(company);
        }

        // 更新时间
        if (shiftDetails.getStartTime() != null) {
            shift.setStartTime(shiftDetails.getStartTime());
        }
        if (shiftDetails.getStopTime() != null) {
            shift.setStopTime(shiftDetails.getStopTime());
        }

        // 验证时间逻辑
        if (shift.getStartTime().isAfter(shift.getStopTime()) || 
            shift.getStartTime().isEqual(shift.getStopTime())) {
            throw new RuntimeException("开始时间必须早于结束时间");
        }

        // 更新发布状态
        if (shiftDetails.getPublished() != null) {
            shift.setPublished(shiftDetails.getPublished());
        }

        return shiftRepository.save(shift);
    }

    public void deleteShift(Long id) {
        if (!shiftRepository.existsById(id)) {
            throw new RuntimeException("排班不存在，ID: " + id);
        }
        shiftRepository.deleteById(id);
    }
}

