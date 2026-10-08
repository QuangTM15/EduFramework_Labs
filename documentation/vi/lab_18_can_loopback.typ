#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 18 - CAN Loopback Communication
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "umich-can",
    type: "web",
    author: [J. A. Cook, J. S. Freudenberg],
    title: [Controller Area Network (CAN)],
    source: [University of Michigan, EECS 461 Lecture Notes],
    year: [2008],
    url: "https://eecs.umich.edu/courses/eecs461/doc/CAN_notes.pdf",
  ),
  (
    key: "ti-can",
    type: "application-note",
    author: [Steve Corrigan, Texas Instruments],
    title: [Introduction to the Controller Area Network (CAN)],
    document: [SLOA101B],
    revision: [B],
    year: [2016],
    url: "https://www.ti.com/lit/an/sloa101b/sloa101b.pdf",
  ),
  (
    key: "cia-can",
    type: "web",
    author: [CAN in Automation (CiA)],
    title: [CAN CC (Classical CAN)],
    source: [CiA CAN Knowledge],
    url: "https://www.can-cia.org/can-knowledge/can-cc",
  ),
  (
    key: "kvaser-can",
    type: "web",
    author: [Kvaser],
    title: [The CAN Bus Protocol Tutorial],
    source: [Kvaser Technical Tutorial],
    url: "https://kvaser.com/can-protocol-tutorial/",
  ),
  (
    key: "nxp-cookbook",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Cookbook],
    document: [AN5413],
    revision: [5],
    year: [2020],
    url: "https://www.nxp.com/docs/en/application-note/AN5413.pdf",
  ),
  (
    key: "eduframework-can",
    type: "web",
    author: [EduFramework],
    title: [Arduino-style CAN API (can.h, can.c)],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZ Edu Development Board User Manual],
    revision: [1.0],
    year: [2025],
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 18,
  language: "vi",
  title: [CAN Loopback \
    Communication],
  subtitle: [Truyền nhận CAN nội bộ với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Controller Area Network (CAN) là giao thức truyền thông nối tiếp được phát triển
cho các hệ thống điều khiển phân tán, đặc biệt trong lĩnh vực ô tô. Thay vì mỗi
bộ điều khiển điện tử (Electronic Control Unit - ECU) phải có đường truyền riêng
đến mọi ECU khác, nhiều thiết bị có thể trao đổi thông điệp qua một mạng CAN
chung #cite-ref(refs, "umich-can") #cite-ref(refs, "ti-can").

Bài lab này giới thiệu Classical CAN và cách tạo, truyền, nhận một CAN frame bằng CAN API của EduFramework trên S32K144. Chế độ Internal Loopback
cho phép bộ điều khiển FlexCAN nhận lại chính frame đã truyền, nhờ đó chương
trình được kiểm chứng trên một board mà không cần ECU thứ hai
#cite-ref(refs, "eduframework-can").

Kết quả truyền và nhận được hiển thị trên Serial Monitor. Bài thực hành tập trung
vào các khái niệm CAN ID, định dạng frame, độ dài dữ liệu và payload; giao tiếp
qua CAN bus vật lý giữa hai ECU sẽ được thực hiện ở Lab 19.

== Mục tiêu

#objectives(
  items: (
    [Mô tả vai trò của CAN trong mạng truyền thông giữa các ECU của phương tiện.],
    [Phân biệt CAN ID tiêu chuẩn 11-bit, mở rộng 29-bit và giới hạn dữ liệu của Classical CAN.],
    [Nhận biết các thành phần chính của CAN data frame và nguyên lý ưu tiên thông điệp.],
    [Giải thích nguyên lý Internal Loopback và phạm vi kiểm chứng của chế độ này.],
    [Sử dụng các CAN API của EduFramework để truyền, nhận và đối chiếu dữ liệu trên Serial Monitor.],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== CAN trong hệ thống automotive

Một phương tiện có thể sử dụng nhiều ECU để đảm nhiệm các chức năng như quản lý
động cơ, truyền động, phanh hoặc hiển thị thông tin. Các ECU cần trao đổi trạng
thái và dữ liệu điều khiển mà không làm tăng quá mức số lượng dây kết nối.
CAN được sử dụng như một phương thức truyền thông chung giữa các nút trên mạng
#cite-ref(refs, "umich-can") #cite-ref(refs, "ti-can").

CAN là giao thức hướng thông điệp (message-oriented). Mỗi thông điệp mang một
identifier (CAN ID), không phải địa chỉ đích cố định của một thiết bị. Trên một
CAN bus thông thường, các nút có thể quan sát thông điệp được phát lên bus;
ứng dụng hoặc bộ điều khiển quyết định dữ liệu nào cần xử lý
#cite-ref(refs, "kvaser-can").

Ở lớp vật lý, CAN tốc độ cao sử dụng hai đường tín hiệu vi sai `CAN_H` và `CAN_L`
để truyền dữ liệu giữa các nút thông qua CAN transceiver. CAN controller trong
MCU xử lý giao thức, còn transceiver chuyển đổi tín hiệu giữa bộ điều khiển và
đường bus #cite-ref(refs, "ti-can").

== Classical CAN và cấu trúc data frame

Classical CAN hỗ trợ hai định dạng định danh: Standard CAN sử dụng CAN ID 11-bit
và Extended CAN sử dụng CAN ID 29-bit. Với data frame của Classical CAN, trường
dữ liệu có độ dài từ `0` đến `8 byte` #cite-ref(refs, "cia-can").

#info-table(
  columns: (1.6fr, 1.1fr, 2.4fr),
  alignments: (left + horizon, center + horizon, left + horizon),
  headers: ([Định dạng], [CAN ID], [Đặc điểm]),
  rows: (
    ([Standard], [11-bit], [Miền identifier từ `0x000` đến `0x7FF`.]),
    ([Extended], [29-bit], [Miền identifier từ `0x00000000` đến `0x1FFFFFFF`.]),
  ),
  caption: [Hai định dạng identifier trong Classical CAN],
)

Một CAN data frame bao gồm các trường phục vụ đồng bộ, định danh thông điệp,
mang dữ liệu và phát hiện lỗi. Các trường quan trọng được tóm tắt trong bảng
sau #cite-ref(refs, "cia-can") #cite-ref(refs, "kvaser-can").

#info-table(
  columns: (1.3fr, 3.7fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Trường], [Vai trò]),
  rows: (
    ([SOF], [Đánh dấu bắt đầu một CAN frame.]),
    ([Arbitration], [Chứa identifier và thông tin phục vụ phân xử quyền truy cập bus.]),
    ([Control], [Chứa thông tin điều khiển, bao gồm DLC xác định độ dài trường dữ liệu đối với Classical CAN.]),
    ([Data], [Chứa từ `0` đến `8 byte` payload của data frame.]),
    ([CRC], [Cho phép phát hiện lỗi trong dữ liệu frame đã truyền.]),
    ([ACK], [Cho phép nút nhận trên bus xác nhận việc thu một frame hợp lệ.]),
    ([EOF], [Đánh dấu kết thúc CAN frame.]),
  ),
  caption: [Các trường chính của Classical CAN data frame],
)

Trong EduFramework, ứng dụng chỉ cần cung cấp `id`, `format`, `length` và
`data[]`. Những trường giao thức như SOF, CRC hay ACK được CAN controller xử lý
bên dưới lớp ứng dụng #cite-ref(refs, "eduframework-can").

== CAN ID, phân xử bus và phát hiện lỗi

Khi nhiều nút cùng muốn phát thông điệp, CAN sử dụng cơ chế phân xử không phá
hủy dữ liệu (non-destructive arbitration) dựa trên identifier. Trong trường hợp
cùng loại data frame, identifier có giá trị số nhỏ hơn có mức ưu tiên cao hơn;
nút thua phân xử ngừng phát và chờ bus rảnh để thử lại
#cite-ref(refs, "cia-can") #cite-ref(refs, "kvaser-can").

CAN còn có các cơ chế phát hiện lỗi, bao gồm kiểm tra CRC, kiểm tra bit và kiểm
tra định dạng frame. Trên bus thông thường, trường ACK cho phép bên phát biết
có ít nhất một nút khác tiếp nhận frame hợp lệ, nhưng ACK không đảm bảo ứng dụng
ở ECU đích đã xử lý dữ liệu #cite-ref(refs, "cia-can")
#cite-ref(refs, "kvaser-can").

#note[
  Các cơ chế arbitration, CRC và ACK được giới thiệu để hiểu nền tảng giao thức.
  Bài Loopback không kiểm chứng quá trình phân xử giữa nhiều ECU hoặc khả năng
  hoạt động của lớp vật lý CAN.
]

== Internal Loopback

Ở chế độ Normal, dữ liệu được phát qua giao diện CAN và có thể được nhận bởi
các nút khác trên bus. Internal Loopback tạo đường nhận nội bộ trong CAN
controller: frame được truyền sẽ quay trở lại khối nhận của chính bộ điều khiển,
không cần đi qua đường `CAN_H` và `CAN_L` bên ngoài
#cite-ref(refs, "eduframework-can").

Trong EduFramework, `CAN_setMode(CAN_MODE_LOOPBACK)` kích hoạt chế độ này. Bài
thực hành có thể kiểm tra việc tạo frame, gửi, nhận và đọc hàng đợi dữ liệu
trên một MCU. Kết quả `PASS` chứng minh các trường đã so sánh khớp nhau trong
thử nghiệm nội bộ; kết quả đó không thay thế kiểm thử trên CAN bus thực.

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng một MaaZEDU Development Board có vi điều khiển S32K144 và
FlexCAN0. Chương trình truyền nhận trong chế độ Internal Loopback nên không cần
ECU thứ hai, CAN transceiver rời hay dây nối `CAN_H`/`CAN_L`.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    ([MaaZEDU Development Board], [Board S32K144 dùng để chạy chương trình CAN Loopback.]),
    ([12V DC Adapter], [Nguồn ngoài theo yêu cầu vận hành CAN của MaaZEDU.]),
    ([USB Cable], [Kết nối máy tính để nạp chương trình và sử dụng Serial Monitor.]),
  ),
)

== Giao diện sử dụng

EduFramework sử dụng `FlexCAN0` của S32K144. Trên MaaZEDU, `CAN0_TX` được ánh
xạ tới `PTE5` và `CAN0_RX` tới `PTE4` theo tài liệu board
#cite-ref(refs, "maazedu-guide") #cite-ref(refs, "nxp-cookbook").

#info-table(
  columns: (1.15fr, 1fr, 2.8fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Tín hiệu], [Chân MCU], [Vai trò]),
  rows: (
    ([`CAN0_TX`], [`PTE5`], [Đường truyền từ CAN controller tới transceiver ở chế độ Normal.]),
    ([`CAN0_RX`], [`PTE4`], [Đường nhận từ transceiver về CAN controller ở chế độ Normal.]),
    ([`Serial1`], [`LPUART1`], [Hiển thị dữ liệu và kết quả kiểm chứng trên Serial Monitor.]),
  ),
  caption: [Các giao diện liên quan tới Lab 18],
)

Hai chân CAN được nêu nhằm nhận biết phần cứng; bài Loopback không cần kết nối
chúng bằng dây. Không nối tắt `CAN_H` với `CAN_L`, vì đây là hai đường riêng
của giao tiếp CAN vi sai #cite-ref(refs, "ti-can").

== Cấu hình nguồn và kết nối

Theo MaaZEDU Development Board Guide, chức năng CAN trên board yêu cầu nguồn
ngoài #cite-ref(refs, "maazedu-guide"). Bài lab áp dụng cấu hình đã được kiểm
thử trên MaaZEDU: chuyển jumper chọn nguồn sang chế độ nguồn ngoài, cấp nguồn
bằng adapter `12V` và duy trì kết nối USB để nạp chương trình, sử dụng Serial
Monitor.

#note[
  Tắt nguồn trước khi thay đổi jumper. Cấp nguồn adapter vào đúng đầu nối
  nguồn của board; không cấp `12V` trực tiếp vào chân MCU hoặc chân tín hiệu.
  Internal Loopback không đòi hỏi dây nối CAN ngoài. Yêu cầu nguồn ngoài là
  đặc điểm cấu hình MaaZEDU dùng trong bài thực hành.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework cung cấp Arduino-style CAN API trên lớp FlexCAN driver. Ứng dụng
không cần cấu hình trực tiếp Message Buffer, ngắt nhận hoặc hàng đợi; những
thành phần đó được quản lý ở các tầng bên dưới
#cite-ref(refs, "eduframework-can").

== `CAN_Frame_t`

`CAN_Frame_t` biểu diễn một Classical CAN frame ở mức ứng dụng. Các trường dữ
liệu được sử dụng trong bài lab gồm:

#info-table(
  columns: (1.1fr, 3.9fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Trường], [Ý nghĩa]),
  rows: (
    ([`id`], [CAN identifier của thông điệp.]),
    ([`format`], [Định dạng ID: `CAN_STANDARD` hoặc `CAN_EXTENDED`.]),
    ([`length`], [Số byte payload, từ `0` đến `8`.]),
    ([`data[]`], [Mảng byte chứa payload, tối đa `CAN_MAX_DATA_LENGTH`.]),
  ),
  caption: [Các thành phần của CAN_Frame_t],
)

Bài lab chọn `id = 0x100`, `format = CAN_STANDARD`, `length = 1` và đặt dữ liệu
truyền tại `data[0]`. Identifier `0x100` là giá trị minh họa do bài lab chọn,
không phải mã thông điệp tốc độ xe quy định chung cho mọi hãng.

== `CAN_begin()`

#api-detail(
  name: "CAN_begin",
  syntax: [CAN_begin(bitRate);],
  description: [Khởi tạo bus CAN với tốc độ bit được chỉ định; chế độ ban đầu là Normal.],
  parameters: (
    ([bitRate], [CAN bitrate], [Tốc độ truyền theo bit mỗi giâygiây.]),
  ),
  returns: [`true` nếu khởi tạo thành công; `false` nếu khởi tạo thất bại hoặc bitrate không hợp lệ.],
)

Giá trị `500000UL` tương ứng `500 kbit/s` và được sử dụng trong ví dụ CAN 2.0
của NXP #cite-ref(refs, "nxp-cookbook").

== `CAN_setMode()`

#api-detail(
  name: "CAN_setMode",
  syntax: [CAN_setMode(mode);],
  description: [Chọn chế độ hoạt động của CAN controller sau khi đã khởi tạo.],
  parameters: (
    ([mode], [CAN operating mode], [Bài lab sử dụng `CAN_MODE_LOOPBACK` để nhận lại frame nội bộ.]),
  ),
  returns: [`true` nếu chuyển chế độ thành công; `false` nếu chế độ không hợp lệ hoặc bộ điều khiển chưa sẵn sàng.],
)

`CAN_begin()` và `CAN_setMode()` phải hoàn thành thành công trước khi chương
trình thử truyền dữ liệu #cite-ref(refs, "eduframework-can").

== `CAN_send()`

#api-detail(
  name: "CAN_send",
  syntax: [CAN_send(&txFrame);],
  description: [Truyền một CAN data frame theo cơ chế blocking, chờ hoàn thành hoặc hết thời gian chờ của driver.],
  parameters: (
    ([frame], [CAN Frame], [Địa chỉ của `CAN_Frame_t` chứa thông tin cần truyền.]),
  ),
  returns: [`true` nếu hoàn thành truyền thành công; `false` nếu truyền thất bại hoặc frame không hợp lệ.],
)

Một frame hợp lệ phải có `format` phù hợp với miền ID và `length` không vượt
quá `8 byte` #cite-ref(refs, "eduframework-can").

== `CAN_available()` và `CAN_read()`

#api-detail(
  name: "CAN_available",
  syntax: [CAN_available();],
  description: [Kiểm tra hàng đợi CAN có ít nhất một frame đã nhận hay không.],
  parameters: (),
  returns: [`true` nếu có frame đang chờ đọc; `false` nếu không có dữ liệu hoặc CAN chưa được khởi tạo.],
)

#api-detail(
  name: "CAN_read",
  syntax: [CAN_read(&rxFrame);],
  description: [Đọc và lấy ra frame cũ nhất trong hàng đợi nhận theo cơ chế non-blocking.],
  parameters: (
    ([frame], [CAN Frame], [Địa chỉ biến `CAN_Frame_t` dùng để lưu frame được nhận.]),
  ),
  returns: [`true` nếu đọc thành công một frame; `false` nếu hàng đợi rỗng hoặc tham số không hợp lệ.],
)

Dữ liệu nhận được EduFramework đưa vào hàng đợi thông qua cơ chế ngắt. Ứng dụng
kiểm tra `CAN_available()` trước, sau đó dùng `CAN_read()` để lấy frame và xử lý
trong vòng lặp chính #cite-ref(refs, "eduframework-can").

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình CAN Loopback trên một board S32K144. Khởi tạo CAN ở
`500 kbit/s` và chuyển sang `CAN_MODE_LOOPBACK`. Mỗi giây, chương trình truyền
một Standard CAN frame với ID `0x100`, DLC bằng `1` và byte dữ liệu tăng dần.

Sau khi truyền, chương trình đọc frame nhận lại, hiển thị giá trị `TX`, `RX` và
thông báo `PASS` khi CAN ID, định dạng, DLC và byte payload trùng khớp. Serial
Monitor sử dụng baud rate `9600`.

== Chương trình

Trong `src/main.c`, sử dụng chương trình đã kiểm chứng trên MaaZEDU Development
Board:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình truyền nhận CAN ở chế độ Internal Loopback],
  )[
    ```c
    #include "Arduino.h"
    #include "can.h"
    int main(void)
    {
        CAN_Frame_t txFrame = {0};
        CAN_Frame_t rxFrame = {0};
        uint8_t value = 0U;
        setup();
        Serial1_begin(9600U);
        if ((false == CAN_begin(500000UL)) ||
            (false == CAN_setMode(CAN_MODE_LOOPBACK)))
        {
            Serial1_println("CAN initialization failed.");
            while (1) {}
        }
        Serial1_println("=== CAN Loopback Demo ===");
        txFrame.id = 0x100UL;
        txFrame.format = CAN_STANDARD;
        txFrame.length = 1U;
        while (1)
        {
            txFrame.data[0] = value;
            if (true == CAN_send(&txFrame))
            {
                Serial1_print("TX: ");
                Serial1_printInt(value);
                Serial1_println("");
                if (true == CAN_available())
                {
                    if (true == CAN_read(&rxFrame))
                    {
                        Serial1_print("RX: ");
                        Serial1_printInt(rxFrame.data[0]);
                        Serial1_println("");
                        if ((txFrame.id == rxFrame.id) && (txFrame.format == rxFrame.format) &&
                            (txFrame.length == rxFrame.length) &&
                            (txFrame.data[0] == rxFrame.data[0]))
                        {
                            Serial1_println("Result: PASS");
                        }
                        else
                        {
                            Serial1_println("Result: FAIL");
                        }
                    }
                }
            }
            else
            {
                Serial1_println("CAN transmission failed.");
            }
            Serial1_println("----------------");
            value++;
            delay(1000U);
        }
    }
    ```
  ]
]

`setup()` khởi tạo môi trường EduFramework và `Serial1_begin(9600U)` chuẩn bị
Serial Monitor. Sau khi `CAN_begin(500000UL)` hoàn tất, chương trình gọi
`CAN_setMode(CAN_MODE_LOOPBACK)` để nhận nội bộ các frame đã truyền.

`txFrame` được cấu hình với Standard CAN ID `0x100` và độ dài payload một byte.
Trong vòng lặp, `value` được gán vào `txFrame.data[0]` rồi gửi bằng `CAN_send()`.
Nếu truyền thành công và có frame trong hàng đợi, `CAN_read()` lấy dữ liệu vào
`rxFrame`. Chương trình so sánh bốn trường `id`, `format`, `length` và `data[0]`
để xác định kết quả `PASS` hoặc `FAIL`.

Biến `value` thuộc miền `0..255` và tăng sau mỗi lần lặp. Khi vượt `255`, giá
trị trở về `0` theo cách biểu diễn số nguyên không dấu 8-bit. Lệnh
`delay(1000U)` tạo khoảng nghỉ một giây giữa hai lần thử.

== Kiểm chứng

Sau khi đặt jumper ở chế độ nguồn ngoài và cấp adapter `12V`, nạp chương trình
vào MaaZEDU Development Board. Mở Serial Monitor tại `9600 baud` và quan sát
giá trị TX/RX theo từng chu kỳ.

Kết quả đã kiểm chứng trên phần cứng:

```text
=== CAN Loopback Demo ===
TX: 0
RX: 0
Result: PASS
----------------
TX: 1
RX: 1
Result: PASS
----------------
TX: 2
RX: 2
Result: PASS
----------------
```

Tiếp tục quan sát một số chu kỳ kế tiếp để xác nhận dữ liệu tăng đều và các
trường được so sánh luôn khớp nhau. Trong chương trình này, việc không có frame
sẵn sàng tại đúng thời điểm `CAN_available()` được gọi sẽ khiến chu kỳ đó không
in kết quả `RX` hoặc `PASS`; do đó việc kiểm chứng dựa trên những frame thực tế
đã được đọc và đối chiếu, không chỉ dựa vào thông báo truyền thành công.

#block(breakable: false)[
  #expected-result[
    FlexCAN0 được khởi tạo và chuyển sang Internal Loopback thành công. Với các
    frame đã nhận lại, CAN ID `0x100`, định dạng Standard, DLC bằng `1` và byte
    dữ liệu RX khớp giá trị TX. Serial Monitor hiển thị `Result: PASS` qua các
    chu kỳ liên tiếp mà không cần kết nối CAN bus bên ngoài.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính sử dụng giao tiếp blocking và đọc dữ liệu bằng polling trên
hàng đợi nhận. EduFramework còn có các API và chế độ hoạt động phục vụ ứng dụng
CAN nhiều chức năng hơn #cite-ref(refs, "eduframework-can").

#info-table(
  columns: (1.6fr, 3.1fr),
  alignments: (left + horizon, left + horizon),
  headers: ([API / Chế độ], [Chức năng]),
  rows: (
    ([`CAN_sendNonBlocking()`], [Khởi động truyền CAN mà không chờ thao tác truyền kết thúc.]),
    ([`CAN_isTxBusy()`], [Kiểm tra hiện có một lần truyền non-blocking đang hoạt động hay không.]),
    ([`CAN_isTxComplete()`], [Kiểm tra cờ hoàn tất thành công của lần truyền gần nhất.]),
    ([`CAN_onReceive()`], [Đăng ký callback được gọi từ ngữ cảnh ngắt khi có frame đã được đưa vào hàng đợi nhận.]),
    ([`CAN_MODE_NORMAL`], [Chế độ giao tiếp CAN bình thường qua bus vật lý.]),
    ([`CAN_MODE_LISTEN_ONLY`], [Chế độ theo dõi lưu lượng CAN mà không chủ động phát frame.]),
    ([`CAN_EXTENDED`], [Sử dụng CAN identifier mở rộng 29-bit.]),
    ([`CAN_end()`], [Dừng hoạt động CAN và đặt lại trạng thái của lớp CAN API.]),
  ),
  caption: [Các chức năng CAN mở rộng của EduFramework],
)

== Bài tập mở rộng

Điều chỉnh frame của chương trình để mang hai byte dữ liệu thay vì một byte.
Sau mỗi lần truyền, kiểm tra cả hai byte của payload nhận được trước khi in
`PASS`. Giữ nguyên chế độ Internal Loopback và không cần thiết bị bổ sung.

Các chức năng truyền non-blocking, callback nhận và chế độ Normal sẽ được vận
dụng trong Lab 19 khi hai ECU trao đổi dữ liệu qua CAN bus vật lý.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
