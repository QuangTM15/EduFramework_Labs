#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 10 - Nhận diện thẻ RFID với MFRC522
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "nxp-mfrc522",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [MFRC522 Standard performance MIFARE and NTAG frontend],
    revision: [3.9],
    year: [2016],
    url: "https://www.nxp.com/docs/en/data-sheet/MFRC522.pdf",
  ),
  (
    key: "alfaisal-rfid-lab",
    type: "web",
    author: [Anis Koubaa],
    title: [Lab: RFID Access Control System],
    source: [SE322: Internet of Things Applications, College of Engineering, Alfaisal University],
    year: [2025],
    url: "https://aniskoubaa.org/se322/lectures/lecture15/lab_notes/",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
  ),
  (
    key: "eduframework-rc522",
    type: "web",
    author: [EduFramework],
    title: [RC522 Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 10,
  language: "vi",
  title: [Nhận diện thẻ RFID \
    với MFRC522],
  subtitle: [Đọc UID thẻ bằng RC522 Device API với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

RFID (Radio Frequency Identification) cho phép một hệ thống nhận dạng thẻ hoặc
tag bằng giao tiếp vô tuyến thay vì yêu cầu tiếp xúc điện trực tiếp. Trong bài
lab này, module MFRC522 được sử dụng làm reader để phát hiện thẻ RFID tương thích
và lấy thông tin nhận dạng của thẻ.
#cite-ref(refs, "nxp-mfrc522").

Trong một ứng dụng RFID cơ bản, reader phát hiện thẻ, đọc UID rồi chuyển UID cho
chương trình để hiển thị hoặc xử lý. Tài liệu thực hành của Alfaisal University
sử dụng cùng mô hình này: MFRC522 đọc UID của thẻ và ứng dụng có thể so sánh UID
với danh sách đã định nghĩa để đưa ra quyết định
#cite-ref(refs, "alfaisal-rfid-lab").


== Mục tiêu

#objectives(
  items: (
    [
      Mô tả vai trò của RFID reader, RFID card/tag và UID trong một hệ thống
      nhận dạng cơ bản.
    ],
    [
      Giải thích vai trò của các tín hiệu SPI `SCK`, `MOSI`, `MISO` và chip-select
      khi kết nối MFRC522 với vi điều khiển.
    ],
    [
      Mô tả luồng xử lý từ khi thẻ xuất hiện đến khi UID được đọc bởi RC522
      Device API.
    ],
    [
      Sử dụng `RC522_PCD_Init()` để khởi tạo reader; sử dụng
      `RC522_PICC_IsNewCardPresent()` và `RC522_PICC_ReadCardSerial()`
      để phát hiện và đọc UID của thẻ.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng hiển thị UID của nhiều thẻ RFID trên
      Serial Monitor.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== RFID reader, card/tag và UID

MFRC522 là reader/writer IC được thiết kế cho giao tiếp không tiếp xúc ở
`13.56 MHz`. IC hỗ trợ giao tiếp với thẻ và transponder theo ISO/IEC 14443 A,
MIFARE và NTAG. Phần phát của MFRC522 điều khiển antenna reader, trong khi phần
thu thực hiện nhận và giải mã tín hiệu phản hồi từ thẻ
#cite-ref(refs, "nxp-mfrc522").

Trong bài lab, MFRC522 đóng vai trò reader còn thẻ hoặc tag RFID là đối tượng
được đưa vào vùng đọc. Ứng dụng không trực tiếp xử lý tín hiệu vô tuyến; thay vào
đó, reader thực hiện giao tiếp với thẻ và cung cấp dữ liệu cho vi điều khiển qua
giao tiếp host #cite-ref(refs, "nxp-mfrc522").

Một thông tin quan trọng khi làm việc với thẻ RFID là UID. UID là một chuỗi byte duy nhất được sử dụng để xác định duy nhất một thẻ RFID. Ví dụ, một UID bốn byte có thể được biểu diễn dưới dạng
`BD 31 15 2B` #cite-ref(refs, "alfaisal-rfid-lab").

RC522 Device hiện tại của EduFramework hỗ trợ UID có kích thước `4 byte`. Sau
khi đọc thành công, các byte UID được lưu trong `rc522_uid_t`, cùng với trường
`size` cho biết số byte hợp lệ và trường `sak` chứa giá trị Select Acknowledge
#cite-ref(refs, "eduframework-rc522").

#note[
  Implementation hiện tại của RC522 Device chỉ hỗ trợ UID bốn byte. UID cascade
  có kích thước `7 byte` hoặc `10 byte`, cùng các chức năng MIFARE authentication
  và block read/write, chưa nằm trong phạm vi hỗ trợ của Device
  #cite-ref(refs, "eduframework-rc522").
]

== Giao tiếp SPI với MFRC522

MFRC522 hỗ trợ nhiều giao tiếp host, trong đó có SPI. Khi sử dụng SPI, MFRC522
hoạt động như thiết bị slave; vi điều khiển tạo tín hiệu clock `SCK`, truyền dữ
liệu tới MFRC522 qua `MOSI` và nhận dữ liệu từ MFRC522 qua `MISO`
#cite-ref(refs, "nxp-mfrc522").

Bên cạnh ba đường tín hiệu trên, SPI cần một tín hiệu chọn thiết bị. Datasheet
MFRC522 ký hiệu tín hiệu này là `NSS`; tín hiệu phải ở mức thấp trong khi một
data stream đang được truyền #cite-ref(refs, "nxp-mfrc522"). Trên module MFRC522
được sử dụng trong bài lab, chân chip-select thường được in nhãn `SDA/SS`. Khi
module hoạt động ở chế độ SPI, chân này được RC522 Device điều khiển như
chip-select mức thấp chứ không được sử dụng như đường dữ liệu I2C
#cite-ref(refs, "eduframework-rc522").

Luồng giao tiếp giữa MaaZEDU và reader có thể mô tả:

`MaaZEDU` ⇄ `SPI` ⇄ `MFRC522` ⇄ `RF` ⇄ `RFID card/tag`

RC522 Device sử dụng các đường SPI cố định của EduFramework cho `SCK`, `MOSI` và
`MISO`, đồng thời cho phép ứng dụng chọn một Digital Logical Pin riêng làm
chip-select và một Digital Logical Pin khác làm reset
#cite-ref(refs, "eduframework-rc522").

== Từ phát hiện thẻ đến đọc UID

Ở mức ứng dụng, quá trình đọc một thẻ có thể được tách thành ba bước chính:
khởi tạo reader, kiểm tra xem có thẻ mới xuất hiện và đọc UID của thẻ. Cách tổ
chức này cũng được sử dụng trong bài thực hành RFID của Alfaisal University,
trong đó chương trình trước hết khởi tạo SPI và MFRC522, sau đó kiểm tra thẻ mới
và đọc UID #cite-ref(refs, "alfaisal-rfid-lab").

Trong EduFramework, `RC522_PCD_Init()` thực hiện phần khởi tạo reader. API cấu
hình hai chân điều khiển, khởi tạo SPI ở chế độ master, reset MFRC522, áp dụng
cấu hình mặc định, bật antenna và kiểm tra giao tiếp thông qua `VersionReg`
#cite-ref(refs, "eduframework-rc522").

Sau khi reader sẵn sàng, `RC522_PICC_IsNewCardPresent()` gửi yêu cầu để kiểm tra
một thẻ ISO/IEC 14443A mới trong vùng đọc. Nếu có phản hồi hợp lệ,
`RC522_PICC_ReadCardSerial()` thực hiện quá trình cần thiết để chọn thẻ và lưu
UID bốn byte vào cấu trúc `rc522_uid_t`
#cite-ref(refs, "eduframework-rc522").

Bài lab không yêu cầu triển khai các bước giao thức ở mức thấp. Ứng dụng chỉ sử
dụng kết quả boolean của hai API để quyết định khi nào UID đã sẵn sàng để hiển
thị.

Luồng xử lý của bài thực hành chính:

`Thẻ xuất hiện` → `IsNewCardPresent()` → `ReadCardSerial()` → `UID bytes` →
`Serial1` → `Serial Monitor`

Sau khi xử lý một thẻ, `RC522_PICC_HaltA()` gửi lệnh HALT tới thẻ đang được chọn.
RC522 Device coi timeout sau lệnh HALT là hành vi mong đợi của một thẻ đã chuyển
sang trạng thái halt #cite-ref(refs, "eduframework-rc522").

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng MaaZEDU Development Board, module MFRC522 và ít nhất một
thẻ hoặc tag RFID tương thích. MFRC522 giao tiếp với vi điều khiển qua SPI, còn
Serial Monitor được sử dụng để quan sát UID đã đọc.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [MFRC522 RFID reader module],
      [
        Module reader dùng để phát hiện và giao tiếp với thẻ RFID tương thích
        ở `13.56 MHz`.
      ],
    ),
    (
      [RFID card/tag],
      [Thẻ hoặc tag được sử dụng để kiểm tra chức năng phát hiện và đọc UID.],
    ),
    (
      [Jumper wires],
      [Kết nối nguồn, SPI, chip-select và reset giữa MFRC522 với MaaZEDU.],
    ),
    (
      [USB Cable],
      [
        Kết nối board với máy tính để cấp nguồn, nạp chương trình và sử dụng
        Serial Monitor.
      ],
    ),
  ),
)

== Ánh xạ chân sử dụng

RC522 Device sử dụng các đường SPI của EduFramework cho clock và dữ liệu. Trong
bài thực hành, `GPIO0` được chọn làm software chip-select và `GPIO1` được chọn
làm reset. Trên MaaZEDU, các tín hiệu SPI tương ứng với nhóm chân SPI của board;
`GPIO0` ánh xạ tới `PTE0` và `GPIO1` ánh xạ tới `PTD17`
#cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-rc522").

#pin-table(
  caption: [Ánh xạ tín hiệu MFRC522 sử dụng trong bài thực hành],
  rows: (
    (
      [MFRC522 `SCK`],
      "SPI_SCK",
      "PTB14",
      [SPI Clock],
    ),
    (
      [MFRC522 `MOSI`],
      "SPI_SOUT",
      "PTB16",
      [SPI Data: MaaZEDU → MFRC522],
    ),
    (
      [MFRC522 `MISO`],
      "SPI_SIN",
      "PTB15",
      [SPI Data: MFRC522 → MaaZEDU],
    ),
    (
      [MFRC522 `SDA/SS`],
      "GPIO0",
      "PTE0",
      [Software Chip-Select],
    ),
    (
      [MFRC522 `RST`],
      "GPIO1",
      "PTD17",
      [Digital Output / Reset],
    ),
  ),
)

== Kết nối MFRC522

Trong cấu hình đã được kiểm chứng cho bài thực hành, MFRC522 được cấp nguồn từ
`3.3V`, sử dụng chung `GND` với MaaZEDU và được nối theo các đường SPI như bảng
ánh xạ phía trên. Chân `IRQ` không được sử dụng trong bài thực hành này.

#figure-block(
  caption: [Sơ đồ kết nối MFRC522 với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/rfid_card_detection_circuit.png",
    width: 88%,
  )
]

#note[
  Chân có nhãn `SDA/SS` trên module được sử dụng làm chip-select khi làm việc
  với RC522 Device qua SPI. Không nối chân này vào giao tiếp I2C của MaaZEDU.
  `GPIO0` và `GPIO1` là hai Logical Pin được lựa chọn cho chip-select và reset
  trong bài thực hành #cite-ref(refs, "eduframework-rc522").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài thực hành chính sử dụng bốn API của RC522 Device:
`RC522_PCD_Init()`, `RC522_PICC_IsNewCardPresent()`,
`RC522_PICC_ReadCardSerial()` và `RC522_PICC_HaltA()`. Các thao tác reset reader,
điều khiển antenna và đọc `VersionReg` được dành cho phần Mở rộng
#cite-ref(refs, "eduframework-rc522").

== Cấu trúc `rc522_uid_t`

Dữ liệu UID được lưu trong cấu trúc `rc522_uid_t`. Đối với bài lab này, hai
trường cần quan tâm là `bytes`, chứa từng byte của UID, và `size`, cho biết số
byte UID hợp lệ. Trường `sak` được thư viện lưu lại nhưng không cần xử lý trong
bài thực hành chính #cite-ref(refs, "eduframework-rc522").

Ví dụ khai báo:

```c
rc522_uid_t uid = {{0U}, 0U, 0U};
```

Sau một lần đọc thành công, các byte UID có thể được truy cập bằng
`uid.bytes[i]` với `i` chạy từ `0` đến `uid.size - 1`.

== `RC522_PCD_Init()`

`RC522_PCD_Init()` khởi tạo reader với một Logical Pin làm chip-select và một
Logical Pin làm reset. API trả về `true` khi quá trình khởi tạo và kiểm tra giao
tiếp hoàn tất thành công #cite-ref(refs, "eduframework-rc522").

#api-detail(
  name: "RC522_PCD_Init",
  syntax: [RC522_PCD_Init(csPin, resetPin);],
  description: [
    Khởi tạo MFRC522, SPI và các chân điều khiển cần thiết cho reader.
  ],
  parameters: (
    (
      [csPin],
      [Digital Logical Pin],
      [Chân digital dùng làm software chip-select cho MFRC522.],
    ),
    (
      [resetPin],
      [Digital Logical Pin],
      [Chân digital dùng để reset MFRC522.],
    ),
  ),
  returns: [
    `true` khi khởi tạo và kiểm tra giao tiếp thành công; `false` khi cấu hình
    chân, reset hoặc kiểm tra giao tiếp thất bại.
  ],
)

Ví dụ:

```c
bool ready = RC522_PCD_Init(GPIO0, GPIO1);
```

== `RC522_PICC_IsNewCardPresent()`

`RC522_PICC_IsNewCardPresent()` kiểm tra xem có một thẻ ISO/IEC 14443A mới phản
hồi trong vùng đọc hay không. Ứng dụng sử dụng giá trị trả về để tránh cố đọc
UID khi chưa có thẻ #cite-ref(refs, "eduframework-rc522").

#api-detail(
  name: "RC522_PICC_IsNewCardPresent",
  syntax: [RC522_PICC_IsNewCardPresent();],
  description: [
    Kiểm tra sự hiện diện của một thẻ mới trong vùng đọc.
  ],
  parameters: (),
  returns: [
    `true` khi nhận được phản hồi thẻ hợp lệ; `false` khi không có thẻ hoặc giao
    tiếp không thành công.
  ],
)

Ví dụ:

```c
if (true == RC522_PICC_IsNewCardPresent())
{
    /* A new card is present. */
}
```

== `RC522_PICC_ReadCardSerial()`

`RC522_PICC_ReadCardSerial()` đọc và chọn thẻ hiện tại, sau đó lưu UID vào cấu
trúc được truyền vào. Implementation hiện tại chỉ chấp nhận UID bốn byte
#cite-ref(refs, "eduframework-rc522").

#api-detail(
  name: "RC522_PICC_ReadCardSerial",
  syntax: [RC522_PICC_ReadCardSerial(&uid);],
  description: [
    Đọc UID của thẻ đã được phát hiện và lưu kết quả vào cấu trúc UID.
  ],
  parameters: (
    (
      [pUid],
      [UID data],
      [
        Địa chỉ của cấu trúc `rc522_uid_t` dùng để nhận các byte UID, kích thước
        UID và SAK.
      ],
    ),
  ),
  returns: [
    `true` khi UID và SAK được đọc thành công; `false` khi tham số không hợp lệ,
    giao tiếp thất bại hoặc thẻ yêu cầu UID cascade chưa được hỗ trợ.
  ],
)

Ví dụ:

```c
if (true == RC522_PICC_ReadCardSerial(&uid))
{
    Serial1_printInt((int)uid.bytes[0]);
}
```

== `RC522_PICC_HaltA()`

Sau khi UID đã được xử lý, `RC522_PICC_HaltA()` gửi lệnh HALT tới thẻ đang được
chọn. API không có tham số và không trả về giá trị
#cite-ref(refs, "eduframework-rc522").

#api-detail(
  name: "RC522_PICC_HaltA",
  syntax: [RC522_PICC_HaltA();],
  description: [
    Đưa thẻ đang được chọn vào trạng thái HALT sau khi hoàn tất xử lý.
  ],
  parameters: (),
  returns: [
    Không có giá trị trả về.
  ],
)

Ví dụ:

```c
RC522_PICC_HaltA();
```

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình phát hiện thẻ RFID bằng MFRC522 và hiển thị UID của thẻ
trên Serial Monitor. Module sử dụng `GPIO0` làm chip-select, `GPIO1` làm reset và
các đường `SPI_SCK`, `SPI_SOUT`, `SPI_SIN` cho giao tiếp SPI.

Chương trình khởi tạo `Serial1` ở baud rate `9600`. Khi MFRC522 khởi tạo thành
công, Serial Monitor hiển thị `RC522 ready.`. Trong vòng lặp chính, chương trình
chỉ đọc UID khi một thẻ mới được phát hiện. Mỗi byte UID được in theo dạng số
thập phân.

Sử dụng ít nhất hai thẻ hoặc tag nếu có để kiểm chứng rằng chương trình có thể
đọc và hiển thị các UID khác nhau.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng như
sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình phát hiện thẻ và hiển thị UID bằng MFRC522],
  )[
    ```c
    #include "Arduino.h"
    #include "rc522.h"

    int main(void)
    {
        rc522_uid_t uid = {{0U}, 0U, 0U};
        uint8_t i = 0U;

        setup();

        Serial1_begin(9600U);

        if (true == RC522_PCD_Init(GPIO0, GPIO1))
        {
            Serial1_println("RC522 ready.");
        }
        else
        {
            Serial1_println("RC522 initialization failed.");
        }

        while (1)
        {
            if (true == RC522_PICC_IsNewCardPresent())
            {
                if (true == RC522_PICC_ReadCardSerial(&uid))
                {
                    Serial1_print("UID: ");

                    for (i = 0U; i < uid.size; i++)
                    {
                        Serial1_printInt((int)uid.bytes[i]);
                        Serial1_print(" ");
                    }

                    Serial1_println("");

                    RC522_PICC_HaltA();
                    delay(500U);
                }
            }

            delay(20U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo các thành phần nền tảng của EduFramework và
`Serial1_begin(9600U)` chuẩn bị kênh Serial Monitor. Sau đó,
`RC522_PCD_Init(GPIO0, GPIO1)` cấu hình reader với `GPIO0` làm chip-select và
`GPIO1` làm reset #cite-ref(refs, "eduframework-rc522").

Trong vòng lặp chính, chương trình gọi `RC522_PICC_IsNewCardPresent()` trước.
Chỉ khi API này trả về `true`, chương trình mới gọi
`RC522_PICC_ReadCardSerial(&uid)`. Cách tổ chức kiểm tra thẻ trước khi đọc UID
cũng tương ứng với luồng ứng dụng RFID được trình bày trong tài liệu thực hành
của Alfaisal University #cite-ref(refs, "alfaisal-rfid-lab")
#cite-ref(refs, "eduframework-rc522").

Khi UID được đọc thành công, vòng `for` đi qua `uid.size` phần tử và in từng byte
trong `uid.bytes[]` lên Serial Monitor. Bài lab sử dụng biểu diễn số thập phân để
giữ phần chương trình hiển thị đơn giản. Sau đó `RC522_PICC_HaltA()` kết thúc
quá trình xử lý thẻ hiện tại #cite-ref(refs, "eduframework-rc522").

Luồng xử lý của chương trình:

`MFRC522 ready` → `Phát hiện thẻ` → `Đọc UID` → `In từng byte UID` →
`Halt thẻ` → `Chờ lần quét tiếp theo`

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board, sau đó mở Serial
Monitor với baud rate `9600`. Khi reader khởi tạo thành công, quan sát thông báo:

```text
RC522 ready.
```

Đưa thẻ hoặc tag vào vùng đọc của MFRC522. Khi đọc thành công, UID được hiển thị
trên Serial Monitor. Với hai thẻ đã được sử dụng để kiểm chứng bài lab, dữ liệu
thu được có dạng:

```text
UID: 100 29 168 0
UID: 100 29 168 0
UID: 238 104 23 5
UID: 238 104 23 5
```

Hai nhóm giá trị khác nhau cho thấy ứng dụng đã nhận dữ liệu UID khác nhau từ
hai thẻ/tag được kiểm tra. Giá trị cụ thể phụ thuộc vào thẻ đang sử dụng và
không được cố định trong chương trình chính.

#block(breakable: false)[
  #expected-result[
    Sau khi MFRC522 khởi tạo thành công, Serial Monitor hiển thị
    `RC522 ready.`. Khi một thẻ hoặc tag tương thích được đưa vào vùng đọc,
    chương trình phát hiện thẻ, đọc UID bốn byte và in các byte UID lên Serial
    Monitor. Khi đổi sang thẻ khác, dữ liệu UID hiển thị thay đổi theo thẻ được
    đọc. Nếu reader không khởi tạo thành công, chương trình hiển thị
    `RC522 initialization failed.` #cite-ref(refs, "eduframework-rc522").
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính chỉ đọc và hiển thị UID. RC522 Device còn cung cấp các API
hỗ trợ quan sát trạng thái reader, trong khi UID đã đọc có thể được sử dụng làm
dữ liệu đầu vào cho một bài toán nhận dạng đơn giản
#cite-ref(refs, "eduframework-rc522") #cite-ref(refs, "alfaisal-rfid-lab").

== Kiểm tra `VersionReg` với `RC522_PCD_GetVersion()`

Sau khi reader khởi tạo thành công, `RC522_PCD_GetVersion()` trả về giá trị
`VersionReg` đọc từ MFRC522. RC522 Device sử dụng chính thanh ghi này trong quá
trình khởi tạo để kiểm tra giao tiếp với reader
#cite-ref(refs, "eduframework-rc522").

#api-detail(
  name: "RC522_PCD_GetVersion",
  syntax: [RC522_PCD_GetVersion();],
  description: [
    Đọc giá trị `VersionReg` của MFRC522 sau khi Device đã được khởi tạo.
  ],
  parameters: (),
  returns: [
    Giá trị `VersionReg`; `RC522_VERSION_INVALID` nếu Device chưa được khởi tạo.
  ],
)

Mở rộng: Sau thông báo `RC522 ready.`, đọc `VersionReg` và in giá trị dạng số
thập phân lên Serial Monitor.

Ví dụ:

```c
Serial1_print("VersionReg: ");
Serial1_printlnInt((int)RC522_PCD_GetVersion());
```

== Nhận dạng thẻ được cho phép bằng UID

Tài liệu thực hành của Alfaisal University mở rộng quá trình đọc UID thành bài
toán access control bằng cách lưu trước các UID được cho phép rồi so sánh UID
vừa quét với danh sách đó #cite-ref(refs, "alfaisal-rfid-lab").

Với implementation hiện tại của EduFramework, UID hỗ trợ có kích thước bốn byte.
Có thể lưu một UID đã biết trong một mảng và so sánh từng byte với
`uid.bytes[]`.

Ví dụ sử dụng UID đã đo trong bài lab:

```c
static const uint8_t authorizedUid[4U] =
{
    238U, 104U, 23U, 5U
};
```

Yêu cầu mở rộng:

- Khi UID vừa đọc trùng cả bốn byte với `authorizedUid`, in
  `Authorization: GRANTED`.

- Khi ít nhất một byte khác, in `Authorization: DENIED`.

- Không thay đổi trạng thái hệ thống nếu UID không được cho phép.

Phần mở rộng này bổ sung bước xử lý sau khi đọc UID nhưng không thay đổi luồng
giao tiếp với MFRC522:

`Phát hiện` → `Đọc UID` → `So sánh UID` → `GRANTED / DENIED`

== Điều khiển LED theo kết quả nhận dạng

Sau khi hoàn thành phép so sánh UID, có thể bổ sung phản hồi trực quan bằng hai
LED trên MaaZEDU. Một hướng triển khai là sử dụng LED xanh cho trạng thái được
cho phép và LED đỏ cho trạng thái từ chối.

Yêu cầu mở rộng:

- UID được cho phép: chuyển trạng thái điều khiển và cập nhật LED xanh.

- UID không được cho phép: chuyển trạng thái điều khiển và cập nhật LED đỏ.

- Vẫn in UID và kết quả `GRANTED` hoặc `DENIED` trên Serial Monitor.

Bài mở rộng này kết hợp kiến thức Digital Output từ các lab trước với dữ liệu
UID của RC522 Device. Luồng xử lý trở thành:

`RFID card` → `UID` → `So sánh` → `Trạng thái ứng dụng` → `LED + Serial Monitor`

Một hệ thống access control hoàn chỉnh có thể bổ sung thêm actuator hoặc cơ chế
quản lý danh sách UID. Trong phạm vi Lab 10, mục tiêu chỉ là sử dụng UID làm dữ
liệu nhận dạng để thực hành cấu trúc quyết định ở tầng ứng dụng
#cite-ref(refs, "alfaisal-rfid-lab").

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
