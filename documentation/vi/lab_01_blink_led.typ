#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 01 - Cơ bản về Digital Output
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "arduino-digital-pins",
    type: "web",
    author: [Arduino],
    title: [Digital Pins],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/learn/microcontrollers/digital-pins/",
  ),

  (
    key: "arduino-language-reference",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
  ),

  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https://www.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
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
  number: 1,
  language: "vi",
  title: [Cơ bản về Digital Output],
  subtitle: [Điều khiển GPIO với EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Digital Input/Output (Digital I/O) là một chức năng cơ bản của GPIO, cho phép
vi điều khiển trao đổi các trạng thái logic với phần cứng bên ngoài. Khi một
chân GPIO được cấu hình làm đầu ra, chương trình có thể thiết lập trạng thái
logic của chân để tạo tín hiệu số #cite-ref(refs, "arduino-digital-pins").

Bài lab này được thiết kế để giới thiệu Digital Output thông qua các API của
EduFramework. LED tích hợp trên MaaZEDU Development Board được sử dụng làm đầu
ra trực quan. Bằng cách luân phiên hai mức logic `HIGH` và `LOW` theo thời gian,
chương trình tạo thành ứng dụng nháy LED cơ bản.


== Mục tiêu

#objectives(
  items: (
    [
      Giải thích nguyên lý cơ bản của Digital Output và ý nghĩa của hai mức
      logic `HIGH`, `LOW`.
    ],

    [
      Xác định mối quan hệ giữa mức logic của GPIO và trạng thái của LED
      active-low.
    ],

    [
      Sử dụng các API `pinMode()`, `digitalWrite()` và `delay()` để điều khiển
      Digital Output.
    ],

    [
      Xây dựng và kiểm chứng ứng dụng nháy LED trên MaaZEDU Development Board.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Digital Output và mức logic

GPIO (General-Purpose Input/Output) là các chân có thể được cấu hình để thực
hiện chức năng vào hoặc ra số. Khi được cấu hình ở chế độ Digital Output,
trạng thái logic tại chân được điều khiển bởi chương trình. Trong EduFramework,
chế độ đầu ra được biểu diễn bằng `OUTPUT`, trong khi hai trạng thái logic được
biểu diễn bằng `HIGH` và `LOW`.

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1fr, 2.6fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Trạng thái*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Giá trị*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Ý nghĩa*]
      ],
    ),

    [`LOW`], [`0U`], [Mức logic thấp.],
    [`HIGH`], [`1U`], [Mức logic cao.],
  )
]

`HIGH` và `LOW` biểu diễn trạng thái logic, không phải một giá trị điện áp cố
định. Điện áp thực tế và các giới hạn điện của chân I/O phụ thuộc vào đặc tính
của vi điều khiển. Đối với S32K1xx, các thông số này được quy định trong Data
Sheet của NXP #cite-ref(refs, "nxp-s32k-datasheet").


== Digital Output và LED active-low

LED thường được sử dụng để biểu diễn trực quan trạng thái của một đầu ra số.
Tuy nhiên, quan hệ giữa mức logic của GPIO và trạng thái sáng hoặc tắt của LED
phụ thuộc vào cách LED được kết nối trong mạch.

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.2fr, 1.4fr, 1.4fr),
    align: (center + horizon, center + horizon, center + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Cấu hình*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*LED bật*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*LED tắt*]
      ],
    ),

    [Active-high], [`HIGH`], [`LOW`],
    [Active-low], [`LOW`], [`HIGH`],
  )
]

Các LED tích hợp được sử dụng trong cấu hình phần cứng của bài lab hoạt động
theo nguyên lý active-low. Vì vậy, mức `LOW` làm LED sáng, trong khi mức `HIGH`
làm LED tắt.

#note[
  `HIGH` và `LOW` mô tả trạng thái logic của GPIO; bật và tắt mô tả trạng thái
  của thiết bị được kết nối. Quan hệ giữa hai trạng thái này được quyết định
  bởi cấu hình phần cứng.
]


== Chu kỳ nháy LED

Ứng dụng nháy LED thay đổi tuần hoàn trạng thái của LED. Trong bài lab này,
LED được giữ ở trạng thái sáng trong `500 ms` và trạng thái tắt trong `500 ms`.
Do đó, thời gian của một chu kỳ hoàn chỉnh là:

$ T = 500 " ms" + 500 " ms" = 1000 " ms" = 1 " s" $

#figure-block(
  caption: [Quan hệ thời gian của ứng dụng nháy LED],
)[
  #image(
    "../assets/images/blink_timing_diagram.png",
    width: 100%,
  )
]

Khoảng thời gian giữa các lần thay đổi trạng thái được tạo bằng `delay()`, giúp
hai trạng thái của LED có thể được quan sát trực tiếp trên phần cứng.


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng trực tiếp LED tích hợp trên MaaZEDU Development Board và không
yêu cầu đấu nối thêm linh kiện bên ngoài.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],

  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),

    (
      [USB Cable],
      [Kết nối board với máy tính để cấp nguồn và nạp chương trình.],
    ),
  ),
)


== Ánh xạ LED tích hợp

EduFramework cung cấp các Logical Pin để truy cập LED tích hợp trong mã nguồn
ứng dụng. Ánh xạ phần cứng được sử dụng trong framework như sau:

#pin-table(
  caption: [Ánh xạ các LED tích hợp trên MaaZEDU Development Board],

  rows: (
    (
      [LED đỏ],
      "LED_RED",
      "PTD15",
      [Digital Output],
    ),

    (
      [LED xanh dương],
      "LED_BLUE",
      "PTD16",
      [Digital Output],
    ),

    (
      [LED xanh lá],
      "LED_GREEN",
      "PTD0",
      [Digital Output],
    ),
  ),
)

Bài thực hành chính sử dụng `LED_RED`, được EduFramework ánh xạ tới chân
`PTD15` của S32K144.


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Ứng dụng nháy LED sử dụng ba API: `pinMode()` để cấu hình Digital Output,
`digitalWrite()` để thiết lập mức logic và `delay()` để tạo khoảng thời gian
giữa các lần thay đổi trạng thái. Cách tổ chức các API này được xây dựng theo
mô hình lập trình quen thuộc của Arduino
#cite-ref(refs, "arduino-language-reference").


== `pinMode()`

`pinMode()` được sử dụng để cấu hình chế độ hoạt động của một chân digital.

#api-detail(
  name: "pinMode",

  syntax: [pinMode(pin, mode);],

  description: [
    Cấu hình chế độ hoạt động cho Logical Pin được chỉ định.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân cần cấu hình, ví dụ `LED_RED`.],
    ),

    (
      [mode],
      [`OUTPUT`],
      [Cấu hình chân làm Digital Output.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
pinMode(LED_RED, OUTPUT);
```


== `digitalWrite()`

`digitalWrite()` được sử dụng để thiết lập mức logic của một chân Digital
Output.

#api-detail(
  name: "digitalWrite",

  syntax: [digitalWrite(pin, value);],

  description: [
    Thiết lập mức logic cho Logical Pin được chỉ định.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân cần điều khiển, ví dụ `LED_RED`.],
    ),

    (
      [value],
      [`HIGH` / `LOW`],
      [Mức logic cần thiết lập cho chân output.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
digitalWrite(LED_RED, LOW);
digitalWrite(LED_RED, HIGH);
```


== `delay()`

`delay()` tạo khoảng thời gian chờ trước khi chương trình tiếp tục thực hiện
lệnh tiếp theo.

#api-detail(
  name: "delay",

  syntax: [delay(ms);],

  description: [
    Tạo khoảng thời gian chờ theo đơn vị millisecond.
  ],

  parameters: (
    (
      [ms],
      [Thời gian],
      [Khoảng thời gian cần chờ, tính bằng millisecond.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
delay(500U);
```

Lệnh trên tạo khoảng thời gian chờ `500 ms`.


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

Tạo một project PlatformIO sử dụng EduFramework cho MaaZEDU Development Board.


== Yêu cầu

Xây dựng chương trình điều khiển LED đỏ tích hợp nhấp nháy liên tục. LED sáng
trong `500 ms`, sau đó tắt trong `500 ms` và quá trình được lặp lại liên tục.


== Chương trình

Trong `src/main.c`, triển khai chương trình như sau:

#code-listing(
  caption: [Chương trình nháy LED sử dụng EduFramework],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      setup();

      pinMode(LED_RED, OUTPUT);

      while (1)
      {
          digitalWrite(LED_RED, LOW);
          delay(500U);

          digitalWrite(LED_RED, HIGH);
          delay(500U);
      }

      return 0;
  }
  ```
]

`setup()` khởi tạo EduFramework trước khi các API được sử dụng. Sau đó,
`pinMode()` cấu hình `LED_RED` thành Digital Output. Trong vòng lặp `while (1)`,
`digitalWrite()` lần lượt thiết lập `LOW` và `HIGH`; mỗi trạng thái được duy trì
trong `500 ms` bằng `delay()`.

Do LED hoạt động theo cấu hình active-low, `LOW` tương ứng với trạng thái sáng
và `HIGH` tương ứng với trạng thái tắt.


== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board, sau đó quan sát LED
đỏ tích hợp.

#expected-result[
  LED đỏ sáng khoảng `500 ms`, tắt khoảng `500 ms` và lặp lại liên tục. Một
  chu kỳ nhấp nháy hoàn chỉnh kéo dài khoảng `1 s`.
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Ngoài các API cơ bản được sử dụng trong bài thực hành, EduFramework còn cung
cấp các API bổ sung và nâng cao phục vụ nhiều kiểu bài toán khác nhau. Trong
phần mở rộng này, `digitalToggle()` được sử dụng để thực hiện thao tác đảo trạng
thái Digital Output, trong khi `millis()` được sử dụng để theo dõi thời gian
thực thi mà không cần tạo khoảng chờ bằng `delay()`.


== Đảo trạng thái với `digitalToggle()`

`digitalToggle()` đảo mức logic hiện tại của một Digital Output. Nếu trạng thái
hiện tại là `LOW`, chân được chuyển sang `HIGH`; ngược lại, nếu trạng thái hiện
tại là `HIGH`, chân được chuyển sang `LOW`.

#api-detail(
  name: "digitalToggle",

  syntax: [digitalToggle(pin);],

  description: [
    Đảo trạng thái logic hiện tại của Logical Pin được chỉ định.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân Digital Output cần đảo trạng thái.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

*Mở rộng:* Viết lại chương trình nháy LED bằng `digitalToggle()` sao cho trạng
thái LED vẫn được thay đổi sau mỗi `500 ms`.


== Định thời với `millis()`

`delay()` tạo một khoảng chờ và giữ luồng thực thi cho đến khi khoảng thời gian
yêu cầu kết thúc. Trong các ứng dụng cần tiếp tục xử lý những tác vụ khác trong
khi theo dõi thời gian, `millis()` có thể được sử dụng để xác định thời gian đã
trôi qua mà không cần dừng vòng lặp chính.

#api-detail(
  name: "millis",

  syntax: [millis();],

  description: [
    Đọc số millisecond đã trôi qua kể từ khi hệ thống thời gian được khởi tạo.
  ],

  parameters: (),

  returns: [
    Thời gian đã trôi qua, tính bằng millisecond.
  ],
)

Một khoảng thời gian có thể được kiểm tra theo nguyên tắc:

#code-listing(
  caption: [Kiểm tra khoảng thời gian bằng `millis()`],
)[
  ```c
  if ((millis() - previousTime) >= interval)
  {
      /* Periodic operation */
  }
  ```
]

Trong đó, `previousTime` lưu mốc thời gian của lần xử lý trước và `interval`
xác định khoảng thời gian giữa hai lần xử lý.

*Mở rộng:* Viết lại ứng dụng nháy LED với khoảng đảo trạng thái `500 ms` mà
không sử dụng `delay()`. Khi đủ thời gian, sử dụng `digitalToggle()` để thay đổi
trạng thái LED và cập nhật lại mốc thời gian.


== Bài tập mở rộng

Xây dựng chương trình điều khiển đồng thời ba LED tích hợp với các khoảng đảo
trạng thái độc lập:

- `LED_RED`: `500 ms`.
- `LED_BLUE`: `1000 ms`.
- `LED_GREEN`: `1500 ms`.

Không sử dụng `delay()` trong vòng lặp chính. Mỗi LED cần sử dụng một mốc thời
gian riêng để quá trình định thời của một LED không làm dừng việc xử lý các LED
còn lại.

#expected-result[
  Ba LED nhấp nháy đồng thời theo các khoảng thời gian tương ứng và hoạt động
  độc lập về mặt định thời.
]


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
