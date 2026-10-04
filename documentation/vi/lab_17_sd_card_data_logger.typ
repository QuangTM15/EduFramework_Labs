#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 17 - SD Card Data Logger
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "methodsx-data-logger",
    type: "web",
    author: [Youcef Bouchekioua, Hiroshi Matsui, Shigeru Watanabe],
    title: [A Versatile and Fast-Sampling Rate Wearable Analog Data Logger],
    source: [MethodsX, Vol. 10, 102098],
    year: [2023],
    url: "https\://doi.org/10.1016/j.mex.2023.102098",
  ),
  (
    key: "cave-pearl",
    type: "web",
    author: [Patricia A. Beddows, Edward K. Mallon],
    title: [Cave Pearl Data Logger: A Flexible Arduino-Based Logging Platform for Long-Term Monitoring in Harsh Environments],
    source: [Sensors, Vol. 18, No. 2, 530],
    year: [2018],
    url: "https\://doi.org/10.3390/s18020530",
  ),
  (
    key: "sd-association",
    type: "web",
    author: [SD Association],
    title: [Physical Layer Simplified Specification],
    source: [SD Specifications - Part 1 Simplified],
    revision: [9.10],
    year: [2023],
    url: "https\://www\.sdcard.org/downloads/pls/",
  ),
  (
    key: "fatfs",
    type: "web",
    author: [ChaN],
    title: [FatFs - Generic FAT Filesystem Module],
    source: [FatFs Documentation],
    url: "https\://elm-chan.org/fsw/ff/",
  ),
  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https\://www\.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
  ),
  (
    key: "eduframework-sd",
    type: "web",
    author: [EduFramework],
    title: [SD Card Device API],
    source: [EduFramework v3.0.0 Source Code],
    url: "https\://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 17,
  language: "vi",
  title: [SD Card Data Logger],
  subtitle: [Lưu dữ liệu ADC vào SD Card với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Trong các hệ thống đo lường và giám sát, dữ liệu không phải lúc nào cũng chỉ được
quan sát tại thời điểm chương trình đang chạy. Một data logger thu dữ liệu từ
cảm biến hoặc tín hiệu đầu vào, xử lý bằng vi điều khiển và lưu lại để có thể
truy xuất hoặc phân tích sau đó. Các hệ thống data logger sử dụng vi điều khiển
và thẻ nhớ microSD đã được ứng dụng trong nhiều bài toán thu thập tín hiệu analog
và giám sát dài hạn #cite-ref(refs, "methodsx-data-logger")
#cite-ref(refs, "cave-pearl").

Bài lab này sử dụng biến trở làm nguồn dữ liệu analog. S32K144 đọc giá trị ADC,
sau đó lưu mười mẫu dữ liệu vào một file trên SD Card. Serial Monitor được dùng
để theo dõi quá trình thu mẫu, còn dữ liệu lưu trên thẻ có thể được kiểm tra lại
sau khi quá trình ghi hoàn tất.

Bài thực hành tập trung vào thao tác lưu trữ ở cấp ứng dụng. Các chi tiết giao
tiếp SPI và xử lý giao thức SD ở mức thấp không được triển khai trong chương
trình chính; EduFramework cung cấp SD Card Device API để thực hiện các thao tác
khởi tạo, mở file, ghi dữ liệu và đóng tài nguyên.

== Mục tiêu

#objectives(
  items: (
    [Mô tả luồng dữ liệu cơ bản của một hệ thống data logging sử dụng vi điều khiển và bộ nhớ ngoài.],
    [Giải thích vai trò của SD Card và filesystem trong việc lưu trữ dữ liệu của ứng dụng nhúng.],
    [Kết nối module MicroSD và biến trở với MaaZEDU Development Board theo cấu hình của bài thực hành.],
    [Sử dụng `SD_Begin()`, `SD_Open()`, `SD_WriteLine()`, `SD_Close()` và `SD_End()` để tạo và ghi dữ liệu vào file.],
    [Kiểm chứng dữ liệu ADC đã được lưu trên SD Card sau khi chương trình kết thúc quá trình ghi.],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Data logging và lưu trữ dữ liệu

Data logging là quá trình thu thập dữ liệu theo thời gian và lưu lại để phục vụ
việc quan sát hoặc phân tích sau đó. Một hệ thống có thể nhận dữ liệu từ cảm
biến, tín hiệu analog hoặc các thiết bị đo, sau đó sử dụng vi điều khiển làm khối
thu thập và xử lý trước khi ghi dữ liệu xuống bộ nhớ
#cite-ref(refs, "methodsx-data-logger").

Mô hình tổng quát có thể biểu diễn như sau:

`Nguồn dữ liệu` → `Thu thập` → `Vi điều khiển` → `Lưu trữ`.

Trong bài lab này, biến trở tạo điện áp analog và `analogRead()` chuyển tín hiệu
đó thành giá trị ADC thô. Giá trị được lưu vào file trên SD Card thay vì chỉ hiển
thị trên Serial Monitor:

`Potentiometer` → `ADC0_SE12` → `S32K144` → `SD Card` → `File`.

Cách tổ chức này minh họa sự khác biệt giữa quan sát dữ liệu tức thời và lưu dữ
liệu để sử dụng về sau. Các data logger dùng bộ nhớ tháo rời như microSD đặc biệt
phù hợp khi hệ thống cần giữ lại nhiều lần đo mà không phụ thuộc vào kết nối liên
tục với máy tính #cite-ref(refs, "cave-pearl").

== SD Card trong hệ thống nhúng

SD Card là thiết bị lưu trữ sử dụng bộ nhớ flash và có thể được sử dụng bởi host
thông qua các chế độ giao tiếp được đặc tả bởi SD Association
#cite-ref(refs, "sd-association"). Trong EduFramework, SD Card Device sử dụng giao
diện SPI đã có của framework, còn application chỉ làm việc với các API lưu trữ
ở mức cao hơn #cite-ref(refs, "eduframework-sd").

Bài lab không yêu cầu chương trình ứng dụng tự gửi command của SD Card hoặc quản
lý các block vật lý. Những thao tác này được xử lý bên dưới SD Device. Ở cấp ứng
dụng, mục tiêu chỉ là khởi tạo thiết bị lưu trữ, làm việc với file và kết thúc
phiên sử dụng đúng trình tự.

#note[
  SPI đã được sử dụng trong các bài lab trước. Lab 17 không lặp lại nguyên lý
  hoạt động của SPI mà chỉ sử dụng các đường `SCK`, `MOSI`, `MISO` và một chân
  chip-select để kết nối module MicroSD.
]

== Filesystem và vòng đời của file

Thiết bị lưu trữ cung cấp không gian dữ liệu vật lý, trong khi filesystem tổ chức
không gian đó thành các đối tượng mà ứng dụng có thể thao tác như file và thư
mục. FatFs cung cấp các chức năng như mount filesystem, mở file, đọc, ghi, đồng
bộ và đóng file cho các hệ thống nhúng #cite-ref(refs, "fatfs").

EduFramework sử dụng FatFs bên dưới SD Card Device nhưng ẩn các cấu trúc nội bộ
khỏi application. Sau khi `SD_Begin()` thành công, SD Card đã được khởi tạo và
filesystem được mount. Application có thể tiếp tục mở file và ghi dữ liệu bằng
các API của EduFramework #cite-ref(refs, "eduframework-sd").

Vòng đời file trong bài thực hành được giới hạn ở bốn bước chính:

`Initialize` → `Open` → `Write` → `Close`.

Việc đóng file sau khi ghi là một bước quan trọng. Tài liệu FatFs khuyến nghị file
đang mở cần được đóng sau phiên truy cập; dữ liệu và thông tin filesystem còn
được cache có thể chưa được cập nhật an toàn nếu nguồn bị ngắt hoặc thiết bị lưu
trữ bị tháo khi file vẫn đang mở #cite-ref(refs, "fatfs").

#note[
  Chỉ tháo SD Card sau khi chương trình đã hoàn thành việc ghi và đóng file. Trong
  bài thực hành, thông báo `Logging complete.` được in sau `SD_Close()` và
  `SD_End()` để xác nhận chu trình lưu trữ đã kết thúc.
]

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng MaaZEDU Development Board với vi điều khiển S32K144 thuộc họ
S32K1xx #cite-ref(refs, "nxp-s32k-datasheet"). Module MicroSD làm bộ nhớ ngoài,
trong khi biến trở cung cấp tín hiệu analog thay đổi để tạo dữ liệu kiểm thử.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [MicroSD Card Module],
      [Module lưu trữ dùng để kết nối SD Card với giao diện SPI của MaaZEDU.],
    ),
    (
      [MicroSD Card],
      [Thiết bị lưu dữ liệu của bài thực hành.],
    ),
    (
      [Potentiometer],
      [Tạo điện áp analog thay đổi để sinh các mẫu ADC.],
    ),
    (
      [Jumper wires],
      [Kết nối nguồn, SPI, chip-select và tín hiệu analog.],
    ),
    (
      [USB Cable],
      [Kết nối board với máy tính để cấp nguồn, nạp chương trình và sử dụng Serial Monitor.],
    ),
  ),
)

== Ánh xạ chân sử dụng

SD Card Device sử dụng các đường SPI của EduFramework cho clock và dữ liệu. Chân
`GPIO4` được chọn làm software chip-select của module MicroSD. Biến trở được đọc
qua `ADC0_SE12`. MaaZEDU Guide xác định các chân SPI và GPIO tương ứng, trong khi
EduFramework cung cấp các Logical Pin sử dụng trong mã nguồn
#cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-sd").

#pin-table(
  caption: [Ánh xạ tín hiệu sử dụng trong Lab 17],
  rows: (
    (
      [MicroSD `SCK`],
      "SPI_SCK",
      "PTB14",
      [SPI Clock],
    ),
    (
      [MicroSD `MOSI`],
      "SPI_SOUT",
      "PTB16",
      [SPI Data: MaaZEDU → MicroSD],
    ),
    (
      [MicroSD `MISO`],
      "SPI_SIN",
      "PTB15",
      [SPI Data: MicroSD → MaaZEDU],
    ),
    (
      [MicroSD `CS`],
      "GPIO4",
      "PTD12",
      [Software Chip-Select],
    ),
    (
      [Potentiometer `OUT`],
      "ADC0_SE12",
      "PTC14",
      [Analog Input],
    ),
  ),
)

== Kết nối mạch

Module MicroSD được cấp nguồn từ `3V3` trong cấu hình đã kiểm chứng của bài lab.
`SCK`, `MOSI`, `MISO` được nối tới các đường SPI tương ứng, còn `CS` được nối tới
`GPIO4`. Biến trở có hai đầu ngoài nối với `3V3` và GND; chân tín hiệu `OUT` nối
với `ADC0_SE12`.

#figure-block(
  caption: [Sơ đồ kết nối MicroSD và biến trở với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/sd_card_data_logger_circuit.png",
    width: 100%,
  )
]

#note[
  Không tháo SD Card trong khi chương trình đang ghi dữ liệu. Sau khi Serial
  Monitor hiển thị `Logging complete.`, file đã được đóng và SD Device đã kết
  thúc phiên hoạt động của bài thực hành.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài thực hành chính sử dụng SD Card Device API để quản lý toàn bộ chu trình lưu
trữ. Các chi tiết về SD command, block access và FatFs object không xuất hiện
trong application. Application chỉ giữ một `SD_File_t` và gọi các API tương ứng
với các bước khởi tạo, mở, ghi và đóng file #cite-ref(refs, "eduframework-sd").

== `SD_File_t`

`SD_File_t` là file handle do SD Card Device quản lý. Cấu trúc này được truyền
cho các API thao tác file sau khi `SD_Open()` thành công. Application không cần
truy cập hoặc thay đổi trường `handle` bên trong trực tiếp
#cite-ref(refs, "eduframework-sd").

Ví dụ:

```c
SD_File_t file = {SD_INVALID_HANDLE};
```

== `SD_Begin()`

#api-detail(
  name: "SD_Begin",
  syntax: [SD_Begin(csPin);],
  description: [Khởi tạo SD Card qua SPI và mount filesystem sử dụng chân software chip-select đã chọn.],
  parameters: (
    (
      [csPin],
      [Digital Logical Pin],
      [Chân chip-select của SD Card. Bài lab sử dụng `GPIO4`.],
    ),
  ),
  returns: [
    `true` nếu SD Card được khởi tạo và filesystem được mount thành công;
    `false` nếu quá trình khởi tạo hoặc mount thất bại.
  ],
)

Trong bài lab, chỉ cần một lệnh `SD_Begin(GPIO4)` để chuẩn bị cả giao tiếp SD và
filesystem trước khi mở file #cite-ref(refs, "eduframework-sd").

== `SD_Open()` và `SD_FILE_WRITE`

#api-detail(
  name: "SD_Open",
  syntax: [SD_Open(&file, path, mode);],
  description: [Mở một file và gán file handle cho biến `SD_File_t`.],
  parameters: (
    (
      [file],
      [SD File],
      [Địa chỉ của biến `SD_File_t` dùng để quản lý file đang mở.],
    ),
    (
      [path],
      [File path],
      [Tên hoặc đường dẫn file cần mở, ví dụ `"data.csv"`.],
    ),
    (
      [mode],
      [File mode],
      [Chế độ truy cập file. Bài lab sử dụng `SD_FILE_WRITE`.],
    ),
  ),
  returns: [
    `true` nếu file được mở thành công; `false` nếu không thể mở hoặc tạo file.
  ],
)

`SD_FILE_WRITE` được ánh xạ tới chế độ tạo file để ghi. Nếu file cùng tên đã tồn
tại, nội dung cũ được thay thế. Cách xử lý này tương ứng với cơ chế
`FA_CREATE_ALWAYS | FA_WRITE` của FatFs
#cite-ref(refs, "eduframework-sd") #cite-ref(refs, "fatfs").

== `SD_WriteLine()`

#api-detail(
  name: "SD_WriteLine",
  syntax: [SD_WriteLine(&file, text);],
  description: [Ghi một chuỗi ký tự vào file và thêm ký tự kết thúc dòng.],
  parameters: (
    (
      [file],
      [SD File],
      [File handle đã được mở bằng `SD_Open()`.],
    ),
    (
      [text],
      [Text],
      [Chuỗi ký tự cần ghi vào file.],
    ),
  ),
  returns: [
    `true` nếu thao tác ghi hoàn thành; `false` nếu file không hợp lệ hoặc quá
    trình ghi thất bại.
  ],
)

Trong chương trình, mỗi mẫu ADC được chuyển thành một dòng text trước khi truyền
cho `SD_WriteLine()` #cite-ref(refs, "eduframework-sd").

== `SD_Close()` và `SD_End()`

`SD_Close()` kết thúc phiên truy cập của một file đang mở. Sau khi đóng thành
công, file handle không còn đại diện cho một file đang mở. Việc đóng file cũng là
bước cần thiết để hoàn tất cập nhật dữ liệu của filesystem
#cite-ref(refs, "fatfs") #cite-ref(refs, "eduframework-sd").

#api-detail(
  name: "SD_Close",
  syntax: [SD_Close(&file);],
  description: [Đóng file đang được quản lý bởi `SD_File_t`.],
  parameters: (
    (
      [file],
      [SD File],
      [File handle cần đóng.],
    ),
  ),
  returns: [
    `true` nếu file được đóng thành công; `false` nếu file handle không hợp lệ
    hoặc thao tác đóng thất bại.
  ],
)

Sau khi file đã được đóng, `SD_End()` giải phóng các tài nguyên filesystem còn
mở, unmount filesystem và kết thúc hoạt động của giao diện SD trong EduFramework
#cite-ref(refs, "eduframework-sd").

```c
SD_Close(&file);
SD_End();
```

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng một data logger sử dụng biến trở làm nguồn dữ liệu analog. Chương trình
đọc `ADC0_SE12` và lưu mười mẫu vào file `data.csv` trên SD Card. Hai lần lấy mẫu
liên tiếp cách nhau `1000 ms`.

Chương trình cần thực hiện theo trình tự:

`Khởi tạo SD` → `Mở file` → `Thu 10 mẫu ADC` → `Ghi file` → `Đóng file`.

Serial Monitor được sử dụng để hiển thị số thứ tự mẫu và giá trị ADC trong quá
trình chạy. Sau khi hoàn tất, SD Card có thể được tháo và kiểm tra trên máy tính.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng như
sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình ghi dữ liệu ADC vào SD Card],
  )[
    ```c
    #include "Arduino.h"
    #include "sd_card.h"
    #include <stdio.h>
    int main(void)
    {
        SD_File_t file = {SD_INVALID_HANDLE};
        int adcValue = 0;
        uint8_t sample = 0U;
        char line[32];
        setup();
        Serial1_begin(9600U);
        if (false == SD_Begin(GPIO4))
        {
            Serial1_println("SD initialization failed.");
            while (1)
            {
            }
        }
        if (false == SD_Open(&file, "data.csv", SD_FILE_WRITE))
        {
            Serial1_println("File open failed.");
            while (1)
            {
            }
        }
        SD_WriteLine(&file, "sample,adc_value");
        for (sample = 1U; sample <= 10U; sample++)
        {
            adcValue = analogRead(ADC0_SE12);
            snprintf(
                line,
                sizeof(line),
                "%u,%d",
                (unsigned int)sample,
                adcValue);
            SD_WriteLine(&file, line);
            Serial1_print("Sample ");
            Serial1_printInt(sample);
            Serial1_print(" | ADC: ");
            Serial1_printlnInt(adcValue);
            delay(1000U);
        }
        SD_Close(&file);
        SD_End();
        Serial1_println("Logging complete.");
        while (1)
        {
        }
        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo các thành phần nền tảng của EduFramework và
`Serial1_begin(9600U)` chuẩn bị Serial Monitor. `SD_Begin(GPIO4)` sau đó khởi tạo
SD Card và mount filesystem. Nếu khởi tạo thất bại, chương trình dừng tại vòng
lặp lỗi để không tiếp tục thao tác với thiết bị lưu trữ chưa sẵn sàng
#cite-ref(refs, "eduframework-sd").

`SD_Open()` tạo `data.csv` với `SD_FILE_WRITE`. Dòng đầu tiên được ghi bằng
`SD_WriteLine()` để mô tả hai giá trị được lưu trong mỗi mẫu. Trong vòng `for`,
`analogRead(ADC0_SE12)` lấy giá trị ADC thô của biến trở. `snprintf()` tạo một
chuỗi gồm số thứ tự mẫu và giá trị ADC; chuỗi này được ghi xuống file bằng
`SD_WriteLine()`.

Mỗi lần lấy mẫu cách nhau `1000 ms`. Sau mười mẫu, `SD_Close()` đóng file và
`SD_End()` kết thúc phiên sử dụng SD Card. Chương trình chỉ in
`Logging complete.` sau hai thao tác này, vì vậy thông báo được dùng làm mốc để
biết quá trình ghi của bài thực hành đã kết thúc.

Luồng dữ liệu của ứng dụng:

`Potentiometer` → `analogRead()` → `ADC value` → `SD_WriteLine()` → `SD Card`.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board, sau đó mở Serial
Monitor với baud rate `9600`. Trong khoảng mười giây lấy mẫu, xoay biến trở để
tạo các mức điện áp khác nhau tại `ADC0_SE12`.

Serial Monitor cần hiển thị mười mẫu và kết thúc bằng thông báo:

```text
Sample 1 | ADC: 4095
Sample 2 | ADC: 4095
Sample 3 | ADC: 1958
...
Sample 10 | ADC: 2868
Logging complete.
```

Sau khi xuất hiện `Logging complete.`, tháo SD Card và mở `data.csv` trên máy
tính. Một kết quả đã được kiểm chứng trên phần cứng có dạng:

```text
sample,adc_value
1,4095
2,4095
3,1958
4,1287
5,748
6,0
7,0
8,766
9,1654
10,2868
```

Giá trị ADC cụ thể phụ thuộc vào vị trí biến trở. Mục tiêu kiểm chứng không phải
đạt đúng các con số trên mà là file được tạo thành công, có đủ mười mẫu và giá
trị thay đổi khi vị trí biến trở thay đổi.

#block(breakable: false)[
  #expected-result[
    SD Card được khởi tạo thành công và file `data.csv` được tạo. Chương trình
    ghi đủ mười mẫu ADC với khoảng lấy mẫu `1000 ms`, sau đó đóng file và kết
    thúc SD Device. Dữ liệu trong file phải tương ứng với các mẫu đã hiển thị
    trên Serial Monitor và thay đổi theo vị trí của biến trở.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính sử dụng `SD_FILE_WRITE` để mỗi lần chạy tạo một bộ dữ liệu
mới. SD Card Device còn cung cấp các API để nối thêm dữ liệu, đọc file, đồng bộ
dữ liệu và truy vấn thông tin lưu trữ #cite-ref(refs, "eduframework-sd").

#info-table(
  columns: (1.5fr, 2.8fr),
  alignments: (
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API / Mode],
    [Mục đích],
  ),
  rows: (
    (
      [`SD_FILE_APPEND`],
      [Mở file để ghi tiếp vào cuối; file được tạo nếu chưa tồn tại.],
    ),
    (
      [`SD_Flush()`],
      [Đồng bộ dữ liệu đang chờ của file xuống thiết bị lưu trữ mà không đóng file.],
    ),
    (
      [`SD_Read()`],
      [Đọc một số byte từ file đang mở vào buffer của application.],
    ),
    (
      [`SD_Exists()`],
      [Kiểm tra file hoặc thư mục theo đường dẫn có tồn tại hay không.],
    ),
    (
      [`SD_GetCapacity()`],
      [Đọc tổng dung lượng và dung lượng trống của filesystem.],
    ),
  ),
  caption: [Một số chức năng mở rộng của SD Card Device],
)

Chế độ `SD_FILE_APPEND` khác với `SD_FILE_WRITE`: dữ liệu mới được ghi ở cuối file
thay vì thay thế nội dung cũ. Trong EduFramework, hai mode này lần lượt được ánh
xạ tới `FA_OPEN_APPEND | FA_WRITE` và `FA_CREATE_ALWAYS | FA_WRITE` của FatFs
#cite-ref(refs, "fatfs") #cite-ref(refs, "eduframework-sd").

#note[
  `SD_Flush()` hữu ích khi một file cần được giữ mở trong thời gian dài nhưng ứng
  dụng muốn đồng bộ dữ liệu đã ghi xuống storage. Hàm này không thay thế việc
  `SD_Close()` khi phiên truy cập file thực sự kết thúc.
]

== Bài tập mở rộng

Thay `SD_FILE_WRITE` bằng `SD_FILE_APPEND` và điều chỉnh chương trình để mỗi lần
reset board, mười mẫu mới được thêm vào cuối file thay vì xóa dữ liệu của lần chạy
trước. Sau ít nhất hai lần chạy, kiểm tra file trên máy tính và xác nhận dữ liệu
của cả hai phiên vẫn được giữ lại.

Một hướng mở rộng khác là thay potentiometer bằng nguồn dữ liệu đã sử dụng ở các
bài lab trước, chẳng hạn nhiệt độ từ NTC hoặc dữ liệu chuyển động từ MPU6050. Khi
đó, cấu trúc lưu trữ của Lab 17 có thể được tái sử dụng mà không cần thay đổi cơ
chế quản lý SD Card.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
