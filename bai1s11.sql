-- 1. Xóa thủ tục cũ bị lỗi
DROP PROCEDURE IF EXISTS CancelAppointment;

-- 2. Tạo lại thủ tục mới đã khắc phục logic
DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN
    -- Khai báo biến cục bộ để hứng trạng thái hiện tại
    DECLARE v_current_status VARCHAR(20);
    
    -- Lấy trạng thái của lịch khám hiện tại nạp vào biến
    SELECT status INTO v_current_status 
    FROM Appointments 
    WHERE appointment_id = p_appointment_id;
    
    -- Rẽ nhánh kiểm tra logic
    IF v_current_status = 'Pending' THEN
        -- Đủ điều kiện: Tiến hành hủy
        UPDATE Appointments
        SET status = 'Cancelled'
        WHERE appointment_id = p_appointment_id;
        
        SELECT 'Thành công: Đã hủy lịch khám.' AS Message;
    ELSE
        -- Vi phạm quy tắc: Chặn đứng và báo lỗi
        SELECT 'Thất bại: Chỉ được hủy lịch khám đang ở trạng thái Pending.' AS Message;
    END IF;
    
END //

DELIMITER ;