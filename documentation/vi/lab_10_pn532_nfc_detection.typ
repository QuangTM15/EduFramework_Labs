#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 10 - Nhận diện thẻ NFC với PN532
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "coskun-nfc-survey",
    type: "web",
    author: [Vedat Coskun, Busra Ozdenizci and Kerem Ok],
    title: [The Survey on Near Field Communication],
    source: [Sensors, 15(6), 13348–13405],
    year: [2015],
    url: "https://doi.org/10.3390/s150613348",
  ),
  (
    key: "mohandes-attendance",
    type: "web",
    author: [Mohamed A. Mohandes],
    title: [Class Attendance Management System Using NFC Mobile Devices],
    source: [Intelligent Automation and Soft Computing, 23(2), 251–259],
    year: [2017],
    url: "https://doi.org/10.1080/10798587.2016.1204749",
  ),
  (
    key: "nxp-pn532-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [PN532/C1 - Near Field Communication (NFC) Controller],
    document: [PN532_C1],
    revision: [3.6],
    year: [2017],
    url: "https://www.nxp.com/docs/en/nxp/data-sheets/PN532_C1.pdf",
  ),
  (
    key: "nxp-pn532-user-manual",
    type: "manual",
    author: [NXP Semiconductors],
    title: [PN532 User Manual],
    document: [UM0701-02],
    revision: [02],
    year: [2007],
    url: "https://www.nxp.com/docs/en/user-guide/141520.pdf",
  ),
  (
    key: "nxp-uid",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [MIFARE Product and Handling of UIDs],
    document: [AN10927],
    revision: [4.1],
    year: [2018],
    url: "https://www.nxp.com/docs/en/application-note/AN10927.pdf",
  ),
  (
    key: "elechouse-pn532-v3",
    type: "manual",
    author: [Elechouse],
    title: [PN532 NFC RFID Module User Guide],
    revision: [Version 3],
    url: "https://easyelecmodule.com/wp-content/uploads/PN532_-Manual_V3.pdf",
  ),
  (
    key: "eduframework-pn532",
    type: "web",
    author: [EduFramework],
    title: [PN532 Device API and UART/HSU Driver],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZEDU Development Board Guide],
    revision: [1.0],
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 10,
  language: "vi",
  title: [Nhận diện thẻ NFC với PN532],
  subtitle: [Đọc UID của thẻ qua UART (HSU) bằng EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Nhận dạng không tiếp xúc cho phép thiết bị trao đổi thông tin với thẻ hoặc
đối tượng mang thẻ mà không cần tiếp điểm điện. Near Field Communication
(NFC) là công nghệ truyền thông vô tuyến tầm ngắn, có quan hệ chặt chẽ với
các hệ thống RFID hoạt động ở tần số `13.56 MHz`. Bài tổng quan của Coskun,
Ozdenizci và Ok trình bày nền tảng công nghệ NFC cùng những ứng dụng như
thẻ điện tử, vé điện tử và tương tác giữa thiết bị
#cite-ref(refs, "coskun-nfc-survey").

Trong một hệ thống đọc thẻ, thiết bị đọc (reader) giao tiếp không tiếp xúc
với thẻ, sau đó chuyển dữ liệu nhận được tới bộ điều khiển của ứng dụng.
Chẳng hạn, Mohandes đã nghiên cứu một mô hình điểm danh sử dụng thiết bị NFC
và thẻ trong môi trường đại học. Đây là ví dụ ứng dụng nhận dạng thẻ, nhưng
không phải một nghiên cứu riêng về module PN532
#cite-ref(refs, "mohandes-attendance").

Bài lab này sử dụng module *PN532 NFC RFID Module V3* và MaaZEDU Development
Board. PN532 giao tiếp với vi điều khiển S32K144 qua giao diện UART/HSU;
EduFramework cung cấp Device API để chương trình khởi tạo module, phát hiện
thẻ ISO/IEC 14443 Type A và hiển thị UID trên Serial Monitor. Những thao tác
chi tiết ở cấp khung truyền, lựa chọn target và đọc/ghi bộ nhớ thẻ không
thuộc yêu cầu chính #cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

== Mục tiêu

#objectives(
  items: (
    [
      Mô tả vai trò của thiết bị đọc NFC, thẻ/tag và mã nhận dạng UID trong
      một hệ thống giao tiếp không tiếp xúc cơ bản.
    ],
    [
      Nhận biết giao tiếp UART/HSU của PN532 và giải thích cách nối chéo
      tín hiệu `TX` và `RX` giữa module với MaaZEDU.
    ],
    [
      Phân biệt việc đọc UID với việc đọc dữ liệu lưu trong thẻ và nhận biết
      giới hạn của UID trong một ứng dụng xác thực.
    ],
    [
      Sử dụng `PN532_Begin()`, `PN532_IsCardPresent()`, `PN532_GetUID()` và
      `PN532_End()` để nhận diện thẻ bằng EduFramework.
    ],
    [
      Xây dựng, kiểm chứng chương trình hiển thị UID dạng hexadecimal trên
      Serial Monitor và thử nghiệm với các thẻ/tag tương thích.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== NFC và hệ thống nhận dạng không tiếp xúc

NFC hoạt động dựa trên tương tác điện từ ở khoảng cách ngắn. Trong bài tổng
quan *The Survey on Near Field Communication*, Coskun và cộng sự mô tả NFC
là công nghệ truyền thông tầm ngắn dựa trên ghép cảm ứng và có nhiều chế độ
hoạt động. RFID và NFC có các công nghệ, ứng dụng liên quan, nhưng không nên
đồng nhất mọi thẻ RFID với một thiết bị NFC có đầy đủ các khả năng giao tiếp
#cite-ref(refs, "coskun-nfc-survey").

PN532 là IC điều khiển giao tiếp không tiếp xúc ở `13.56 MHz`. Datasheet
PN532/C1 mô tả khả năng hỗ trợ nhiều giao thức và chế độ, bao gồm giao tiếp
với thẻ ISO/IEC 14443 Type A/MIFARE. Tuy nhiên, Lab 10 chỉ khai thác một
trường hợp cụ thể: *reader phát hiện một thẻ Type A và lấy UID*
#cite-ref(refs, "nxp-pn532-datasheet").

#info-table(
  columns: (1.4fr, 3.1fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Thành phần], [Vai trò trong bài thực hành]),
  rows: (
    ([MaaZEDU / S32K144], [Điều khiển ứng dụng, nhận kết quả qua UART và xuất thông tin trên Serial Monitor.]),
    ([PN532 module], [Thực hiện giao tiếp vô tuyến với thẻ và trao đổi lệnh/kết quả với MCU.]),
    ([NFC card/tag], [Đối tượng được phát hiện và cung cấp thông tin nhận dạng.]),
    ([Serial Monitor], [Hiển thị UID do chương trình nhận được từ PN532.]),
  ),
  caption: [Các thành phần của hệ thống nhận diện thẻ trong Lab 10],
)

Với bài lab này, đường truyền UART là giao tiếp *giữa vi điều khiển và module*,
còn giao tiếp vô tuyến ở `13.56 MHz` diễn ra *giữa PN532 và thẻ*. Hai đường
truyền có nhiệm vụ khác nhau và không sử dụng cùng một tốc độ dữ liệu
#cite-ref(refs, "nxp-pn532-datasheet")
#cite-ref(refs, "nxp-pn532-user-manual").

== PN532 và mã nhận dạng UID

Trong quá trình phát hiện thẻ ISO/IEC 14443 Type A, PN532 có thể thực hiện
các bước cần thiết để nhận biết và lựa chọn thẻ. Khi lệnh
`InListPassiveTarget` thành công, thông tin trả về có thể bao gồm `ATQA`,
`SAK`, độ dài UID và các byte UID. Đây là những trường thông tin được mô tả
trong *PN532 User Manual* của NXP
#cite-ref(refs, "nxp-pn532-user-manual").

UID (*Unique Identifier*) được biểu diễn bằng một dãy byte. Theo tài liệu
NXP AN10927, các độ dài UID theo ISO/IEC 14443 Type A có thể là `4`, `7`
hoặc `10 byte`. Tài liệu này cũng chỉ rõ không phải mọi UID đều được bảo
đảm duy nhất trong mọi tình huống; một số sản phẩm sử dụng Random ID hoặc
Non-Unique ID #cite-ref(refs, "nxp-uid").

#info-table(
  columns: (1.2fr, 1.7fr, 2.1fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Độ dài UID], [Tên gọi], [Ghi chú]),
  rows: (
    ([`4 byte`], [Single Size UID], [Được lựa chọn qua một cascade level.]),
    ([`7 byte`], [Double Size UID], [Được lựa chọn qua hai cascade level.]),
    ([`10 byte`], [Triple Size UID], [Được lựa chọn qua ba cascade level.]),
  ),
  caption: [Các độ dài UID trong ISO/IEC 14443 Type A theo AN10927],
)

Ví dụ, UID thu được trong thử nghiệm phần cứng của bài lab có dạng:

```text
EE 68 17 05
```

Đây là cách biểu diễn *hexadecimal*: mỗi cặp ký tự tương ứng với một byte.
Dữ liệu UID được in để quan sát và so sánh giữa các lần quét; chương trình
chính không truy cập bộ nhớ người dùng, khóa xác thực hay dữ liệu ứng dụng
bên trong thẻ #cite-ref(refs, "eduframework-pn532").

#warning[
  UID có thể phù hợp để minh họa việc phân biệt thẻ trong một bài thực hành,
  nhưng *không được xem UID đơn lẻ là bằng chứng xác thực an toàn*. NXP nêu
  rõ các trường hợp Random ID và Non-Unique ID trong hệ thống thẻ không tiếp
  xúc. Phần mở rộng so sánh UID vì vậy chỉ là mô hình xử lý dữ liệu, không
  phải giải pháp kiểm soát truy cập có bảo mật
  #cite-ref(refs, "nxp-uid").
]

== Giao tiếp UART/HSU giữa PN532 và S32K144

PN532 hỗ trợ các giao diện host gồm SPI, I2C và High Speed UART (`HSU`).
Với UART, một thiết bị truyền dữ liệu trên đường `TX` và nhận dữ liệu trên
đường `RX`; vì vậy `TX` của thiết bị này phải nối với `RX` của thiết bị kia.
Hai thiết bị cũng cần nối chung `GND` để có cùng mốc điện áp
#cite-ref(refs, "nxp-pn532-datasheet")
#cite-ref(refs, "elechouse-pn532-v3").

Trong EduFramework, driver PN532 sử dụng `Serial2` với baud rate cố định
`115200`. Kênh `Serial1` được giữ cho việc ghi log lên Serial Monitor ở
`9600` baud, tương tự Lab 03. Ứng dụng không trực tiếp điều khiển thanh ghi
LPUART của S32K144 vì các thao tác UART đã được đóng gói ở các tầng driver
#cite-ref(refs, "eduframework-pn532").

#info-table(
  columns: (1.25fr, 1.4fr, 2.35fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Kênh], [Baud rate], [Mục đích]),
  rows: (
    ([`Serial1`], [`9600`], [Xuất thông báo và UID lên Serial Monitor.]),
    ([`Serial2`], [`115200`], [Giao tiếp UART/HSU hai chiều với module PN532.]),
  ),
  caption: [Hai kênh Serial được sử dụng trong bài thực hành],
)

#note[
  `115200 baud` là tốc độ UART giữa MaaZEDU và PN532 theo cấu hình driver.
  Nó không phải tần số sóng mang NFC `13.56 MHz` và cũng không phải tốc độ
  truyền vô tuyến khi reader làm việc với thẻ
  #cite-ref(refs, "nxp-pn532-datasheet")
  #cite-ref(refs, "eduframework-pn532").
]

== Từ phát hiện thẻ đến hiển thị UID

Theo *PN532 User Manual*, lệnh `InListPassiveTarget` cho phép PN532 thực hiện
quá trình phát hiện và khởi tạo target ở chế độ thụ động. Với tham số Type A
`106 kbps`, chip thực hiện các bước cần thiết để phát hiện thẻ phù hợp và
trả dữ liệu nhận dạng cho host #cite-ref(refs, "nxp-pn532-user-manual").

Driver PN532 của EduFramework bao bọc chuỗi trao đổi này bằng Easy API.
`PN532_Begin()` khởi tạo UART và module, `PN532_IsCardPresent()` thực hiện
việc quét thẻ, còn `PN532_GetUID()` truy xuất chuỗi UID đã được lưu sau lần
quét thành công. `PN532_End()` giải phóng target đang được chọn để chuẩn bị
cho lượt xử lý tiếp theo #cite-ref(refs, "eduframework-pn532").

Luồng xử lý của bài thực hành có thể tóm tắt như sau:

`NFC card/tag` ⇄ `PN532 (RF 13.56 MHz)` ⇄ `UART2 (HSU)` ⇄ `S32K144` →
`Serial1` → `Serial Monitor`.

Các thao tác như đóng gói frame, kiểm tra checksum, chờ ACK, xử lý timeout
và phân tích phản hồi được thực hiện trong driver. Vì vậy, chương trình chính
không phải xử lý mảng byte của giao thức PN532
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng MaaZEDU Development Board, module PN532 NFC RFID V3 màu đỏ,
ít nhất một thẻ hoặc tag ISO/IEC 14443 Type A tương thích, dây kết nối và
cáp USB. Chỉ dùng giao tiếp UART/HSU trong bài chính; các đường SPI và I2C
không được nối tới module #cite-ref(refs, "elechouse-pn532-v3")
#cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board sử dụng vi điều khiển S32K144 và cung cấp giao tiếp UART ngoài.],
    ),
    (
      [PN532 NFC RFID Module V3],
      [Module đọc thẻ sử dụng chip PN532, tích hợp anten trên PCB và lựa chọn giao tiếp HSU.],
    ),
    (
      [NFC card/tag],
      [Thẻ hoặc móc khóa tương thích được sử dụng để kiểm chứng chức năng đọc UID.],
    ),
    (
      [Jumper wires],
      [Bốn dây kết nối nguồn, GND, UART TX và UART RX.],
    ),
    (
      [USB Cable],
      [Kết nối MaaZEDU với máy tính để nạp chương trình và sử dụng Serial Monitor.],
    ),
  ),
)

== Ánh xạ chân UART và kết nối PN532

Trong cấu hình EduFramework của bài thực hành, `Serial2` sử dụng hai tín hiệu
`UART2_TX` và `UART2_RX` của S32K144. Chân truyền của MaaZEDU nối với chân
nhận của PN532, và ngược lại. `Serial1` dùng cho Serial Monitor nên không
được sử dụng làm đường truyền tới module PN532
#cite-ref(refs, "eduframework-pn532")
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Ánh xạ hai tín hiệu UART2 sử dụng trong Lab 10],
  rows: (
    ([PN532 `RXD`], "UART2_TX", "PTD7", [Dữ liệu từ MaaZEDU đến module PN532.]),
    ([PN532 `TXD`], "UART2_RX", "PTD6", [Dữ liệu từ module PN532 đến MaaZEDU.]),
  ),
)

#info-table(
  columns: (1.4fr, 1.55fr, 2.05fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Chân module PN532], [MaaZEDU], [Chức năng]),
  rows: (
    ([`VCC`], [`3.3V`], [Cấp nguồn cho module.]),
    ([`GND`], [`GND`], [Thiết lập mốc điện áp chung.]),
    ([`RXD` / `RX`], [`UART2_TX`], [Module nhận lệnh từ S32K144.]),
    ([`TXD` / `TX`], [`UART2_RX`], [Module gửi phản hồi tới S32K144.]),
  ),
  caption: [Kết nối module PN532 ở chế độ UART/HSU],
)

#figure-block(
  caption: [Sơ đồ kết nối module PN532 UART/HSU với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/pn532_nfc_detection_circuit.png",
    width: 88%,
  )
]

== Lựa chọn chế độ HSU trên module

Module PN532 V3 có hai công tắc chọn giao tiếp. Theo *Elechouse PN532 NFC RFID
Module User Guide*, cấu hình `HSU` tương ứng với cả hai công tắc ở trạng thái
`OFF`; các cấu hình khác dành cho I2C hoặc SPI. Ở phiên bản module này, các
chân HSU dùng chung vị trí vật lý với chân I2C nhưng ký hiệu chức năng UART
được in ở mặt sau PCB #cite-ref(refs, "elechouse-pn532-v3").

#info-table(
  columns: (1.4fr, 1.3fr, 1.3fr),
  alignments: (center + horizon, center + horizon, center + horizon),
  headers: ([Chế độ], [Channel 1], [Channel 2]),
  rows: (
    ([`HSU / UART`], [`OFF`], [`OFF`]),
    ([`I2C`], [`ON`], [`OFF`]),
    ([`SPI`], [`OFF`], [`ON`]),
  ),
  caption: [Cấu hình công tắc chọn giao tiếp của PN532 Module V3],
)

#warning[
  Ngắt nguồn trước khi thay đổi dây hoặc công tắc. Đối chiếu nhãn `TXD` và
  `RXD` ở *mặt sau* module V3; không xem `SDA` và `SCL` được in ở mặt trước là
  tên của hai tín hiệu UART. Cấp nguồn `3.3 V` như cấu hình đã kiểm thử trên
  MaaZEDU. Khi thay module khác, phải kiểm tra hướng dẫn phần cứng tương ứng
  #cite-ref(refs, "elechouse-pn532-v3").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework cung cấp các hàm đơn giản để đọc thông tin thẻ mà không yêu cầu
ứng dụng tạo cấu trúc dữ liệu `PN532_Card_t` hoặc tự phân tích khung truyền.
Bốn hàm của *Easy API* cần dùng trong bài chính gồm `PN532_Begin()`,
`PN532_IsCardPresent()`, `PN532_GetUID()` và `PN532_End()`
#cite-ref(refs, "eduframework-pn532").

== `PN532_Begin()`

`PN532_Begin()` khởi tạo giao tiếp `Serial2` ở `115200 baud`, đánh thức module
qua HSU, kiểm tra phiên bản firmware của chip và thực hiện cấu hình cần thiết
cho chế độ đọc thẻ. Hàm không nhận tham số; ứng dụng chỉ cần kiểm tra kết quả
khởi tạo #cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_Begin",
  syntax: [PN532_Begin();],
  description: [Khởi tạo UART/HSU và chuẩn bị PN532 cho quá trình phát hiện thẻ.],
  parameters: (),
  returns: [
    `PN532_STATUS_OK` khi khởi tạo thành công; một giá trị trạng thái lỗi
    `PN532_STATUS_*` nếu không thể hoàn tất thao tác khởi tạo.
  ],
)

Ví dụ:

```c
if (PN532_STATUS_OK == PN532_Begin())
{
    Serial1_println("PN532 ready.");
}
```

Các trạng thái lỗi chi tiết có thể được chuyển thành chuỗi bằng
`PN532_StatusString()`. Trong bài chính, chương trình chỉ cần thông báo khởi
tạo thành công hoặc thất bại.

== `PN532_IsCardPresent()`

`PN532_IsCardPresent()` gửi yêu cầu tìm một thẻ ISO/IEC 14443 Type A. Khi tìm
thấy thẻ, driver lưu thông tin nhận dạng của thẻ hiện tại; vì vậy có thể gọi
`PN532_GetUID()` ngay sau khi hàm trả về `true`
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_IsCardPresent",
  syntax: [PN532_IsCardPresent();],
  description: [Quét một thẻ tương thích và lưu thông tin của thẻ khi phát hiện thành công.],
  parameters: (),
  returns: [
    `true` nếu phát hiện và đọc thông tin thẻ thành công; `false` khi không
    có thẻ hoặc khi thao tác giao tiếp thất bại.
  ],
)

Ví dụ:

```c
if (true == PN532_IsCardPresent())
{
    Serial1_println("Card detected.");
}
```

#note[
  `PN532_IsCardPresent()` thực hiện giao tiếp thực tế và có thể chờ phản hồi
  từ module. Giá trị `false` không tự phân biệt trường hợp chưa có thẻ với
  lỗi giao tiếp; nguyên nhân chi tiết có thể được truy vấn bằng
  `PN532_GetLastError()` trong phần Mở rộng
  #cite-ref(refs, "eduframework-pn532").
]

== `PN532_GetUID()`

`PN532_GetUID()` không thực hiện một lần quét mới. Hàm chỉ trả về chuỗi UID
đã được lưu từ lần phát hiện thẻ thành công gần nhất. Driver định dạng các
byte UID thành các cặp ký tự hexadecimal phân tách bằng dấu cách
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_GetUID",
  syntax: [PN532_GetUID();],
  description: [Truy xuất UID của thẻ hiện tại dưới dạng chuỗi hexadecimal.],
  parameters: (),
  returns: [
    Chuỗi UID dạng `EE 68 17 05` khi dữ liệu hiện tại hợp lệ; chuỗi rỗng
    nếu chưa có UID hợp lệ trong bộ nhớ của driver.
  ],
)

Ví dụ:

```c
Serial1_print("UID: ");
Serial1_println(PN532_GetUID());
```

Chuỗi trả về do driver quản lý, không cần khai báo mảng UID hoặc tự chuyển
đổi từng byte. Ứng dụng chỉ dùng chuỗi để hiển thị, không chỉnh sửa dữ liệu
qua con trỏ trả về #cite-ref(refs, "eduframework-pn532").

== `PN532_End()`

`PN532_End()` giải phóng target đang được chọn và xóa thông tin thẻ được lưu
trong Easy API. Hàm không thực hiện thao tác tắt nguồn module PN532; ứng dụng
có thể tiếp tục quét ở vòng lặp sau #cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_End",
  syntax: [PN532_End();],
  description: [Giải phóng thẻ đang được chọn sau khi chương trình xử lý UID.],
  parameters: (),
  returns: [
    `true` khi giải phóng target thành công; `false` nếu không có target hợp
    lệ hoặc thao tác không thành công.
  ],
)

Ví dụ:

```c
(void)PN532_End();
```

Bài chính gọi hàm sau khi đã in UID. Nếu một thẻ vẫn nằm trong vùng anten,
lần quét tiếp theo có thể tiếp tục phát hiện cùng thẻ, nên UID có thể xuất
hiện nhiều lần trên Serial Monitor.

Các hàm `Serial1_begin()`, `Serial1_print()` và `Serial1_println()` đã được
trình bày trong Lab 03. Lab 10 sử dụng lại các API này để hiển thị kết quả,
không lặp lại mô tả cú pháp Serial API ở đây.

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng ứng dụng phát hiện thẻ bằng PN532 và hiển thị UID trên Serial Monitor.
Chương trình có những yêu cầu sau:

- Dùng module PN532 V3 ở chế độ `HSU`, kết nối với `UART2_TX` và `UART2_RX`.
- Khởi tạo `Serial1` ở `9600 baud`, xuất thông báo khởi động và kết quả khởi tạo.
- Chỉ thực hiện vòng lặp quét khi `PN532_Begin()` thành công.
- Khi phát hiện một thẻ tương thích, lấy UID từ Easy API và in dưới dạng hexadecimal.
- Sau khi xử lý UID, giải phóng target và tiếp tục chờ lần quét tiếp theo.

Bài thực hành không yêu cầu tạo cấu trúc dữ liệu, xử lý UID ở dạng mảng hay
triển khai lệnh giao thức PN532 trực tiếp. Có thể sử dụng thẻ trắng và móc
khóa NFC đi kèm module để kiểm chứng, nếu chúng tương thích với chế độ thẻ
ISO/IEC 14443 Type A đang được driver lựa chọn
#cite-ref(refs, "eduframework-pn532").

== Chương trình

Trong `src/main.c`, sử dụng chương trình đã được kiểm thử trên phần cứng:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình nhận diện thẻ NFC và hiển thị UID bằng PN532],
  )[
    ```c
    #include "Arduino.h"
    #include "pn532.h"

    int main(void)
    {
        setup();

        Serial1_begin(9600U);
        Serial1_println("PN532 NFC Card Detection");

        if (PN532_STATUS_OK == PN532_Begin())
        {
            Serial1_println("PN532 ready.");
        }
        else
        {
            Serial1_println("PN532 initialization failed.");

            while (1)
            {
                delay(1000U);
            }
        }

        while (1)
        {
            if (true == PN532_IsCardPresent())
            {
                Serial1_print("UID: ");
                Serial1_println(PN532_GetUID());

                (void)PN532_End();
                delay(500U);
            }

            delay(100U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` chuẩn bị những thành phần nền tảng của EduFramework, còn
`Serial1_begin(9600U)` mở kênh log. `PN532_Begin()` tự khởi tạo `Serial2`
ở `115200 baud` và chuẩn bị PN532; vì vậy chương trình chính không cần gọi
`Serial2_begin()` riêng #cite-ref(refs, "eduframework-pn532").

Trong vòng lặp, `PN532_IsCardPresent()` thử phát hiện một thẻ. Khi có kết quả
hợp lệ, `PN532_GetUID()` trả về chuỗi đã được định dạng để hiển thị. Chương
trình gọi `PN532_End()` sau khi in để giải phóng target, chờ `500 ms` và sau
đó tiếp tục vòng lặp với một khoảng `delay(100U)`.

#note[
  `delay(100U)` là khoảng chờ *sau* một lần thực hiện vòng lặp, không phải
  cam kết rằng PN532 quét chính xác mỗi `100 ms`. Lệnh quét dùng UART/HSU,
  chờ phản hồi và có cơ chế timeout trong driver nên thời gian giữa hai lần
  hiển thị còn phụ thuộc vào quá trình giao tiếp
  #cite-ref(refs, "eduframework-pn532").
]

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU, sau đó mở Serial Monitor ở
`9600 baud`. Kiểm tra thông báo `PN532 ready.` để xác nhận module được khởi
tạo thành công. Khi đưa thẻ vào vùng đọc, quan sát thông tin UID xuất hiện
trên Serial Monitor. Có thể thay bằng thẻ khác để so sánh giá trị nhận được.

Đoạn log dưới đây được ghi nhận trong lần kiểm thử thực tế của Lab 10:

```text
PN532 NFC Card Detection
PN532 ready.
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
```

Các lần hiển thị cùng một UID cho thấy chương trình có thể tiếp tục phát hiện
thẻ đang nằm trong vùng đọc. Giá trị `EE 68 17 05` là kết quả của thẻ được
sử dụng trong thử nghiệm, không phải UID cố định của module PN532. Khi thử
thẻ khác, UID thực tế phụ thuộc vào thẻ đó #cite-ref(refs, "nxp-uid")
#cite-ref(refs, "eduframework-pn532").

Các điểm cần đối chiếu khi kiểm chứng:

- Chương trình hiển thị trạng thái `PN532 ready.` khi khởi tạo thành công.
- UID được hiển thị bằng các byte hexadecimal, phân tách bằng dấu cách.
- Đưa thẻ ra khỏi anten thì không có UID mới được in; đưa thẻ lại gần có thể đọc tiếp.
- Nếu khởi tạo không thành công, chương trình thông báo lỗi và không thực hiện quét thẻ.

#block(breakable: false)[
  #expected-result[
    PN532 hoạt động ở chế độ UART/HSU và được khởi tạo thành công. Khi một
    thẻ ISO/IEC 14443 Type A tương thích xuất hiện trong vùng đọc,
    Serial Monitor hiển thị UID dạng hexadecimal. Chương trình chỉ in
    UID sau khi phát hiện thẻ thành công và tiếp tục sẵn sàng cho lần quét sau.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài chính chỉ thực hiện chức năng phát hiện thẻ và in UID. Những yêu cầu dưới
đây giới thiệu thêm khả năng của PN532 và EduFramework, nhưng không làm thay
đổi chương trình bắt buộc của Lab 10 #cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

== Quan sát thông tin thẻ

Sau khi `PN532_IsCardPresent()` thành công, driver có thể cung cấp độ dài
UID, `ATQA` và `SAK` của thẻ được phát hiện qua các hàm
`PN532_GetUIDLength()`, `PN532_GetATQA()` và `PN532_GetSAK()`. Những trường
thông tin này liên quan đến quá trình khởi tạo và lựa chọn thẻ Type A được
mô tả trong tài liệu PN532 của NXP
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

Ngoài ra, `PN532_GetCardType()` trả về chuỗi phân loại *ước đoán* dựa trên
các trường thông tin vừa đọc. Giá trị này không phải bằng chứng xác nhận
chính xác loại chip hoặc khả năng của thẻ.

*Mở rộng:* In thêm độ dài UID và kết quả phân loại sơ bộ khi quét thẻ.
So sánh dữ liệu thu được từ hai thẻ hoặc tag khác nhau.

== Phân biệt thẻ bằng UID và phản hồi LED

Có thể lưu một UID đã đo và so sánh với chuỗi được đọc qua
`PN532_GetUID()`. Khi trùng giá trị, chương trình hiển thị `MATCH`;
ngược lại, hiển thị `NOT MATCH`. Có thể kết hợp LED xanh và LED đỏ của
MaaZEDU để tạo phản hồi trực quan bằng Digital Output đã học từ Lab 01
và Lab 02. Ý tưởng sử dụng thông tin từ thẻ trong một ứng dụng quản lý
được minh họa ở nghiên cứu của Mohandes về điểm danh qua NFC
#cite-ref(refs, "mohandes-attendance").

*Mở rộng:* Đọc UID của một thẻ mẫu, lưu giá trị để so sánh và điều khiển
LED theo kết quả. Không xem việc so sánh UID là cơ chế xác thực bảo mật:
NXP đã mô tả Random ID và Non-Unique ID, trong khi hệ thống thực tế còn
cần xác thực và các biện pháp an toàn thích hợp #cite-ref(refs, "nxp-uid").

== Kiểm tra trạng thái giao tiếp

Nếu `PN532_IsCardPresent()` trả về `false`, ứng dụng chưa thể kết luận nguyên
nhân chỉ từ giá trị boolean. EduFramework hỗ trợ `PN532_GetLastError()` để
xem trạng thái thao tác gần nhất, `PN532_StatusString()` để đổi trạng thái
thành nhãn và `PN532_GetDiagnostics()` để khảo sát giai đoạn chờ phản hồi
hoặc các byte UART đã nhận #cite-ref(refs, "eduframework-pn532").

*Mở rộng:* Phân biệt trường hợp không có thẻ với lỗi timeout hoặc dữ liệu
phản hồi không hợp lệ. Chỉ thêm chức năng chẩn đoán sau khi ứng dụng
đọc UID cơ bản hoạt động ổn định.

== Đọc dữ liệu được lưu trên thẻ

PN532 hỗ trợ trao đổi dữ liệu với một số dòng thẻ MIFARE. Trong EduFramework,
việc đọc block MIFARE Classic yêu cầu xác thực phù hợp trước khi gọi
`PN532_ReadBlock()`, sau đó có thể lấy nội dung đã đọc bằng
`PN532_GetBlockHex()`. Driver còn có các thao tác riêng cho
Ultralight/NTAG, nhưng chúng không được sử dụng trong bài chính
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

#warning[
  Không thực hiện ghi block, sector trailer, trang khóa, OTP hoặc trang
  cấu hình khi chưa xác định chính xác loại thẻ và ý nghĩa vùng nhớ.
  Các thao tác ghi có thể làm thay đổi dữ liệu hoặc cấu hình không thể
  phục hồi. Phần mở rộng này chỉ yêu cầu khảo sát chức năng đọc với
  thẻ được phép sử dụng #cite-ref(refs, "eduframework-pn532").
]

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
