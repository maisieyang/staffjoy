package com.staffjoy.controller;

import com.staffjoy.model.Shift;
import com.staffjoy.service.ShiftService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 排班REST API控制器
 * 
 * RESTful API设计：
 * - GET /api/shifts - 获取所有排班
 * - GET /api/shifts/{id} - 获取指定排班
 * - GET /api/shifts/user/{userId} - 获取指定用户的所有排班
 * - GET /api/shifts/company/{companyId} - 获取指定公司的所有排班
 * - POST /api/shifts - 创建新排班
 * - PUT /api/shifts/{id} - 更新排班
 * - DELETE /api/shifts/{id} - 删除排班
 */
@RestController
@RequestMapping("/api/shifts")
public class ShiftController {

    private final ShiftService shiftService;

    @Autowired
    public ShiftController(ShiftService shiftService) {
        this.shiftService = shiftService;
    }

    /**
     * 获取所有排班
     * GET /api/shifts
     */
    @GetMapping
    public ResponseEntity<List<Shift>> getAllShifts() {
        List<Shift> shifts = shiftService.getAllShifts();
        return ResponseEntity.ok(shifts);
    }

    /**
     * 根据ID获取排班
     * GET /api/shifts/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<Shift> getShiftById(@PathVariable Long id) {
        return shiftService.getShiftById(id)
                .map(shift -> ResponseEntity.ok(shift))
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 根据用户ID获取排班
     * GET /api/shifts/user/{userId}
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Shift>> getShiftsByUserId(@PathVariable Long userId) {
        List<Shift> shifts = shiftService.getShiftsByUserId(userId);
        return ResponseEntity.ok(shifts);
    }

    /**
     * 根据公司ID获取排班
     * GET /api/shifts/company/{companyId}
     */
    @GetMapping("/company/{companyId}")
    public ResponseEntity<List<Shift>> getShiftsByCompanyId(@PathVariable Long companyId) {
        List<Shift> shifts = shiftService.getShiftsByCompanyId(companyId);
        return ResponseEntity.ok(shifts);
    }

    /**
     * 获取指定时间范围内的排班
     * GET /api/shifts/between?startTime=...&stopTime=...
     */
    @GetMapping("/between")
    public ResponseEntity<List<Shift>> getShiftsBetween(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime stopTime) {
        List<Shift> shifts = shiftService.getShiftsBetween(startTime, stopTime);
        return ResponseEntity.ok(shifts);
    }

    /**
     * 创建新排班
     * POST /api/shifts
     */
    @PostMapping
    public ResponseEntity<Shift> createShift(@Valid @RequestBody Shift shift) {
        try {
            Shift createdShift = shiftService.createShift(shift);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdShift);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 更新排班
     * PUT /api/shifts/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<Shift> updateShift(@PathVariable Long id, @Valid @RequestBody Shift shift) {
        try {
            Shift updatedShift = shiftService.updateShift(id, shift);
            return ResponseEntity.ok(updatedShift);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 删除排班
     * DELETE /api/shifts/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShift(@PathVariable Long id) {
        try {
            shiftService.deleteShift(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}

