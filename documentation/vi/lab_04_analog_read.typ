#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 04 - Cơ bản về Analog Read
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "iowa-sampling",
    type: "web",
    author: [Iowa State University],
    title: [Chapter 6: Sampling Theory],
    source: [EE/CprE/HSSE Lab],
    url: "https://class.ece.iastate.edu/mmina/ee418/Notes/Chapter6SamplingTheory-less-book%20stuff.pdf",
  ),
  (
    key: "cmu-photoresistor",
    type: "web",
    author: [Carnegie Mellon University],
    title: [Reading a Photoresistor: How Light Is It?],
    source: [60-223 Introduction to Physical Computing],
    url: "https://courses.ideate.cmu.edu/60-223/s2026/tutorials/reading-a-photoresistor",
  ),
  (
    key: "arduino-analogread",
    type: "web",
    author: [Arduino],
    title: [analogRead()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/analog-io/analogRead/",
  ),
  (
    key: "arduino-analogread-resolution",
    type: "web",
    author: [Arduino],
    title: [analogReadResolution()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/analog-io/analogReadResolution/",
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
    key: "nxp-s32k-cookbook",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Cookbook],
    document: [AN5413],
    revision: [5],
    year: [2020],
    url: "https://www.nxp.com/docs/en/application-note/AN5413.pdf",
  ),
  (
    key: "eduframework-analog",
    type: "web",
    author: [EduFramework],
    title: [Analog API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 4,
  language: "vi",
  title: [Cơ bản về Analog Read],
  subtitle: [Đọc tín hiệu analog với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Trong hệ thống nhúng, nhiều đại lượng vật lý không chỉ tồn tại dưới hai trạng
thái logic như `HIGH` và `LOW` mà thay đổi liên tục theo điều kiện môi trường.
Để vi điều khiển có thể xử lý các tín hiệu dạng này, điện áp analog cần được
chuyển đổi thành giá trị số thông qua bộ chuyển đổi tương tự - số
(Analog-to-Digital Converter - ADC).

Bài lab này được thiết kế để giới thiệu quá trình đọc tín hiệu analog bằng ADC
và API `analogRead()` của EduFramework. Một quang trở LDR được mắc trong mạch
chia áp để tạo điện áp thay đổi theo điều kiện chiếu sáng. Giá trị ADC thu được
được truyền tới Serial Monitor để quan sát bằng kiến thức đã sử dụng ở bài lab
trước.

Bài thực hành tập trung vào giá trị ADC thô thay vì chuyển đổi sang đơn vị lux.
Qua đó, mối quan hệ giữa tín hiệu analog, quá trình lấy mẫu, độ phân giải ADC và
giá trị số có thể được quan sát trực tiếp trên phần cứng.

== Mục tiêu

#objectives(
  items: (
    [
      Phân biệt tín hiệu analog và biểu diễn số được sử dụng trong hệ thống
      nhúng.
    ],
    [
      Giải thích các khái niệm cơ bản của ADC gồm sampling, quantization và độ
      phân giải.
    ],
    [
      Mô tả cách quang trở kết hợp với mạch chia áp để tạo tín hiệu điện áp có thể
      đưa vào ADC.
    ],
    [
      Sử dụng `analogRead()` để đọc giá trị ADC 12-bit thông qua EduFramework.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng giám sát sự thay đổi ánh sáng trên Serial
      Monitor.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Tín hiệu analog và biểu diễn số

Tín hiệu analog có thể thay đổi liên tục theo thời gian và biên độ. Trong khi
đó, hệ thống số xử lý dữ liệu dưới dạng các giá trị rời rạc. Vì vậy, khi một đại
lượng vật lý được chuyển thành điện áp analog, vi điều khiển cần một quá trình
chuyển đổi để biểu diễn điện áp đó bằng dữ liệu số.

Sampling là quá
trình biến tín hiệu liên tục theo thời gian thành một chuỗi các mẫu rời rạc
#cite-ref(refs, "iowa-sampling"). ADC thực hiện vai trò quan trọng trong quá
trình thu nhận dữ liệu này: tín hiệu điện áp tại đầu vào được lấy mẫu và kết quả
được biểu diễn bằng một mã số mà chương trình có thể xử lý.


== Chuyển đổi tương tự - số

Quá trình chuyển đổi analog sang digital có thể được mô tả bằng hai khái niệm
cơ bản: sampling và quantization.

*Sampling* xác định giá trị của tín hiệu analog tại những thời điểm rời rạc.
Khoảng thời gian giữa hai lần lấy mẫu liên tiếp được gọi là sampling period,
thường ký hiệu là $T_s$. Sampling frequency $F_s$ có quan hệ:

$ F_s = 1 / T_s $

Sau khi lấy mẫu, giá trị biên độ của mẫu cần được biểu diễn bằng một số hữu hạn
các mức. Quá trình gán giá trị analog vào một mức số có thể biểu diễn được gọi
là *quantization*. Do số mức biểu diễn là hữu hạn, giá trị số thu được chỉ là
một biểu diễn rời rạc của điện áp đầu vào.
Quantization error là sai khác xuất hiện khi giá trị thực được làm tròn về mức
LSB gần nhất; tăng độ phân giải ADC làm giảm kích thước của mỗi bước lượng tử
#cite-ref(refs, "iowa-sampling").

== Độ phân giải ADC

Độ phân giải xác định số bit được sử dụng để biểu diễn kết quả chuyển đổi. Với
ADC có độ phân giải $N$ bit, số mã số có thể biểu diễn là:

$ 2^N $

S32K1xx tích hợp ADC có độ phân giải tới 12 bit
#cite-ref(refs, "nxp-s32k-datasheet"). EduFramework hiện cấu hình đường đọc
analog mặc định ở chế độ 12-bit #cite-ref(refs, "eduframework-analog"). Vì vậy:

$ 2^12 = 4096 $

Kết quả ADC thô có 4096 mã, từ `0` đến `4095`.

#info-table(
  columns: (1.2fr, 1.4fr, 2fr),
  alignments: (
    center + horizon,
    center + horizon,
    center + horizon,
  ),
  headers: (
    [Độ phân giải],
    [Số mã],
    [Dải giá trị thô],
  ),
  rows: (
    (
      [12-bit],
      [`4096`],
      [`0` đến `4095`],
    ),
  ),
  caption: [Biểu diễn kết quả ADC 12-bit trong EduFramework],
)

Giá trị `0` và `4095` là các mã số ở hai đầu dải chuyển đổi, không phải đơn vị
điện áp hoặc đơn vị ánh sáng. Quan hệ giữa một mã ADC và điện áp phụ thuộc vào
điện áp tham chiếu của ADC.Trong EduFramework của bài
lab này, độ phân giải đã được framework cấu hình cố định ở 12 bit nên ứng dụng
không cần thay đổi độ phân giải trước khi đọc.

== Quang trở LDR

Photoresistor, thường được gọi là LDR (Light-Dependent Resistor), là linh kiện
có điện trở thay đổi theo lượng ánh sáng chiếu vào
#cite-ref(refs, "cmu-photoresistor"). LDR vì vậy có thể được sử dụng làm phần tử
nhạy sáng trong các ứng dụng cần phát hiện sự thay đổi tương đối của điều kiện
chiếu sáng.

ADC không đo trực tiếp điện trở của LDR. Để biến sự thay đổi điện trở thành một
đại lượng ADC có thể đọc, LDR được kết hợp với một điện trở cố định tạo thành
mạch chia áp
#cite-ref(refs, "cmu-photoresistor").

Bài lab sử dụng LDR để quan sát xu hướng thay đổi của ánh sáng, không thực hiện
hiệu chuẩn theo đơn vị lux. Giá trị ADC phụ thuộc vào đặc tính của LDR, điện trở
cố định, nguồn cấp và điều kiện chiếu sáng thực tế.

== Mạch chia áp với LDR

Mạch chia áp của bài thực hành gồm LDR ở phía nguồn và điện trở cố định `10 kΩ`
ở phía GND. Điểm giữa hai linh kiện được nối với đầu vào ADC. Với cấu hình này,
điện áp tại điểm đo có thể biểu diễn theo quan hệ chia áp:

$ V_"ADC" = V_"CC" times (R_"fixed" / (R_"LDR" + R_"fixed")) $

Khi điều kiện chiếu sáng làm điện trở LDR giảm, điện áp tại điểm giữa tăng; ADC
vì vậy tạo ra giá trị số lớn hơn. Khi LDR bị che tối, xu hướng ngược lại xuất
hiện. Quan hệ này đã được kiểm chứng trên mạch sử dụng trong bài thực hành.

#note[
  Giá trị ADC phản ánh điện áp tại điểm giữa của mạch chia áp. Nó không phải là
  phép đo cường độ ánh sáng theo đơn vị lux nếu chưa có quá trình hiệu chuẩn cảm
  biến.
]

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng một LDR và điện trở `10 kΩ` để tạo mạch chia áp bên ngoài. Điện
áp tại điểm giữa được đưa vào kênh ADC của S32K144.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [LDR],
      [Quang trở được sử dụng để tạo tín hiệu thay đổi theo ánh sáng.],
    ),
    (
      [Điện trở 10 kΩ],
      [Điện trở cố định tạo mạch chia áp với LDR.],
    ),
    (
      [Breadboard],
      [Sử dụng để lắp mạch chia áp.],
    ),
    (
      [Jumper wires],
      [Kết nối nguồn, GND và tín hiệu ADC giữa board và mạch ngoài.],
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

== Ánh xạ chân ADC

EduFramework hiện hỗ trợ hai Logical Pin cho Analog Input là `ADC0_SE12` và
`ADC0_SE13` #cite-ref(refs, "eduframework-analog"). Bài thực hành sử dụng
`ADC0_SE12`, được ánh xạ tới `PTC14` của S32K144.

#pin-table(
  caption: [Ánh xạ Analog Input sử dụng trong bài thực hành],
  rows: (
    (
      [Ngõ ra mạch chia áp LDR],
      "ADC0_SE12",
      "PTC14",
      [Analog Input / ADC0 Channel 12],
    ),
  ),
)

== Kết nối mạch LDR

LDR được nối từ nguồn của mạch tới điểm đo ADC. Điện trở `10 kΩ` được nối từ
điểm đo ADC xuống GND. Điểm giữa được nối tới `ADC0_SE12` (`PTC14`). Board và
mạch ngoài phải sử dụng chung GND.

#figure-block(
  caption: [Sơ đồ kết nối LDR và điện trở 10 kΩ với Analog Input],
)[
  #image(
    "../assets/circuits/ldr_voltage_divider_circuit.png",
    width: 78%,
  )
]

Với cách mắc đã được kiểm chứng trên phần cứng, tăng ánh sáng làm giá trị ADC
tăng; che LDR làm giá trị ADC giảm. Không cần xác định một giá trị ngưỡng cố
định trong bài lab vì giá trị thực tế thay đổi theo linh kiện và môi trường.

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

== `analogRead()`

`analogRead()` thực hiện một lần chuyển đổi ADC trên Logical Pin analog được chỉ
định và chờ cho tới khi kết quả sẵn sàng. Trong EduFramework hiện tại, các chân
đầu vào được hỗ trợ là `ADC0_SE12` và `ADC0_SE13`
#cite-ref(refs, "eduframework-analog").

#api-detail(
  name: "analogRead",
  syntax: [analogRead(pin);],
  description: [
    Đọc một Analog Input và trả về kết quả ADC thô.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [
        Chân analog cần đọc. Phiên bản hiện tại hỗ trợ `ADC0_SE12` và
        `ADC0_SE13`.
      ],
    ),
  ),
  returns: [
    Giá trị ADC thô khi chuyển đổi thành công; `-1` nếu chân không hợp lệ hoặc
    quá trình khởi tạo/chuyển đổi thất bại.
  ],
)

Ví dụ:

```c
int value = analogRead(ADC0_SE12);
```

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình đọc LDR qua `ADC0_SE12` và hiển thị liên tục giá trị ADC
thô trên Serial Monitor. Chương trình sử dụng baud rate `9600` và cập nhật kết
quả sau mỗi khoảng `500 ms`.

Thay đổi điều kiện chiếu sáng bằng cách chiếu sáng vào LDR hoặc che LDR để quan
sát xu hướng thay đổi của giá trị ADC.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình đọc LDR bằng Analog Input],
  )[
    ```c
    #include "Arduino.h"

    int main(void)
    {
        uint16_t lightValue = 0U;

        setup();

        Serial1_begin(9600U);

        Serial1_println("EduFramework Analog Read");
        Serial1_println("LDR monitoring started.");

        while (1)
        {
            lightValue = analogRead(ADC0_SE12);

            Serial1_print("ADC: ");
            Serial1_printlnInt(lightValue);

            delay(500U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo các thành phần nền tảng của EduFramework. Sau đó,
`Serial1_begin(9600U)` khởi tạo kênh Serial Monitor theo cấu hình đã sử dụng ở
Lab 03.

Trong vòng lặp chính, `analogRead(ADC0_SE12)` thực hiện một lần đọc ADC và lưu
kết quả vào `lightValue`. Giá trị này được truyền tới Serial Monitor bằng các
API Serial đã học trước đó. `delay(500U)` tạo khoảng cách giữa hai lần hiển thị,
giúp kết quả thay đổi đủ chậm để quan sát.

Luồng xử lý của ứng dụng có thể tóm tắt:

`Ánh sáng` → `LDR + mạch chia áp` → `ADC0_SE12` → `analogRead()` → `Serial1`
→ `Serial Monitor`.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board, sau đó mở Serial
Monitor với baud rate `9600`.

Quan sát giá trị ADC ở ba điều kiện: ánh sáng môi trường, chiếu sáng mạnh hơn
vào LDR và che LDR. Không cần đạt một giá trị ADC cụ thể; mục tiêu là kiểm tra
xu hướng thay đổi ổn định theo điều kiện chiếu sáng.

Dữ liệu trên Serial Monitor có dạng:

```text
EduFramework Analog Read
LDR monitoring started.
ADC: ...
ADC: ...
ADC: ...
```

#block(breakable: false)[
  #expected-result[
    Serial Monitor cập nhật một giá trị ADC khoảng mỗi `500 ms`. Với mạch chia
    áp của bài thực hành, giá trị tăng khi LDR được chiếu sáng mạnh hơn và giảm
    khi LDR bị che tối. Giá trị nằm trong dải mã của ADC 12-bit, từ `0` đến
    `4095`.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính sử dụng `analogRead()` để tập trung vào khái niệm Analog
Input và giá trị ADC thô. EduFramework còn cung cấp API chuyển đổi kết quả sang
millivolt và nhóm API đọc ADC theo phương pháp non-blocking
#cite-ref(refs, "eduframework-analog").

== Đọc điện áp với `analogReadMilliVolts()`

`analogReadMilliVolts()` thực hiện một lần đọc analog và chuyển kết quả ADC thô
sang millivolt theo điện áp tham chiếu được cấu hình trong EduFramework.

#api-detail(
  name: "analogReadMilliVolts",
  syntax: [analogReadMilliVolts(pin);],
  description: [
    Đọc Analog Input và trả về giá trị đã được quy đổi sang millivolt.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Chân analog cần đọc, ví dụ `ADC0_SE12`.],
    ),
  ),
  returns: [
    Giá trị điện áp theo millivolt khi thành công; `-1` nếu thao tác thất bại.
  ],
)

Ví dụ:

```c
int voltageMv = analogReadMilliVolts(ADC0_SE12);
```

Trong phiên bản EduFramework hiện tại, phép quy đổi của API này sử dụng giá trị
tham chiếu mặc định `5000 mV` được cấu hình trong `wiring_analog.c`
#cite-ref(refs, "eduframework-analog"). Vì vậy, khi sử dụng kết quả như một phép
đo điện áp chính xác, điện áp tham chiếu thực tế của hệ thống phải phù hợp với
cấu hình được sử dụng trong framework.

*Mở rộng:* Thay giá trị ADC thô trên Serial Monitor bằng giá trị millivolt và
quan sát quan hệ giữa hai cách biểu diễn khi điều kiện chiếu sáng thay đổi.

== Đọc ADC theo phương pháp non-blocking

`analogRead()` là API blocking: hàm bắt đầu chuyển đổi và chỉ trả về sau khi kết
quả đã sẵn sàng. Với ứng dụng cần tiếp tục thực hiện công việc khác trong thời
gian chờ ADC, EduFramework cung cấp ba API:

- `analogStart(pin)` bắt đầu một lần chuyển đổi và trả về ngay.
- `analogAvailable()` kiểm tra kết quả đã sẵn sàng hay chưa.
- `analogGetResult()` lấy kết quả của lần chuyển đổi đã hoàn thành.

Luồng sử dụng có thể biểu diễn bằng mẫu ngắn sau:

#block(breakable: false)[
  #code-listing(
    caption: [Nguyên tắc đọc ADC theo phương pháp non-blocking],
  )[
    ```c
    analogStart(ADC0_SE12);

    /* Other application processing */

    if (0U != analogAvailable())
    {
        value = analogGetResult();
    }
    ```
  ]
]

*Mở rộng:* Viết lại phần đọc LDR của bài thực hành bằng
`analogStart()` → `analogAvailable()` → `analogGetResult()` mà không sử dụng
`analogRead()`. Sau khi nhận kết quả, hiển thị giá trị trên Serial Monitor và
khởi động lần chuyển đổi tiếp theo. Không thay đổi mạch phần cứng.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
