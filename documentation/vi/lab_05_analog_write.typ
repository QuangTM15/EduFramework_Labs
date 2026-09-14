#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 05 - Cơ bản về Analog Write
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "uw-pwm",
    type: "web",
    author: [University of Wisconsin-Madison],
    title: [Điều chế độ rộng xung],
    source: [ECE353 - Introduction to Microprocessor Systems],
    url: "https\://ece353.engr.wisc.edu/peripheral-devices/pulse-width-modulation/",
  ),
  (
    key: "nxp-s32k-cookbook",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Cookbook],
    document: [AN5413],
    revision: [5],
    year: [2020],
    url: "https\://www.nxp.com/docs/en/application-note/AN5413.pdf",
  ),
  (
    key: "arduino-analogwrite",
    type: "web",
    author: [Arduino],
    title: [analogWrite()],
    source: [Arduino Language Reference],
    url: "https\://docs.arduino.cc/language-reference/en/functions/analog-io/analogWrite/",
  ),
  (
    key: "ti-rgb-led",
    type: "application-note",
    author: [Texas Instruments],
    title: [MSP430 Software RGB LED Control Design Guide],
    document: [TIDU761],
    year: [2015],
    url: "https\://www.ti.com/lit/ug/tidu761/tidu761.pdf",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 5,
  language: "vi",
  title: [Cơ bản về Analog Write],
  subtitle: [Điều khiển độ sáng LED bằng PWM với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Digital Output trong các bài lab trước sử dụng hai trạng thái `HIGH` và `LOW` để
bật hoặc tắt một đầu ra. Tuy nhiên, nhiều ứng dụng cần điều khiển mức tác động
trung gian, chẳng hạn thay đổi độ sáng của LED, điều khiển tốc độ động cơ thay vì chỉ bật hoặc tắt hoàn
toàn.

Điều chế độ rộng xung (PWM) là kỹ thuật điều khiển công suất trung bình truyền
tới tải bằng cách chuyển đổi nhanh tín hiệu giữa trạng thái bật và tắt. Thay vì
thay đổi trực tiếp biên độ điện áp của tín hiệu số, PWM thay đổi tỷ lệ thời gian
tín hiệu ở trạng thái bật trong mỗi chu kỳ #cite-ref(refs, "uw-pwm").

Bài thực hành tập trung vào quan hệ giữa chu kỳ PWM, duty cycle và độ sáng LED.

== Mục tiêu

#objectives(
  items: (
    [
      Giải thích nguyên lý cơ bản của điều chế độ rộng xung (PWM).
    ],
    [
      Mô tả các khái niệm chu kỳ, tần số và duty cycle của tín hiệu PWM.
    ],
    [
      Giải thích quan hệ giữa duty cycle và độ sáng quan sát được của LED.
    ],
    [
      Sử dụng `analogWrite()` để điều khiển mức PWM.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng làm LED sáng dần rồi tối dần liên tục.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Điều chế độ rộng xung

PWM tạo ra một tín hiệu số chuyển đổi tuần hoàn giữa hai trạng thái bật và tắt.
PWM được mô tả như một phương pháp điều khiển công
suất trung bình truyền tới tải bằng cách đóng và ngắt tín hiệu nhanh; tín hiệu
PWM thường được biểu diễn dưới dạng sóng vuông có chu kỳ xác định
#cite-ref(refs, "uw-pwm").

Điểm quan trọng của PWM là biên độ logic không cần thay đổi. Thay vào đó, lượng
thời gian tín hiệu ở trạng thái bật trong mỗi chu kỳ được thay đổi. Vì vậy, PWM
vẫn là tín hiệu số theo thời gian, không phải một mức điện áp analog liên tục.

== Chu kỳ và tần số

Một tín hiệu PWM lặp lại theo một chu kỳ cố định. Gọi thời gian tín hiệu ở trạng
thái bật là $T_"ON"$ và thời gian ở trạng thái tắt là $T_"OFF"$, chu kỳ $T$ được
xác định bởi:

$ T = T_"ON" + T_"OFF" $

Tần số $f$ cho biết số chu kỳ lặp lại trong một giây và có quan hệ:

$ f = 1 / T $

Các đại lượng chu kỳ và tần số mô tả tốc độ lặp lại của tín hiệu, trong khi
duty cycle mô tả tỷ lệ thời gian bật trong từng chu kỳ. Đây là ba đại lượng cơ
bản được sử dụng để mô tả tín hiệu PWM #cite-ref(refs, "uw-pwm").

== Duty cycle

Duty cycle là tỷ số giữa thời gian tín hiệu ở trạng thái bật và tổng thời gian
của một chu kỳ. Giá trị này thường được biểu diễn theo phần trăm:

$ D = (T_"ON" / T) times 100 " %" $

Ví dụ, duty cycle `25%` nghĩa là tín hiệu ở trạng thái bật trong một phần tư chu
kỳ; duty cycle `50%` nghĩa là thời gian bật và tắt bằng nhau. Khi duty cycle tăng,
thời gian bật trong mỗi chu kỳ tăng và công suất trung bình truyền tới tải cũng
tăng #cite-ref(refs, "uw-pwm").

#info-table(
  columns: (1.1fr, 1.5fr, 2.4fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Duty cycle],
    [Thời gian bật trong chu kỳ],
    [Ý nghĩa],
  ),
  rows: (
    (
      [`0%`],
      [Không có],
      [Tín hiệu luôn ở trạng thái tắt.],
    ),
    (
      [`25%`],
      [Một phần tư chu kỳ],
      [Thời gian bật ngắn hơn thời gian tắt.],
    ),
    (
      [`50%`],
      [Một nửa chu kỳ],
      [Thời gian bật và tắt bằng nhau.],
    ),
    (
      [`75%`],
      [Ba phần tư chu kỳ],
      [Thời gian bật dài hơn thời gian tắt.],
    ),
    (
      [`100%`],
      [Toàn bộ chu kỳ],
      [Tín hiệu luôn ở trạng thái bật.],
    ),
  ),
  caption: [Quan hệ giữa duty cycle và thời gian bật của tín hiệu PWM],
)

== PWM và độ sáng LED

PWM thường được sử dụng để điều khiển độ sáng LED. Khi tần số chuyển mạch đủ
nhanh, các lần bật và tắt liên tiếp không được quan sát như các trạng thái tách
biệt; thay vào đó, LED được cảm nhận với một mức sáng phụ thuộc vào tỷ lệ thời
gian bật #cite-ref(refs, "uw-pwm").

Vì vậy, với cùng một chu kỳ PWM, thay đổi duty cycle cho phép thay đổi độ sáng
quan sát được mà không cần thay đổi giữa nhiều mức điện áp logic. Đây là nguyên
lý được sử dụng trong bài thực hành để làm LED sáng dần và tối dần.

Quan hệ giữa duty cycle và độ sáng thực tế của LED không nhất thiết tuyến tính
hoàn toàn. Đối với LED thực, duty cycle không hoàn
toàn tương ứng tuyến tính với mức sáng đầu ra; trong các ứng dụng đơn giản có
thể sử dụng quan hệ gần đúng để điều khiển #cite-ref(refs, "ti-rgb-led").

#note[
  PWM điều khiển tỷ lệ thời gian bật của tín hiệu số. `analogWrite()` trong bài
  lab được sử dụng để điều khiển PWM; tên API không có nghĩa là chân tạo ra một
  mức điện áp analog liên tục.
]

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng trực tiếp LED tích hợp trên MaaZEDU Development Board và không
yêu cầu lắp thêm linh kiện hoặc mạch ngoài.

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

== Ánh xạ LED sử dụng trong bài thực hành

EduFramework cung cấp Logical Pin `LED_RED` để truy cập LED đỏ tích hợp. Bài
thực hành sử dụng LED này làm đầu ra PWM; không cần kết nối thêm LED ngoài.

#pin-table(
  caption: [Ánh xạ LED sử dụng trong bài thực hành],
  rows: (
    (
      [LED đỏ tích hợp],
      "LED_RED",
      "PTD15",
      [PWM Output],
    ),
  ),
)

Trước khi điều khiển độ sáng, `LED_RED` phải được cấu hình ở chế độ `OUTPUT` bằng
`pinMode()`.

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài thực hành giới thiệu một API mới là `analogWrite()` giúp chương trình điều khiển mức PWM bằng một Logical Pin
và một giá trị số thay vì thao tác trực tiếp với cấu hình PWM mức thấp
#cite-ref(refs, "arduino-analogwrite").

== `analogWrite()`

`analogWrite()` ghi một giá trị PWM tới Logical Pin có hỗ trợ PWM. Trong
EduFramework, giá trị đầu vào nằm trong dải `0` đến `255`; giá trị này biểu diễn
mức điều khiển từ tắt tới độ sáng tối đa đối với LED trong bài thực hành.

#api-detail(
  name: "analogWrite",
  syntax: [analogWrite(pin, value);],
  description: [
    Ghi giá trị PWM tới Logical Pin được chỉ định.
  ],
  parameters: (
    (
      [pin],
      [PWM-capable Logical Pin],
      [Chân cần điều khiển bằng PWM, ví dụ `LED_RED`.],
    ),
    (
      [value],
      [`0` đến `255`],
      [
        Mức PWM cần thiết lập. `0` tương ứng LED tắt và `255` tương ứng độ sáng
        tối đa trong cách sử dụng của bài lab.
      ],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
analogWrite(LED_RED, 128U);
```

Các giá trị trung gian cho phép thay đổi duty cycle theo các mức khác nhau. Khi
giá trị được thay đổi dần theo thời gian, độ sáng LED cũng thay đổi dần theo xu
hướng tương ứng.

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình điều khiển `LED_RED` sáng dần từ trạng thái tắt tới độ
sáng tối đa, sau đó tối dần về trạng thái tắt và lặp lại liên tục.

Chương trình cần đáp ứng các yêu cầu sau:

- Cấu hình `LED_RED` ở chế độ `OUTPUT`.
- Tăng giá trị PWM tuần tự từ `0` đến `255` để LED sáng dần.
- Giảm giá trị PWM từ `255` về `0` để LED tối dần.
- Sử dụng khoảng chờ `5 ms` giữa hai mức liên tiếp để hiệu ứng có thể quan sát
  rõ trên phần cứng.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình điều khiển LED sáng dần và tối dần bằng PWM],
  )[
    ```c
    #include "Arduino.h"

    int main(void)
    {
        int pwmValue = 0U;

        setup();

        pinMode(LED_RED, OUTPUT);

        while (1)
        {
            /* Fade in: 0 -> 255 */
            for (pwmValue = 0U; pwmValue <= 255U; pwmValue++)
            {
                analogWrite(LED_RED, pwmValue);
                delay(5U);
            }

            /* Fade out: 255 -> 0 */
            for (pwmValue = 255U; pwmValue > 0U; pwmValue--)
            {
                analogWrite(LED_RED, pwmValue);
                delay(5U);
            }

            analogWrite(LED_RED, 0U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo các thành phần nền tảng của EduFramework. Sau đó,
`pinMode(LED_RED, OUTPUT)` cấu hình LED đỏ làm đầu ra theo kiến thức đã sử dụng
ở Lab 01.

Vòng lặp `for` thứ nhất tăng `pwmValue` từ `0` đến `255`. Mỗi giá trị được truyền
vào `analogWrite()`, sau đó chương trình chờ `5 ms` trước khi chuyển sang mức kế
tiếp. Kết quả là mức PWM tăng từng bước nhỏ và LED sáng dần.

Vòng lặp `for` thứ hai thực hiện quá trình ngược lại: `pwmValue` giảm từ `255` về
gần `0`, làm LED tối dần. Lệnh `analogWrite(LED_RED, 0U)` sau vòng lặp bảo đảm
LED trở về trạng thái tắt trước khi chu kỳ tiếp theo bắt đầu.

Luồng xử lý của ứng dụng có thể tóm tắt:

`0` → tăng dần giá trị PWM → `255` → giảm dần giá trị PWM → `0` → lặp lại.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Quan sát `LED_RED`
trong nhiều chu kỳ liên tiếp.

#block(breakable: false)[
  #expected-result[
    LED đỏ bắt đầu từ trạng thái tắt, sáng dần tới mức sáng tối đa, sau đó tối
    dần về trạng thái tắt. Quá trình diễn ra liên tục và sự thay đổi giữa các
    mức sáng liên tiếp có thể quan sát như một hiệu ứng chuyển độ sáng mượt.
  ]
]

Có thể thay đổi tạm thời giá trị `delay(5U)` để quan sát ảnh hưởng của khoảng
thời gian giữa các lần cập nhật PWM tới tốc độ của hiệu ứng. Nội dung này chỉ
thay đổi tốc độ cập nhật giá trị trong chương trình, không thay đổi định nghĩa
duty cycle của tín hiệu PWM.

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

MaaZEDU cung cấp ba kênh LED đỏ, xanh lá và xanh dương thông
qua các Logical Pin `LED_RED`, `LED_GREEN` và `LED_BLUE`. Ba thành phần này có
thể được điều khiển độc lập để mở rộng từ thay đổi độ sáng sang trộn màu RGB.

== Trộn màu RGB bằng PWM

Trộn màu RGB dựa trên ba thành phần màu đỏ, xanh lá và xanh dương. Màu đầu ra
của RGB LED được tạo bằng cách thay đổi mức của ba thành phần R, G và B; các
thành phần được kết hợp theo nguyên lý additive color mixing, và mức của từng
thành phần có thể được điều khiển bằng duty cycle PWM
#cite-ref(refs, "ti-rgb-led").

Ở mức ứng dụng, có thể xem một màu như một bộ ba giá trị PWM `(R, G, B)`. Một số
kết hợp cơ bản được trình bày dưới đây:

#info-table(
  columns: (1.4fr, 1fr, 1fr, 1fr),
  alignments: (
    left + horizon,
    center + horizon,
    center + horizon,
    center + horizon,
  ),
  headers: (
    [Màu kết quả],
    [Red],
    [Green],
    [Blue],
  ),
  rows: (
    ([Đỏ], [`255`], [`0`], [`0`]),
    ([Xanh lá], [`0`], [`255`], [`0`]),
    ([Xanh dương], [`0`], [`0`], [`255`]),
    ([Vàng], [`255`], [`255`], [`0`]),
    ([Cyan], [`0`], [`255`], [`255`]),
    ([Magenta], [`255`], [`0`], [`255`]),
    ([Trắng], [`255`], [`255`], [`255`]),
  ),
  caption: [Ví dụ giá trị RGB ở mức điều khiển 0 đến 255],
)

Các bộ giá trị trên biểu diễn các kết hợp lý tưởng ở mức điều khiển. Màu quan
sát thực tế có thể khác do đặc tính và độ sáng của từng LED không hoàn toàn
đồng nhất. Các màu LED có đặc tính điện và quan hệ
dòng điện - độ sáng khác nhau, vì vậy hệ thống yêu cầu độ chính xác màu cao cần
xem xét đặc tính phần cứng cụ thể #cite-ref(refs, "ti-rgb-led").

== Gợi ý chuyển màu mượt

Nếu chương trình tắt hoàn toàn màu hiện tại rồi mới bật màu tiếp theo, sự thay
đổi sẽ xuất hiện như một bước chuyển đột ngột. Để tạo chuyển màu mượt, có thể
thay đổi đồng thời các giá trị PWM của hai hoặc ba kênh theo nhiều bước nhỏ.

Ví dụ, để chuyển từ đỏ sang xanh lá:

- Giảm dần giá trị của `LED_RED` từ `255` về `0`.
- Đồng thời tăng dần giá trị của `LED_GREEN` từ `0` lên `255`.
- Giữ `LED_BLUE` bằng `0` trong quá trình chuyển màu.

Ý tưởng tương tự có thể được áp dụng tuần tự để tạo chuỗi màu:

`Red` → `Yellow` → `Green` → `Cyan` → `Blue` → `Magenta` → `Red`.

#note[
  Phần mở rộng không yêu cầu một thuật toán color science hoặc hiệu chuẩn màu.
  Mục tiêu là áp dụng cùng nguyên lý PWM của bài chính cho nhiều kênh và thay
  đổi các giá trị RGB theo từng bước để tạo color mixing và smooth transition.
]

*Mở rộng:* Viết chương trình sử dụng `LED_RED`, `LED_GREEN` và `LED_BLUE` để tạo
một chuỗi chuyển màu liên tục. Không chuyển trực tiếp từ màu này sang màu khác;
thay vào đó, hãy thay đổi dần các giá trị PWM của các kênh liên quan để quá
trình chuyển màu có thể quan sát một cách liên tục.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
