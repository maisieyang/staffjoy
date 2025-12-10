package com.staffjoy.service;

import com.staffjoy.model.Company;
import com.staffjoy.model.Shift;
import com.staffjoy.model.User;
import com.staffjoy.repository.CompanyRepository;
import com.staffjoy.repository.ShiftRepository;
import com.staffjoy.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 排班业务逻辑层
 */
@Service
@Transactional
public class ShiftService {

    private final ShiftRepository shiftRepository;
    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;

    @Autowired
    public ShiftService(ShiftRepository shiftRepository,
                       UserRepository userRepository,
                       CompanyRepository companyRepository) {
        this.shiftRepository = shiftRepository;
        this.userRepository = userRepository;
        this.companyRepository = companyRepository;
    }

    /**
     * 创建新排班
     */
    public Shift createShift(Shift shift) {
        // 验证用户是否存在
        User user = userRepository.findById(shift.getUser().getId())
                .orElseThrow(() -> new RuntimeException("用户不存在，ID: " + shift.getUser().getId()));

        // 验证公司是否存在
        Company company = companyRepository.findById(shift.getCompany().getId())
                .orElseThrow(() -> new RuntimeException("公司不存在，ID: " + shift.getCompany().getId()));

        // 验证时间逻辑
        if (shift.getStartTime().isAfter(shift.getStopTime()) || 
            shift.getStartTime().isEqual(shift.getStopTime())) {
            throw new RuntimeException("开始时间必须早于结束时间");
        }

        // 设置关联关系
        shift.setUser(user);
        shift.setCompany(company);

        return shiftRepository.save(shift);
    }

    /**
     * 根据ID获取排班
     */
    @Transactional(readOnly = true)
    public Optional<Shift> getShiftById(Long id) {
        return shiftRepository.findById(id);
    }

    /**
     * 获取所有排班
     */
    @Transactional(readOnly = true)
    public List<Shift> getAllShifts() {
        return shiftRepository.findAll();
    }

    /**
     * 根据用户ID获取排班
     */
    @Transactional(readOnly = true)
    public List<Shift> getShiftsByUserId(Long userId) {
        return shiftRepository.findByUserId(userId);
    }

    /**
     * 根据公司ID获取排班
     */
    @Transactional(readOnly = true)
    public List<Shift> getShiftsByCompanyId(Long companyId) {
        return shiftRepository.findByCompanyId(companyId);
    }

    /**
     * 获取指定时间范围内的排班
     */
    @Transactional(readOnly = true)
    public List<Shift> getShiftsBetween(LocalDateTime startTime, LocalDateTime stopTime) {
        return shiftRepository.findShiftsBetween(startTime, stopTime);
    }

    /**
     * 更新排班信息
     */
    public Shift updateShift(Long id, Shift shiftDetails) {
        Shift shift = shiftRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("排班不存在，ID: " + id));

        // 更新用户（如果提供）
        if (shiftDetails.getUser() != null && shiftDetails.getUser().getId() != null) {
            User user = userRepository.findById(shiftDetails.getUser().getId())
                    .orElseThrow(() -> new RuntimeException("用户不存在，ID: " + shiftDetails.getUser().getId()));
            shift.setUser(user);
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

    /**
     * 删除排班
     */
    public void deleteShift(Long id) {
        if (!shiftRepository.existsById(id)) {
            throw new RuntimeException("排班不存在，ID: " + id);
        }
        shiftRepository.deleteById(id);
    }
}

