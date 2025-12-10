package com.staffjoy.shift.controller;

import com.staffjoy.shift.model.Company;
import com.staffjoy.shift.model.Shift;
import com.staffjoy.shift.service.ShiftService;
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
 */
@RestController
@RequestMapping("/api/shifts")
public class ShiftController {

    private final ShiftService shiftService;

    @Autowired
    public ShiftController(ShiftService shiftService) {
        this.shiftService = shiftService;
    }

    @GetMapping
    public ResponseEntity<List<Shift>> getAllShifts() {
        List<Shift> shifts = shiftService.getAllShifts();
        return ResponseEntity.ok(shifts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Shift> getShiftById(@PathVariable Long id) {
        return shiftService.getShiftById(id)
                .map(shift -> ResponseEntity.ok(shift))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Shift>> getShiftsByUserId(@PathVariable Long userId) {
        List<Shift> shifts = shiftService.getShiftsByUserId(userId);
        return ResponseEntity.ok(shifts);
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<List<Shift>> getShiftsByCompanyId(@PathVariable Long companyId) {
        List<Shift> shifts = shiftService.getShiftsByCompanyId(companyId);
        return ResponseEntity.ok(shifts);
    }

    @GetMapping("/between")
    public ResponseEntity<List<Shift>> getShiftsBetween(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime stopTime) {
        List<Shift> shifts = shiftService.getShiftsBetween(startTime, stopTime);
        return ResponseEntity.ok(shifts);
    }

    @PostMapping
    public ResponseEntity<Shift> createShift(@Valid @RequestBody Shift shift) {
        try {
            Shift createdShift = shiftService.createShift(shift);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdShift);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Shift> updateShift(@PathVariable Long id, @Valid @RequestBody Shift shift) {
        try {
            Shift updatedShift = shiftService.updateShift(id, shift);
            return ResponseEntity.ok(updatedShift);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

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

