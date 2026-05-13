# BÁO CÁO BÀI TẬP [VẬN DỤNG CƠ BẢN 1] - SỰ CỐ HỦY LỊCH KHÁM

**Vai trò:** Database Developer  
**Bối cảnh:** Xử lý lỗ hổng logic trong Stored Procedure `CancelAppointment` khiến lịch khám đã hoàn tất vẫn bị hủy, gây sai lệch dữ liệu tài chính của phòng khám.

---

## PHẦN A: PHÂN TÍCH VẤN ĐỀ

### 1. Câu lệnh tái hiện lỗi hệ thống
Dựa trên dữ liệu mẫu của hệ thống, lịch khám mang mã số `105` (của bệnh nhân Trần Thị Bình) hiện đang ở trạng thái đã hoàn tất (`'Completed'`). Để tái hiện việc hệ thống cho phép hủy sai quy tắc, ta sử dụng lệnh gọi thủ tục sau:
```sql
CALL CancelAppointment(105);
-- Xóa bỏ hoàn toàn thủ tục cũ đang bị lỗi logic
DROP PROCEDURE IF EXISTS CancelAppointment;
DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN
    -- Khai báo biến cục bộ để hứng trạng thái hiện tại của lịch khám
    DECLARE v_current_status VARCHAR(20);
    
    -- Truy vấn trạng thái hiện tại và nạp vào biến
    SELECT status INTO v_current_status 
    FROM Appointments 
    WHERE appointment_id = p_appointment_id;
    
    -- Kiểm tra quy tắc nghiệp vụ: Chỉ cho phép hủy nếu trạng thái là 'Pending'
    IF v_current_status = 'Pending' THEN
        -- Đủ điều kiện: Tiến hành hủy lịch
        UPDATE Appointments
        SET status = 'Cancelled'
        WHERE appointment_id = p_appointment_id;
        
        -- Trả về thông báo thành công
        SELECT 'Thành công: Đã hủy lịch khám.' AS Message;
    ELSE
        -- Vi phạm quy tắc: Chặn giao dịch và báo lỗi
        SELECT 'Thất bại: Chỉ được phép hủy lịch khám đang ở trạng thái Pending.' AS Message;
    END IF;
    
END //

DELIMITER ;
