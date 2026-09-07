#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 02 - Cơ bản về Digital Input
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "arduino-digitalread",
    type: "web",
    author: [Arduino],
    title: [digitalRead()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/digital-io/digitalread/",
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

  (
    key: "uw-gpio",
    type: "web",
    author: [University of Wisconsin-Madison],
    title: [GPIO Pins],
    source: [ECE353 - Introduction to Microprocessor Systems],
    url: "https://ece353.engr.wisc.edu/gpio-pins/gpio-pins/",
  ),

  (
    key: "ti-debounce",
    type: "application-note",
    author: [Texas Instruments],
    title: [Debounce a Switch],
    document: [SCEA094],
    url: "https://www.ti.com/document-viewer/lit/html/scea094",
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 2,
  language: "vi",
  title: [Cơ bản về Digital Input],
  subtitle: [Đọc nút nhấn và điều khiển GPIO với EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Digital Input cho phép vi điều khiển nhận trạng thái logic từ các tín hiệu bên
ngoài thông qua GPIO. Khi một chân được cấu hình làm đầu vào số, chương trình
có thể đọc trạng thái tại chân và sử dụng kết quả đó để thực hiện các hành vi
điều khiển tương ứng.

Bài lab này được thiết kế để giới thiệu Digital Input thông qua một nút nhấn và
các API của EduFramework. Trạng thái của nút nhấn được sử dụng để điều khiển một
LED ngoài kết nối với GPIO.


== Mục tiêu

#objectives(
  items: (
    [
      Giải thích nguyên lý cơ bản của Digital Input và các trạng thái logic.
    ],
    [
      Sử dụng EduFramework để cấu hình và đọc trạng thái của nút nhấn thông
      qua GPIO.
    ],
    [
      Kết nối và điều khiển LED ngoài bằng GPIO.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng sử dụng nút nhấn để thay đổi trạng thái
      của LED.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Digital Input và mức logic

GPIO (General-Purpose Input/Output) có thể được cấu hình làm đầu vào hoặc đầu
ra số. Khi được cấu hình làm Digital Input, chân GPIO được sử dụng để đọc mức
logic của tín hiệu bên ngoài.

Trong EduFramework, trạng thái Digital Input được biểu diễn bằng `LOW` và
`HIGH`.

#info-table(
  columns: (1fr, 1fr, 2.4fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Trạng thái],
    [Giá trị],
    [Ý nghĩa],
  ),
  rows: (
    (
      [`LOW`],
      [`0U`],
      [Mức logic thấp được phát hiện tại Digital Input.],
    ),
    (
      [`HIGH`],
      [`1U`],
      [Mức logic cao được phát hiện tại Digital Input.],
    ),
  ),
  caption: [Trạng thái logic của Digital Input],
)

`HIGH` và `LOW` không biểu diễn một giá trị điện áp cố định. Ngưỡng điện áp
được nhận biết là logic cao hoặc logic thấp phụ thuộc vào đặc tính điện của vi
điều khiển. Các giới hạn đối với S32K1xx được quy định trong Data Sheet của NXP
#cite-ref(refs, "nxp-s32k-datasheet").


== Nút nhấn như một Digital Input

Nút nhấn có hai trạng thái cơ bản: nhấn và thả. Khi thao tác nút làm thay đổi
mức logic tại Digital Input, chương trình có thể đọc mức này để xác định trạng
thái hiện tại của nút.

Trong một ứng dụng điển hình, Digital Input có thể được đọc liên tục trong vòng
lặp chính để chương trình phản hồi khi trạng thái của tín hiệu thay đổi.


== LED ngoài và điện trở hạn dòng

LED (Light-Emitting Diode) là linh kiện có cực tính với hai cực anode và
cathode. Khi LED được điều khiển từ GPIO, điện trở mắc nối tiếp được sử dụng để
giới hạn dòng qua LED #cite-ref(refs, "uw-gpio").

Khi kết nối LED ngoài với board phát triển, cần bảo đảm đúng cực tính của LED
và sử dụng chung GND giữa mạch ngoài và board.


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [LED],
      [LED ngoài được sử dụng làm đầu ra trực quan.],
    ),
    (
      [Điện trở 330 Ω],
      [Điện trở mắc nối tiếp để giới hạn dòng qua LED.],
    ),
    (
      [Breadboard],
      [Sử dụng để lắp LED và điện trở.],
    ),
    (
      [Jumper wires],
      [Sử dụng để kết nối mạch ngoài với board phát triển.],
    ),
  ),
)


== Ánh xạ chân

Bài thực hành sử dụng nút nhấn `BTN0` tích hợp trên board làm Digital Input và
Logical Pin `GPIO0` làm Digital Output. Ánh xạ phần cứng được trình bày trong
bảng dưới đây #cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Ánh xạ Digital I/O sử dụng trong bài thực hành],
  rows: (
    (
      [Nút nhấn tích hợp],
      "BTN0",
      "PTC12",
      [Digital Input],
    ),
    (
      [LED ngoài],
      "GPIO0",
      "PTE0",
      [Digital Output],
    ),
  ),
)


== Kết nối LED ngoài

LED ngoài được mắc nối tiếp với điện trở hạn dòng giữa `GPIO0` và GND. Sơ đồ
kết nối được trình bày trong hình dưới đây.

#figure-block(
  caption: [Sơ đồ kết nối LED ngoài với GPIO],
)[
  #image(
    "../assets/circuits/external_led_circuit.png.png",
    width: 82%,
  )
]

#note[
  LED là linh kiện có cực tính. Cần xác định đúng anode và cathode trước khi
  cấp nguồn cho mạch.
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài lab sử dụng các API Digital I/O của EduFramework để cấu hình đầu vào, đọc
trạng thái logic và thay đổi trạng thái của Digital Output.


== `pinMode()` với `INPUT`

`pinMode()` cấu hình chế độ hoạt động của một Logical Pin. Trong bài lab này,
chế độ `INPUT` được sử dụng để cấu hình chân làm Digital Input.

#api-detail(
  name: "pinMode",
  syntax: [pinMode(pin, INPUT);],
  description: [
    Cấu hình Logical Pin được chỉ định làm Digital Input.
  ],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân cần cấu hình làm đầu vào số.],
    ),
    (
      [mode],
      [`INPUT`],
      [Chế độ Digital Input.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
pinMode(BTN0, INPUT);
```


== `digitalRead()`

`digitalRead()` được sử dụng để đọc trạng thái logic hiện tại của một Logical
Pin #cite-ref(refs, "arduino-digitalread").

#api-detail(
  name: "digitalRead",
  syntax: [digitalRead(pin);],
  description: [
    Đọc trạng thái logic hiện tại của Logical Pin được chỉ định.
  ],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân Digital Input cần đọc trạng thái.],
    ),
  ),
  returns: [
    `HIGH` khi mức logic cao được phát hiện; `LOW` khi mức logic thấp được
    phát hiện.
  ],
)

Ví dụ:

```c
if (HIGH == digitalRead(BTN0))
{
    /* Button is pressed */
}
```


== `digitalToggle()`

`digitalToggle()` đảo mức logic hiện tại của một Digital Output.

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

Ví dụ:

```c
digitalToggle(GPIO0);
```


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình sử dụng `BTN0` để điều khiển LED ngoài kết nối với
`GPIO0`. Chương trình cần đáp ứng các yêu cầu sau:

- LED ngoài ban đầu ở trạng thái tắt.
- Mỗi lần `BTN0` được nhấn, trạng thái LED được đảo một lần.
- Giữ `BTN0` không làm LED thay đổi trạng thái liên tục.
- Sau khi thả `BTN0`, chương trình sẵn sàng nhận lần nhấn tiếp theo.


== Chương trình

Trong `src/main.c`, triển khai chương trình như sau:

#code-listing(
  caption: [Chương trình điều khiển LED ngoài bằng nút nhấn],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      bool pressed = false;

      setup();

      pinMode(BTN0, INPUT);
      pinMode(GPIO0, OUTPUT);

      digitalWrite(GPIO0, LOW);

      while (1)
      {
          if ((HIGH == digitalRead(BTN0)) && (false == pressed))
          {
              digitalToggle(GPIO0);
              pressed = true;
          }

          if (LOW == digitalRead(BTN0))
          {
              pressed = false;
          }
      }

      return 0;
  }
  ```
]

`BTN0` được cấu hình làm Digital Input và `GPIO0` làm Digital Output. LED được
đặt ở trạng thái ban đầu bằng `digitalWrite(GPIO0, LOW)`.

Biến `pressed` được sử dụng để ghi nhận lần nhấn hiện tại đã được xử lý hay
chưa. Khi `BTN0` ở mức `HIGH` và `pressed` bằng `false`, chương trình gọi
`digitalToggle()` để đảo trạng thái LED và đặt `pressed` thành `true`. Vì vậy,
việc tiếp tục giữ nút không làm LED bị đảo trạng thái nhiều lần.

Khi nút được thả và `digitalRead(BTN0)` trả về `LOW`, `pressed` được đặt lại
thành `false`. Chương trình sau đó có thể xử lý lần nhấn tiếp theo.


== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Quan sát LED ngoài
trong quá trình nhấn, giữ và thả `BTN0`.

#expected-result[
  LED ngoài ban đầu tắt. Mỗi lần `BTN0` được nhấn, LED đổi trạng thái đúng một
  lần. Việc giữ nút không làm LED thay đổi liên tục. Sau khi thả nút, lần nhấn
  tiếp theo tiếp tục đảo trạng thái LED.
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

== Nút nhấn ngoài và điện trở kéo

Khi một Digital Input không được chủ động nối tới mức logic cao hoặc thấp,
trạng thái tại chân có thể không được xác định ổn định. Điện trở pull-up hoặc
pull-down được sử dụng để thiết lập trạng thái mặc định cho input khi công tắc
đang mở.

S32K1xx tích hợp điện trở pull-up và pull-down cho các chân I/O. Trong điều kiện
I/O 3.3 V, Data Sheet quy định điện trở kéo nội có dải từ `20 kΩ` đến `60 kΩ`
#cite-ref(refs, "nxp-s32k-datasheet").

EduFramework cung cấp hai chế độ Digital Input có điện trở kéo:

#info-table(
  columns: (1.4fr, 2.6fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Chế độ],
    [Chức năng],
  ),
  rows: (
    (
      [`INPUT_PULLUP`],
      [Digital Input với điện trở kéo lên nội.],
    ),
    (
      [`INPUT_PULLDOWN`],
      [Digital Input với điện trở kéo xuống nội.],
    ),
  ),
  caption: [Các chế độ Digital Input có điện trở kéo],
)

Ví dụ:

```c
pinMode(pin, INPUT_PULLUP);
pinMode(pin, INPUT_PULLDOWN);
```

*Mở rộng:* Thay nút nhấn tích hợp bằng một nút nhấn ngoài kết nối với một
Logical Pin GPIO khác. Lựa chọn `INPUT_PULLUP` hoặc `INPUT_PULLDOWN` phù hợp
với cách đấu mạch và điều chỉnh điều kiện phát hiện trạng thái nhấn.


== Button debouncing

Tiếp điểm cơ học của nút nhấn có thể tạo nhiều chuyển mức ngắn trong quá trình
đóng hoặc mở. Hiện tượng này được gọi là contact bounce và có thể khiến một
thao tác vật lý được nhận thành nhiều sự kiện số
#cite-ref(refs, "ti-debounce").

Debouncing là quá trình hạn chế các chuyển mức không mong muốn này. Tùy yêu cầu
của ứng dụng, debouncing có thể được thực hiện bằng phần cứng hoặc phần mềm.

EduFramework tự động bật passive input filter cho các Logical Pin được xác định
là nút nhấn tích hợp. Cơ chế này giúp lọc các xung ngắn tại input nhưng không
thay thế một phương pháp debounce hoàn chỉnh trong mọi trường hợp.

*Mở rộng:* Sử dụng nút nhấn ngoài và đề xuất một phương pháp software debounce
để chỉ xử lý trạng thái nút sau khi tín hiệu đã ổn định trong một khoảng thời
gian xác định.


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
