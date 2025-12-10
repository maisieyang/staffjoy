package com.staffjoy.shift.repository;

import com.staffjoy.shift.model.Shift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 排班数据访问层
 */
@Repository
public interface ShiftRepository extends JpaRepository<Shift, Long> {

    /**
     * 根据用户ID查找所有排班
     */
    List<Shift> findByUserId(Long userId);

    /**
     * 根据公司ID查找所有排班
     */
    List<Shift> findByCompanyId(Long companyId);

    /**
     * 根据用户ID和公司ID查找排班
     */
    List<Shift> findByUserIdAndCompanyId(Long userId, Long companyId);

    /**
     * 查找指定时间范围内的排班
     */
    @Query("SELECT s FROM Shift s WHERE s.startTime >= :startTime AND s.stopTime <= :stopTime")
    List<Shift> findShiftsBetween(@Param("startTime") LocalDateTime startTime, 
                                   @Param("stopTime") LocalDateTime stopTime);

    /**
     * 查找指定用户在某时间范围内的排班
     */
    @Query("SELECT s FROM Shift s WHERE s.userId = :userId AND s.startTime >= :startTime AND s.stopTime <= :stopTime")
    List<Shift> findUserShiftsBetween(@Param("userId") Long userId,
                                      @Param("startTime") LocalDateTime startTime,
                                      @Param("stopTime") LocalDateTime stopTime);

    /**
     * 查找已发布的排班
     */
    List<Shift> findByPublishedTrue();
}

