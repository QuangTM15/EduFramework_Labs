#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 03 - Cơ bản về Serial Monitor
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "ut-serial",
    type: "web",
    author: [Jonathan Valvano and Ramesh Yerraballi],
    title: [Chapter 9: Serial Communication],
    source: [Introduction to Embedded Systems - The University of Texas at Austin],
    url: "https://users.ece.utexas.edu/~valvano/Volume1/IntroToEmbSys/Ch9_SerialCommunication.htm",
  ),
  (
    key: "uf-uart",
    type: "web",
    author: [University of Florida],
    title: [Lab 5: Asynchronous Serial Communication],
    source: [EEL4744C - Electrical & Computer Engineering Department],
    url: "https://mil.ufl.edu/4744/labs/lab5_f24_asynchronous_serial_communication.pdf",
  ),
  (
    key: "arduino-serial",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
  ),
  (
    key: "eduframework-serial",
    type: "web",
    author: [EduFramework],
    title: [Hardware Serial API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
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
  number: 3,
  language: "vi",
  title: [Cơ bản về Serial Monitor],
  subtitle: [Giám sát trạng thái hệ thống với EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Trong quá trình phát triển hệ thống nhúng, việc quan sát trạng thái bên trong
chương trình là cần thiết để kiểm chứng hoạt động của phần mềm và theo dõi dữ
liệu trong thời gian chạy. Một phương pháp phổ biến là truyền thông tin từ vi
điều khiển tới máy tính thông qua giao tiếp nối tiếp và hiển thị dữ liệu trên
Serial Monitor.

UART (Universal Asynchronous Receiver/Transmitter) là một cơ chế truyền thông
nối tiếp bất đồng bộ thường được tích hợp trong vi điều khiển. Dữ liệu được
truyền tuần tự theo từng bit giữa các thiết bị và không yêu cầu một đường clock
chung cho quá trình truyền nhận
#cite-ref(refs, "ut-serial").

Bài lab này được thiết kế để giới thiệu Serial Monitor thông qua giao diện
`Serial1` của EduFramework. Trạng thái của nút nhấn tích hợp được truyền tới máy
tính để quan sát trực tiếp trên Serial Monitor. Qua đó, Serial Monitor trở thành
một công cụ cơ bản có thể được tái sử dụng trong các bài lab tiếp theo để quan
sát giá trị cảm biến, trạng thái hệ thống và kết quả xử lý.

== Mục tiêu

#objectives(
  items: (
    [
      Giải thích nguyên lý cơ bản của truyền thông nối tiếp bất đồng bộ và vai
      trò của UART trong việc truyền dữ liệu.
    ],
    [
      Mô tả vai trò của TX, RX, baud rate và cấu trúc cơ bản của một UART frame.
    ],
    [
      Sử dụng các API `Serial1_begin()`, `Serial1_print()` và
      `Serial1_println()` để truyền dữ liệu tới Serial Monitor.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng giám sát sự kiện nút nhấn trên Serial
      Monitor.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Truyền thông nối tiếp và Serial Monitor

Trong truyền thông nối tiếp, dữ liệu được truyền tuần tự theo từng bit thay vì
truyền đồng thời nhiều bit trên nhiều đường tín hiệu. Phương pháp này được sử
dụng rộng rãi trong hệ thống nhúng để trao đổi dữ liệu giữa vi điều khiển và
các thiết bị khác #cite-ref(refs, "ut-serial").

Serial Monitor là một công cụ hiển thị dữ liệu được truyền qua cổng serial.
Trong bài lab này, Serial Monitor được sử dụng như một kênh quan sát từ
MaaZEDU Development Board tới máy tính. Chương trình có thể gửi các chuỗi ký tự
mô tả trạng thái hoặc sự kiện để hỗ trợ quá trình kiểm chứng hoạt động.

== UART và truyền thông bất đồng bộ

UART thực hiện truyền thông nối tiếp bất đồng bộ. Khác với giao tiếp đồng bộ,
hai phía không sử dụng một đường clock chung để xác định thời điểm truyền và
nhận dữ liệu. Thay vào đó, các thiết bị cần thống nhất các tham số truyền thông,
đặc biệt là tốc độ truyền #cite-ref(refs, "uf-uart").

Một giao tiếp UART thông thường sử dụng hai hướng tín hiệu:

#info-table(
  columns: (1fr, 1.3fr, 2.7fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Tín hiệu],
    [Tên],
    [Chức năng],
  ),
  rows: (
    (
      [`TX`],
      [Transmit],
      [Truyền dữ liệu từ thiết bị hiện tại tới thiết bị nhận.],
    ),
    (
      [`RX`],
      [Receive],
      [Nhận dữ liệu được truyền từ thiết bị khác.],
    ),
  ),
  caption: [Hai hướng tín hiệu cơ bản của UART],
)

Bài lab chỉ sử dụng hướng truyền dữ liệu từ S32K144 tới máy tính. Vì vậy, nội
dung chính tập trung vào quá trình xuất dữ liệu qua `Serial1`; chức năng nhận dữ
liệu sẽ được giới thiệu trong một bài lab sau.

== Baud rate

Baud rate biểu thị tốc độ ký hiệu của giao tiếp. Trong UART nhị phân thông
thường, mỗi ký hiệu tương ứng với một bit; vì vậy baud rate xác định khoảng thời
gian truyền của từng bit. Hai phía giao tiếp cần sử dụng cấu hình tương thích để
dữ liệu được diễn giải chính xác #cite-ref(refs, "ut-serial").

Ví dụ, khi chương trình khởi tạo:

```c
Serial1_begin(9600U);
```

giao diện `Serial1` được cấu hình hoạt động với baud rate `9600`. Serial Monitor
trên máy tính cũng cần sử dụng cùng baud rate.

#note[
  Với cấu hình clock mặc định hiện tại của EduFramework, giao tiếp Serial nên
  được sử dụng ở các baud rate thấp để bảo đảm hoạt động ổn định. Trong series
  bài lab này, `9600 baud` được khuyến nghị và được sử dụng làm cấu hình mặc
  định cho Serial Monitor.

  Đây là giới hạn liên quan tới cấu hình hiện tại của framework, không phải giới
  hạn chung của peripheral LPUART trên S32K144.
]

== Cấu trúc cơ bản của UART frame

Do UART không sử dụng một đường clock chung, dữ liệu cần được tổ chức theo một
frame để phía nhận có thể xác định thời điểm bắt đầu và kết thúc của dữ liệu. Một
UART frame cơ bản gồm start bit, các data bit và stop bit; parity có thể được
bổ sung tùy theo cấu hình #cite-ref(refs, "uf-uart").

Một cấu hình phổ biến là `8N1`, gồm:

#info-table(
  columns: (1.3fr, 2.7fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Thành phần],
    [Ý nghĩa],
  ),
  rows: (
    (
      [1 Start bit],
      [Đánh dấu thời điểm bắt đầu một frame dữ liệu.],
    ),
    (
      [8 Data bits],
      [Chứa tám bit dữ liệu cần truyền.],
    ),
    (
      [No parity],
      [Không sử dụng bit parity.],
    ),
    (
      [1 Stop bit],
      [Đánh dấu kết thúc frame trước khi dữ liệu tiếp theo được truyền.],
    ),
  ),
  caption: [Cấu trúc khái quát của cấu hình UART 8N1],
)


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng nút nhấn tích hợp trên MaaZEDU Development Board và Serial
Monitor của PlatformIO, do đó không yêu cầu lắp thêm linh kiện hoặc mạch ngoài.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
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

== Giao diện sử dụng

Nút nhấn `BTN0` được sử dụng để tạo sự kiện cần giám sát. EduFramework ánh xạ
`BTN0` tới chân `PTC12` của S32K144
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Ánh xạ Digital Input sử dụng trong bài thực hành],
  rows: (
    (
      [Nút nhấn tích hợp],
      "BTN0",
      "PTC12",
      [Digital Input],
    ),
  ),
)

Đối với dữ liệu Serial, EduFramework sử dụng `Serial1` cho Serial Monitor và
thông tin debug thông qua giao diện debug của board. `Serial1` được ánh xạ tới
khối ngoại vi `LPUART1` #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.2fr, 1.4fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Giao diện],
    [Khối ngoại vi],
    [Vai trò trong bài lab],
  ),
  rows: (
    (
      [`Serial1`],
      [`LPUART1`],
      [Truyền dữ liệu từ S32K144 tới Serial Monitor trên máy tính.],
    ),
  ),
  caption: [Giao diện Serial sử dụng trong bài thực hành],
)

Luồng dữ liệu trong bài lab có thể được mô tả theo thứ tự:

`BTN0` → chương trình trên S32K144 → `Serial1` → Serial Monitor.


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài lab sử dụng ba API cơ bản của `Serial1`: `Serial1_begin()` để khởi tạo giao
tiếp, `Serial1_print()` để truyền một chuỗi ký tự và `Serial1_println()` để truyền
chuỗi ký tự kèm thao tác kết thúc dòng. Các API thuộc lớp Arduino-style API của
EduFramework #cite-ref(refs, "eduframework-serial").

== `Serial1_begin()`

`Serial1_begin()` khởi tạo giao diện `Serial1` với baud rate được chỉ định.

#api-detail(
  name: "Serial1_begin",
  syntax: [Serial1_begin(baudRate);],
  description: [
    Khởi tạo `Serial1` để truyền và nhận dữ liệu với baud rate được chỉ định.
  ],
  parameters: (
    (
      [baudRate],
      [Baud rate],
      [Tốc độ truyền cần sử dụng cho giao tiếp Serial.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
Serial1_begin(9600U);
```

Trong series bài lab này, `9600 baud` được sử dụng cho Serial Monitor theo cấu
hình EduFramework hiện tại.

== `Serial1_print()`

`Serial1_print()` truyền một chuỗi ký tự qua `Serial1` mà không tự động kết thúc
dòng.

#api-detail(
  name: "Serial1_print",
  syntax: [Serial1_print(text);],
  description: [
    Truyền chuỗi ký tự được chỉ định qua `Serial1`.
  ],
  parameters: (
    (
      [text],
      [Chuỗi ký tự],
      [Nội dung cần truyền tới Serial Monitor.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
Serial1_print("System status: ");
```

Dữ liệu được truyền tiếp theo sẽ tiếp tục xuất hiện trên cùng dòng cho đến khi
một thao tác kết thúc dòng được thực hiện.

== `Serial1_println()`

`Serial1_println()` truyền một chuỗi ký tự qua `Serial1` và tự động kết thúc dòng
sau chuỗi được truyền #cite-ref(refs, "eduframework-serial").

#api-detail(
  name: "Serial1_println",
  syntax: [Serial1_println(text);],
  description: [
    Truyền chuỗi ký tự được chỉ định qua `Serial1` và kết thúc dòng.
  ],
  parameters: (
    (
      [text],
      [Chuỗi ký tự],
      [Nội dung cần truyền tới Serial Monitor.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
Serial1_println("System started.");
```

Khác với `Serial1_print()`, dữ liệu được truyền bằng `Serial1_println()` kết thúc
tại dòng hiện tại và nội dung tiếp theo được hiển thị trên dòng mới. Cách tổ
chức `print()` và `println()` tương ứng cũng được sử dụng trong mô hình Serial
của Arduino #cite-ref(refs, "arduino-serial").


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình sử dụng `BTN0` làm nguồn tạo sự kiện và hiển thị trạng
thái nút nhấn trên Serial Monitor. Chương trình cần đáp ứng các yêu cầu sau:

- Khởi tạo `Serial1` với baud rate `9600`.
- Hiển thị thông báo khi hệ thống bắt đầu hoạt động.
- Khi `BTN0` được nhấn, Serial Monitor hiển thị thông báo tương ứng đúng một lần.
- Khi `BTN0` được thả, Serial Monitor hiển thị thông báo tương ứng đúng một lần.
- Giữ nút không làm cùng một thông báo được in liên tục.

== Chương trình

Trong `src/main.c`, triển khai chương trình như sau:

#code-listing(
  caption: [Chương trình giám sát sự kiện nút nhấn bằng Serial Monitor],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      bool pressed = false;

      setup();

      pinMode(BTN0, INPUT);

      Serial1_begin(9600U);

      Serial1_print("EduFramework ");
      Serial1_println("Serial Monitor");
      Serial1_println("System started.");

      while (1)
      {
          if ((HIGH == digitalRead(BTN0)) && (false == pressed))
          {
              Serial1_println("BTN0 pressed.");
              pressed = true;
          }

          if ((LOW == digitalRead(BTN0)) && (true == pressed))
          {
              Serial1_println("BTN0 released.");
              pressed = false;
          }
      }

      return 0;
  }
  ```
]

Sau khi `setup()` khởi tạo EduFramework, `BTN0` được cấu hình làm Digital Input
và `Serial1_begin(9600U)` khởi tạo giao tiếp Serial với baud rate `9600`.

Hai API `Serial1_print()` và `Serial1_println()` được sử dụng để hiển thị thông
tin khởi động. Trong vòng lặp chính, biến `pressed` ghi nhận trạng thái xử lý của
nút nhấn. Cơ chế này kế thừa nguyên tắc phát hiện sự kiện đã sử dụng trong Lab
02, nhưng thay vì điều khiển một Digital Output, sự kiện được chuyển thành
thông tin quan sát trên Serial Monitor.

Khi `BTN0` chuyển sang trạng thái nhấn, thông báo `BTN0 pressed.` được truyền một
lần. Khi nút được thả, chương trình truyền `BTN0 released.` và sẵn sàng xử lý
lần nhấn tiếp theo.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Sau đó mở Serial
Monitor và cấu hình baud rate `9600`.

Quan sát nội dung hiển thị khi chương trình bắt đầu, sau đó lần lượt nhấn, giữ
và thả `BTN0`.

#expected-result[
  Serial Monitor hiển thị thông tin khởi động của hệ thống. Mỗi lần `BTN0`
  được nhấn, thông báo `BTN0 pressed.` xuất hiện đúng một lần; khi nút được thả,
  thông báo `BTN0 released.` xuất hiện đúng một lần. Việc giữ nút không làm
  cùng một thông báo được lặp lại liên tục.
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Các API cơ bản trong bài thực hành tập trung vào việc truyền chuỗi ký tự. Trong
các ứng dụng đo lường và giám sát, dữ liệu cần quan sát thường còn bao gồm các
giá trị số như số lần xảy ra sự kiện, giá trị ADC hoặc kết quả tính toán từ cảm
biến. EduFramework cung cấp thêm các API hỗ trợ trực tiếp việc in số nguyên và
số thực qua `Serial1` #cite-ref(refs, "eduframework-serial").

== In giá trị số nguyên

`Serial1_printInt()` truyền một giá trị số nguyên có dấu qua `Serial1`, trong khi
`Serial1_printlnInt()` thực hiện cùng thao tác và kết thúc dòng sau giá trị.

#info-table(
  columns: (1.5fr, 1.5fr, 2.4fr),
  alignments: (
    left + horizon,
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Cú pháp],
    [Chức năng],
  ),
  rows: (
    (
      [`Serial1_printInt()`],
      [`Serial1_printInt(value);`],
      [In một giá trị số nguyên mà không tự động chuyển dòng.],
    ),
    (
      [`Serial1_printlnInt()`],
      [`Serial1_printlnInt(value);`],
      [In một giá trị số nguyên và kết thúc dòng.],
    ),
  ),
  caption: [API xuất giá trị số nguyên qua Serial1],
)

Ví dụ:

```c
Serial1_print("Value: ");
Serial1_printlnInt(value);
```

Cách tách phần mô tả bằng chuỗi ký tự và phần dữ liệu số giúp thông tin trên
Serial Monitor dễ đọc hơn.

== In giá trị số thực

Đối với dữ liệu dạng số thực, EduFramework cung cấp `Serial1_printFloat()` và
`Serial1_printlnFloat()`. Trong phiên bản hiện tại của EduFramework, giá trị số thực được hiển thị
với ba chữ số sau dấu thập phân #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.5fr, 1.5fr, 2.4fr),
  alignments: (
    left + horizon,
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Cú pháp],
    [Chức năng],
  ),
  rows: (
    (
      [`Serial1_printFloat()`],
      [`Serial1_printFloat(value);`],
      [In một giá trị số thực mà không tự động chuyển dòng.],
    ),
    (
      [`Serial1_printlnFloat()`],
      [`Serial1_printlnFloat(value);`],
      [In một giá trị số thực và kết thúc dòng.],
    ),
  ),
  caption: [API xuất giá trị số thực qua Serial1],
)

Ví dụ:

```c
Serial1_print("Temperature: ");
Serial1_printFloat(temperature);
Serial1_println(" C");
```

Các API này sẽ được tái sử dụng trong các bài lab liên quan tới ADC và cảm biến,
khi giá trị đo cần được quan sát trực tiếp trên Serial Monitor.

== Bài tập mở rộng: đếm số lần nhấn nút

Mở rộng chương trình chính để theo dõi tổng số lần `BTN0` được nhấn kể từ khi hệ
thống khởi động. Mỗi sự kiện nhấn hợp lệ chỉ được tăng bộ đếm một lần.

Sau mỗi lần nhấn, Serial Monitor cần hiển thị kết quả theo dạng:

```text
BTN0 pressed. Count: 1
BTN0 pressed. Count: 2
BTN0 pressed. Count: 3
```

Sử dụng `Serial1_print()` kết hợp với API xuất số nguyên phù hợp để tạo một dòng
thông tin gồm cả chuỗi ký tự và giá trị bộ đếm.

Không thay đổi yêu cầu phát hiện sự kiện của chương trình chính: việc giữ nút
không được làm bộ đếm tăng liên tục.

#expected-result[
  Mỗi lần `BTN0` được nhấn và được nhận diện như một sự kiện mới, giá trị bộ đếm
  tăng thêm một. Serial Monitor hiển thị số lần nhấn tích lũy theo đúng thứ tự
  sự kiện.
]

== `Serial1` và `Serial2`

EduFramework cung cấp hai giao diện Serial phần cứng với mục đích sử dụng khác
nhau #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.1fr, 1.3fr, 2.8fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Giao diện],
    [Khối ngoại vi],
    [Mục đích sử dụng],
  ),
  rows: (
    (
      [`Serial1`],
      [`LPUART1`],
      [
        Serial Monitor và thông tin debug thông qua giao diện debug của board.
      ],
    ),
    (
      [`Serial2`],
      [`LPUART2`],
      [
        Giao tiếp UART với thiết bị hoặc module bên ngoài thông qua các chân
        UART tương ứng.
      ],
    ),
  ),
  caption: [Vai trò của Serial1 và Serial2 trong EduFramework],
)

Trong các bài lab cần quan sát dữ liệu trên máy tính, `Serial1` được ưu tiên sử
dụng làm kênh giám sát. `Serial2` được dành cho các ứng dụng cần trao đổi dữ
liệu với thiết bị UART bên ngoài. Nội dung nhận dữ liệu và xử lý lệnh qua UART
sẽ được giới thiệu trong một bài lab sau.


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
