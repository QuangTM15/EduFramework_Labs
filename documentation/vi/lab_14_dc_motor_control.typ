#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 14 - Điều khiển động cơ DC
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "purdue-actuators",
    type: "web",
    author: [Purdue University],
    title: [Lab 7: Implementing Actuators],
    source: [ME588 - Mechatronics],
    year: [2015],
    url: "https://engineering.purdue.edu/ME588/LabManual/2015_lab7.pdf",
  ),

  (
    key: "ut-motor-pwm",
    type: "web",
    author: [Jonathan W. Valvano and Andreas Gerstlauer],
    title: [ECE445M/ECE380L.12 - Lecture 8],
    source: [The University of Texas at Austin],
    year: [2025],
    url: "https://users.ece.utexas.edu/~gerstl/ece445m_s25/lectures/Lec08.pdf",
  ),

  (
    key: "toshiba-tb6612fng",
    type: "datasheet",
    author: [Toshiba Electronic Devices & Storage Corporation],
    title: [TB6612FNG - Driver IC for Dual DC Motor],
    document: [TB6612FNG],
    year: [2026],
    url: "https://toshiba.semicon-storage.com/info/docget.jsp?did=10660&prodName=TB6612FNG",
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
    revision: [1.0],
    year: [2025],
  ),

  (
    key: "eduframework-dc-motor",
    type: "web",
    author: [EduFramework],
    title: [API thiết bị động cơ DC],
    source: [Mã nguồn EduFramework],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 14,
  language: "vi",
  title: [Điều khiển động cơ DC],
  subtitle: [Điều khiển tốc độ và chiều quay với module điều khiển động cơ],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

PWM đã được sử dụng trong các bài lab trước để điều khiển mức tác động của một
đầu ra. Với tải công suất như động cơ DC, vi điều khiển không cấp dòng trực tiếp
cho động cơ mà thường sử dụng một module điều khiển động cơ làm tầng trung gian
giữa tín hiệu điều khiển và tải.

Các module điều khiển động cơ kiểu cầu H thường cho phép thực hiện ba chức năng
cơ bản: thay đổi chiều quay, điều khiển mức tác động bằng PWM và đưa động cơ về
trạng thái dừng. Trong bài thực hành này, TB6612FNG được sử dụng làm một ví dụ
điển hình cho loại module đó. TB6612FNG hỗ trợ điều khiển hai chiều quay, PWM,
dừng, phanh ngắn mạch và chế độ chờ
#cite-ref(refs, "toshiba-tb6612fng").

Ở mức ứng dụng, EduFramework cung cấp API thiết bị động cơ DC để chương trình
thiết lập mức điều khiển tốc độ, chiều quay và trạng thái dừng mà không cần thao
tác trực tiếp với từng tín hiệu điều khiển của mạch cầu H.

Bài thực hành tập trung vào một chuỗi hoạt động đơn giản: động cơ quay thuận ở
mức điều khiển khoảng `50%`, dừng, quay nghịch ở cùng mức và tiếp tục lặp lại.

== Mục tiêu

#objectives(
  items: (
    [
      Mô tả vai trò của module điều khiển động cơ trong hệ thống điều khiển
      động cơ DC.
    ],

    [
      Giải thích nguyên lý cơ bản của mạch cầu H trong điều khiển chiều quay và
      vai trò của PWM trong điều khiển mức tác động lên động cơ.
    ],

    [
      Sử dụng các API `DCMotor_Init()`,`DCMotor_SetSpeed()`,`DCMotor_Forward()`,`DCMotor_Reverse()` và `DCMotor_Stop()`.
    ],

    [
      Xây dựng và kiểm chứng chương trình điều khiển động cơ theo chuỗi
      quay thuận → dừng → quay nghịch → dừng.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Động cơ DC

Động cơ DC là một cơ cấu chấp hành chuyển đổi năng lượng điện một chiều thành
chuyển động quay. Trong một hệ thống điều khiển cơ bản, thay đổi cực tính đặt
lên hai đầu động cơ làm thay đổi chiều dòng qua động cơ và từ đó thay đổi chiều
quay. Vì vậy, ứng dụng cần một tầng công suất có khả năng điều khiển dòng theo
hai hướng thay vì chỉ sử dụng một đầu ra số đơn lẻ
#cite-ref(refs, "purdue-actuators").

Đối với điều khiển tốc độ theo phương pháp vòng hở, PWM có thể được sử dụng để
thay đổi mức công suất trung bình cung cấp cho động cơ. Tốc độ cơ học thực tế
không chỉ phụ thuộc vào giá trị PWM mà còn phụ thuộc vào đặc tính của động cơ,
nguồn cấp và tải cơ học #cite-ref(refs, "ut-motor-pwm").

== Module điều khiển động cơ kiểu cầu H

Mạch cầu H là cấu trúc được sử dụng phổ biến để điều khiển chiều quay của động
cơ DC. Bằng cách thay đổi trạng thái của các nhánh công suất, cực tính điện áp
đặt lên hai đầu động cơ có thể được đảo để tạo hai chiều quay
#cite-ref(refs, "purdue-actuators").

Một module điều khiển động cơ kiểu cầu H thường cung cấp các nhóm tín hiệu:

- tín hiệu lựa chọn chiều quay;
- tín hiệu PWM để điều khiển mức tác động;
- tín hiệu kích hoạt hoặc chế độ chờ, tùy từng loại module.

Tên chân, mức logic và cách tổ chức tín hiệu có thể khác nhau giữa các module.
Vì vậy, khi thay TB6612FNG bằng một module khác, cần đối chiếu tài liệu kỹ thuật
của module đó trước khi kết nối.

Trong phần cứng mẫu của bài lab, TB6612FNG được sử dụng làm ví dụ điển hình.
Kênh A của module nhận bốn tín hiệu chính:

- `AIN1` và `AIN2`: lựa chọn trạng thái và chiều quay;
- `PWMA`: đầu vào PWM của kênh A;
- `STBY`: kích hoạt module hoặc đưa module về chế độ chờ.

Khi `STBY` ở trạng thái hoạt động và `PWMA` cho phép ngõ ra, quan hệ cơ bản giữa
`AIN1`, `AIN2` và trạng thái của kênh A có thể tóm tắt như sau
#cite-ref(refs, "toshiba-tb6612fng"):

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1fr, 2.2fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*AIN1*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*AIN2*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Trạng thái*]
      ],
    ),

    [`HIGH`], [`LOW`], [Quay theo một chiều.],
    [`LOW`], [`HIGH`], [Quay theo chiều ngược lại.],
    [`LOW`], [`LOW`], [Dừng với ngõ ra ở trạng thái trở kháng cao.],
    [`HIGH`], [`HIGH`], [Phanh ngắn mạch.],
  )
]

Hai API `DCMotor_Forward()` và `DCMotor_Reverse()` biểu diễn hai cấu hình điều
khiển đối nghịch. Chiều quay vật lý quan sát được còn phụ thuộc vào cách hai đầu
động cơ được nối với `AO1` và `AO2`.

== Điều khiển tốc độ bằng PWM

Nguyên lý PWM, chu kỳ và chu kỳ công tác đã được giới thiệu trong Lab 05 nên
không được lặp lại chi tiết trong bài lab này. Trong điều khiển động cơ, PWM
được đưa tới đầu vào điều khiển của module để thay đổi mức tác động trung bình
lên tải. PWM và mạch cầu H thường được kết hợp để điều khiển tốc độ và chiều
quay của động cơ DC
#cite-ref(refs, "purdue-actuators") #cite-ref(refs, "ut-motor-pwm").

API thiết bị động cơ DC của EduFramework sử dụng miền điều khiển từ `0` đến
`255` #cite-ref(refs, "eduframework-dc-motor"):

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1.3fr, 2.1fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Giá trị*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Mức điều khiển*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Ý nghĩa*]
      ],
    ),

    [`0`], [`0%`], [Không tạo mức điều khiển tốc độ.],
    [`64`], [xấp xỉ `25%`], [Mức điều khiển thấp.],
    [`128`], [xấp xỉ `50%`], [Mức giữa của miền điều khiển.],
    [`191`], [xấp xỉ `75%`], [Mức điều khiển cao.],
    [`255`], [`100%`], [Mức điều khiển lớn nhất.],
  )
]

Các tỷ lệ trên mô tả giá trị lệnh trong miền điều khiển, không phải tỷ lệ tốc độ
quay thực tế của động cơ.


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng MaaZEDU Development Board để tạo tín hiệu điều khiển, một module
điều khiển động cơ kiểu cầu H làm tầng công suất và một động cơ DC làm tải. Nguồn ngoài được
dùng để cấp năng lượng cho động cơ.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],

  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),

    (
      [Module điều khiển động cơ TB6612FNG],
      [
        Module cầu H được sử dụng làm ví dụ để điều khiển tốc độ và chiều quay
        của động cơ DC.
      ],
    ),

    (
      [Động cơ DC],
      [Động cơ một chiều được sử dụng làm tải trong bài thực hành.],
    ),

    (
      [Nguồn ngoài cho động cơ],
      [Nguồn riêng cấp cho đường `VM` của module điều khiển.],
    ),

    (
      [Dây nối],
      [Kết nối nguồn và các tín hiệu điều khiển giữa các khối phần cứng.],
    ),

    (
      [Cáp USB],
      [Kết nối MaaZEDU với máy tính để cấp nguồn logic và nạp chương trình.],
    ),
  ),
)

== Ánh xạ chân điều khiển

API động cơ DC hiện tại của EduFramework sử dụng bốn tín hiệu: PWM, hai tín hiệu
điều khiển chiều và một tín hiệu chế độ chờ. Trong cấu hình mẫu với TB6612FNG,
`GPIO2` đến `GPIO5` được nối lần lượt tới `PWMA`, `AIN1`, `AIN2` và `STBY`.

Theo MaaZEDU Development Board Guide, các chân logic này lần lượt được ánh xạ
tới `PTD14`, `PTD13`, `PTD12` và `PTD11`
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Ánh xạ chân trong cấu hình mẫu sử dụng TB6612FNG],

  rows: (
    (
      [PWMA],
      "GPIO2",
      "PTD14",
      [Đầu ra PWM],
    ),

    (
      [AIN1],
      "GPIO3",
      "PTD13",
      [Đầu ra số],
    ),

    (
      [AIN2],
      "GPIO4",
      "PTD12",
      [Đầu ra số],
    ),

    (
      [STBY],
      "GPIO5",
      "PTD11",
      [Đầu ra số],
    ),
  ),
)

#note[
  Nếu sử dụng một module điều khiển động cơ khác, cần xác định các chân có chức
  năng tương đương và kiểm tra mức logic điều khiển theo tài liệu kỹ thuật của
  module. Không nên giả định mọi module có cùng tên chân hoặc cùng bảng trạng
  thái với TB6612FNG.
]

== Nguồn logic và nguồn động cơ

Một số module điều khiển động cơ sử dụng riêng nguồn logic và nguồn công suất.
Đối với TB6612FNG, `VCC` cấp nguồn cho phần logic điều khiển, trong khi `VM` cấp
nguồn cho tầng công suất động cơ. Datasheet quy định dải hoạt động của `VCC` là
`2.7 V` đến `5.5 V` và `VM` là `2.5 V` đến `13.5 V`
#cite-ref(refs, "toshiba-tb6612fng").

Trong cấu hình mẫu của bài lab:

- `VCC` của TB6612FNG được nối với `3.3V` từ MaaZEDU;
- `VM` được nối với nguồn ngoài phù hợp với động cơ sử dụng;
- GND của MaaZEDU, TB6612FNG và nguồn động cơ phải được nối chung;
- `AO1` và `AO2` được nối tới hai đầu của động cơ DC.

#note[
  Điện áp nguồn ngoài phải phù hợp với điện áp định mức của động cơ và nằm trong
  giới hạn cho phép của module điều khiển. Tắt nguồn động cơ trước khi thay đổi
  các kết nối phần cứng.
]

== Sơ đồ kết nối

Sơ đồ dưới đây minh họa cách sử dụng TB6612FNG làm module điều khiển động cơ
trong bài thực hành. MaaZEDU tạo các tín hiệu điều khiển, TB6612FNG đảm nhiệm
tầng công suất và nguồn ngoài cung cấp năng lượng cho động cơ.

#figure-block(
  caption: [Sơ đồ kết nối mẫu sử dụng MaaZEDU, TB6612FNG và động cơ DC],
)[
  #image(
    "../assets/circuits/dc_motor_control_circuit.png",
    width: 100%,
  )
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài lab sử dụng API thiết bị động cơ DC của EduFramework để điều khiển động cơ
ở mức ứng dụng. Các thao tác PWM và đầu ra số cần thiết cho module điều khiển
được thực hiện bên trong lớp thiết bị, vì vậy chương trình không cần thao tác
trực tiếp với từng chân điều khiển
#cite-ref(refs, "eduframework-dc-motor").

API hiện tại được xây dựng theo giao diện gồm một chân PWM, hai chân điều khiển
chiều và một chân chế độ chờ.

== `DCMotor_Init()`

`DCMotor_Init()` khởi tạo các chân cần thiết cho module điều khiển động cơ. Sau
khi khởi tạo, động cơ ở trạng thái dừng và module được kích hoạt.

#api-detail(
  name: "DCMotor_Init",

  syntax: [DCMotor_Init(pwmPin, in1Pin, in2Pin, stbyPin);],

  description: [
    Khởi tạo giao diện điều khiển một động cơ DC thông qua module điều khiển
    động cơ.
  ],

  parameters: (
    (
      [pwmPin],
      [Chân logic hỗ trợ PWM],
      [Chân nối tới đầu vào PWM của module điều khiển.],
    ),

    (
      [in1Pin],
      [Chân logic],
      [Chân nối tới đầu vào điều khiển chiều thứ nhất.],
    ),

    (
      [in2Pin],
      [Chân logic],
      [Chân nối tới đầu vào điều khiển chiều thứ hai.],
    ),

    (
      [stbyPin],
      [Chân logic],
      [Chân nối tới đầu vào chế độ chờ của module điều khiển.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ với TB6612FNG:

```c
DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);
```

== `DCMotor_SetSpeed()`

`DCMotor_SetSpeed()` thiết lập mức điều khiển tốc độ theo miền `0` đến `255`.
Hàm chỉ thay đổi mức PWM và không tự thay đổi chiều quay hiện tại.

#api-detail(
  name: "DCMotor_SetSpeed",

  syntax: [DCMotor_SetSpeed(speed);],

  description: [
    Thiết lập mức điều khiển tốc độ của động cơ.
  ],

  parameters: (
    (
      [speed],
      [`0` đến `255`],
      [
        Giá trị điều khiển tốc độ. `0` là mức thấp nhất và `255` là mức lớn
        nhất của miền điều khiển.
      ],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
DCMotor_SetSpeed(128U);
```

Giá trị `128` tương ứng xấp xỉ `50%` miền điều khiển.

== `DCMotor_Forward()`

`DCMotor_Forward()` đặt module vào cấu hình quay thuận và áp dụng mức tốc độ đã
được thiết lập trước đó.

#api-detail(
  name: "DCMotor_Forward",

  syntax: [DCMotor_Forward();],

  description: [
    Điều khiển động cơ quay theo chiều thuận.
  ],

  parameters: (),

  returns: [Không trả về giá trị.],
)

Chiều quay vật lý thực tế phụ thuộc vào cách hai đầu động cơ được nối với ngõ
ra của module điều khiển.

== `DCMotor_Reverse()`

`DCMotor_Reverse()` đặt module vào cấu hình đối nghịch với quay thuận.

#api-detail(
  name: "DCMotor_Reverse",

  syntax: [DCMotor_Reverse();],

  description: [
    Điều khiển động cơ quay theo chiều nghịch.
  ],

  parameters: (),

  returns: [Không trả về giá trị.],
)

== `DCMotor_Stop()`

`DCMotor_Stop()` đưa mức điều khiển PWM về `0` và đưa các chân điều khiển chiều
về trạng thái dừng. Với cấu hình mẫu TB6612FNG, động cơ được dừng theo kiểu thả
trôi #cite-ref(refs, "toshiba-tb6612fng")
#cite-ref(refs, "eduframework-dc-motor").

#api-detail(
  name: "DCMotor_Stop",

  syntax: [DCMotor_Stop();],

  description: [
    Dừng động cơ theo kiểu thả trôi.
  ],

  parameters: (),

  returns: [Không trả về giá trị.],
)


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình điều khiển động cơ DC thông qua module điều khiển động cơ.

- Khởi tạo giao diện điều khiển với `GPIO2`, `GPIO3`, `GPIO4` và `GPIO5`.
- Thiết lập mức điều khiển tốc độ bằng `128`, tương ứng xấp xỉ `50%`.
- Quay thuận trong `3000 ms`.
- Dừng động cơ trong `2000 ms`.
- Quay nghịch trong `3000 ms`.
- Dừng động cơ trong `2000 ms`.
- Lặp lại chuỗi hoạt động liên tục.

== Chương trình

Trong `src/main.c`, triển khai chương trình như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình điều khiển động cơ DC bằng EduFramework],
  )[
    ```c
    #include "Arduino.h"
    #include "dc_motor.h"

    int main(void)
    {
        setup();

        DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);

        while (1)
        {
            DCMotor_SetSpeed(128U);
            DCMotor_Forward();
            delay(3000U);

            DCMotor_Stop();
            delay(2000U);

            DCMotor_SetSpeed(128U);
            DCMotor_Reverse();
            delay(3000U);

            DCMotor_Stop();
            delay(2000U);
        }

        return 0;
    }
    ```
  ]
]

== Giải thích chương trình

`setup()` khởi tạo các thành phần nền tảng của EduFramework. Sau đó,
`DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5)` cấu hình bốn chân điều khiển được
API động cơ DC sử dụng. Trong cấu hình mẫu TB6612FNG, các chân này tương ứng
với `PWMA`, `AIN1`, `AIN2` và `STBY`.

Trong vòng lặp chính, `DCMotor_SetSpeed(128U)` thiết lập mức điều khiển khoảng
một nửa miền `0..255`. `DCMotor_Forward()` đặt module vào cấu hình quay thuận
và động cơ duy trì trạng thái này trong `3000 ms`.

Sau đó, `DCMotor_Stop()` đưa động cơ về trạng thái dừng thả trôi trong
`2000 ms`. Chương trình tiếp tục thiết lập cùng mức tốc độ, gọi
`DCMotor_Reverse()` để đổi chiều điều khiển và giữ trạng thái quay nghịch trong
`3000 ms`. Động cơ được dừng thêm `2000 ms` trước khi chu kỳ tiếp theo bắt đầu.

Luồng hoạt động của chương trình có thể tóm tắt:

`Quay thuận 50%` → `Dừng` → `Quay nghịch 50%` → `Dừng` → lặp lại.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Cấp nguồn ngoài cho
module điều khiển động cơ và quan sát động cơ trong nhiều chu kỳ liên tiếp.

Kiểm tra lần lượt các trạng thái:

- Động cơ quay theo một chiều trong khoảng `3 s`.
- Động cơ thả trôi về trạng thái dừng và giữ trạng thái này khoảng `2 s`.
- Động cơ quay theo chiều ngược lại trong khoảng `3 s`.
- Động cơ tiếp tục dừng khoảng `2 s` trước khi chu kỳ được lặp lại.

#expected-result[
  Động cơ DC lặp lại liên tục chuỗi quay thuận → dừng → quay nghịch → dừng.
  Hai trạng thái quay sử dụng cùng mức điều khiển `128`, tương ứng xấp xỉ
  `50%` miền điều khiển của API thiết bị động cơ DC. Mỗi trạng thái quay kéo
  dài khoảng `3 s` và mỗi trạng thái dừng kéo dài khoảng `2 s`.
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính sử dụng một mức tốc độ và phương pháp dừng thả trôi để tập
trung vào cách điều khiển cơ bản. API thiết bị động cơ DC còn cung cấp các chức
năng cho phép khảo sát thêm nhiều trạng thái điều khiển khác.

== Thay đổi mức tốc độ

Thay giá trị `128` trong chương trình bằng các mức khác nhau và quan sát sự thay
đổi tương đối của tốc độ động cơ:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1.4fr, 2.1fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Giá trị*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Mức điều khiển*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Yêu cầu quan sát*]
      ],
    ),

    [`64`], [xấp xỉ `25%`], [Mức quay thấp.],
    [`128`], [xấp xỉ `50%`], [Mức sử dụng trong bài chính.],
    [`191`], [xấp xỉ `75%`], [Mức quay cao hơn.],
    [`255`], [`100%`], [Mức điều khiển lớn nhất.],
  )
]

*Mở rộng:* Thay đổi lần lượt bốn giá trị trên trong cùng một chiều quay và quan
sát xu hướng thay đổi. Không cần đo RPM; phần đo tốc độ thực tế bằng encoder
được thực hiện trong Lab 15.

== Dừng thả trôi và phanh ngắn mạch

TB6612FNG hỗ trợ cả trạng thái dừng thả trôi và phanh ngắn mạch
#cite-ref(refs, "toshiba-tb6612fng"). Trong EduFramework:

- `DCMotor_Stop()` sử dụng phương pháp dừng thả trôi;
- `DCMotor_Brake()` sử dụng trạng thái phanh ngắn mạch.

Cú pháp:

```c
DCMotor_Stop();
DCMotor_Brake();
```

#api-detail(
  name: "DCMotor_Brake",

  syntax: [DCMotor_Brake();],

  description: [
    Dừng động cơ bằng trạng thái phanh ngắn mạch của mạch cầu H.
  ],

  parameters: (),

  returns: [Không trả về giá trị.],
)

*Mở rộng:* Cho động cơ quay ở cùng một mức tốc độ, sau đó thử riêng
`DCMotor_Stop()` và `DCMotor_Brake()`. Quan sát sự khác nhau giữa hai cách dừng
mà không thay đổi phần cứng.

== Chế độ chờ

Chân `STBY` của TB6612FNG cho phép đưa module về chế độ chờ và tắt các ngõ ra
công suất #cite-ref(refs, "toshiba-tb6612fng"). EduFramework cung cấp
`DCMotor_Standby()` để điều khiển trạng thái này.

#api-detail(
  name: "DCMotor_Standby",

  syntax: [DCMotor_Standby(standby);],

  description: [
    Kích hoạt module điều khiển hoặc đưa module về chế độ chờ.
  ],

  parameters: (
    (
      [standby],
      [`0` / khác `0`],
      [
        `0` để kích hoạt module; giá trị khác `0` để đưa module về chế độ chờ.
      ],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
DCMotor_Standby(1U);
delay(2000U);
DCMotor_Standby(0U);
```

*Mở rộng:* Bổ sung một khoảng chế độ chờ vào chuỗi điều khiển và kiểm tra rằng
động cơ không được cấp điều khiển trong khoảng thời gian module ở chế độ chờ.


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
