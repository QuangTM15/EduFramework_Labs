#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 16 - Điều khiển động cơ BLDC
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "mit-bldc",
    type: "web",
    author: [James L. Kirtley Jr.],
    title: [Course Notes 7: Permanent Magnet "Brushless DC" Motors],
    source: [MIT OpenCourseWare - 6.685 Electric Machines],
    year: [2013],
    url: "https://ocw.mit.edu/courses/6-685-electric-machines-fall-2013/resources/mit6_685f13_chapter7/",
  ),
  (
    key: "ieee-bldc-review",
    type: "web",
    author: [Deepak Mohanraj et al.],
    title: [A Review of BLDC Motor: State of Art, Advanced Control Techniques, and Applications],
    source: [IEEE Access, Vol. 10, pp. 54833-54869],
    year: [2022],
    url: "https://doi.org/10.1109/ACCESS.2022.3175011",
  ),
  (
    key: "fab-esc",
    type: "web",
    author: [Luc Hanneuse],
    title: [Output Devices - Brushless Motor and ESC],
    source: [Fab Academy - Sorbonne Lab],
    year: [2019],
    url: "https://fabacademy.org/2019/labs/sorbonne/students/hanneuse-luc/assignments/week12/",
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
    key: "arduino-language",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
  ),
  (
    key: "eduframework-esc",
    type: "web",
    author: [EduFramework],
    title: [ESC Device API],
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
  number: 16,
  language: "vi",
  title: [Điều khiển động cơ BLDC],
  subtitle: [Điều khiển BLDC thông qua ESC với EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Động cơ BLDC (Brushless DC Motor) sử dụng chuyển mạch điện tử thay cho chổi than
và cổ góp cơ khí #cite-ref(refs, "mit-bldc") #cite-ref(refs, "ieee-bldc-review").
Trong hệ thống của bài lab, bộ điều khiển tốc độ điện tử (Electronic Speed
Controller - ESC) đảm nhiệm việc chuyển mạch và điều khiển công suất cho động cơ.
S32K144 không điều khiển trực tiếp các pha của động cơ mà gửi tín hiệu điều khiển
tới ESC.

Bài lab tập trung vào việc sử dụng API điều khiển ESC của EduFramework để khởi tạo,
thực hiện quá trình khởi động an toàn (arming) và thay đổi mức ga (throttle), qua đó
điều khiển hoạt động của động cơ BLDC.

== Mục tiêu

#objectives(
  items: (
    [Mô tả vai trò của BLDC và Electronic Speed Controller trong hệ thống điều khiển động cơ.],
    [Giải thích ý nghĩa của throttle command và quá trình arming ESC.],
    [Kết nối MaaZEDU, ESC, nguồn ngoài và động cơ BLDC đúng cấu hình thực hành.],
    [Sử dụng `ESC_Init()`, `ESC_Arm()` và `ESC_SetThrottle()` để điều khiển BLDC.],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== BLDC và Electronic Speed Controller

BLDC sử dụng rotor nam châm vĩnh cửu và các cuộn dây trên stator. Do không có
chổi than cơ khí, dòng điện trong các cuộn dây cần được chuyển mạch bằng mạch
điện tử để tạo mô-men quay #cite-ref(refs, "mit-bldc") #cite-ref(refs, "ieee-bldc-review").

Trong bài lab, nhiệm vụ này được thực hiện bởi ESC. S32K144 không điều khiển trực
tiếp ba đầu `U`, `V`, `W`; board chỉ gửi lệnh điều khiển tới ESC. ESC nhận nguồn
công suất riêng qua `B+`, `B-` và điều khiển ba pha nối tới động cơ
#cite-ref(refs, "fab-esc").

#note[
  Nguồn công suất của động cơ không được lấy trực tiếp từ GPIO của MaaZEDU.
  Nguồn ngoài phải phù hợp với ESC và động cơ đang sử dụng.
]

== Throttle command và arming

EduFramework sử dụng lệnh throttle từ `0%` đến `100%`. Với cấu hình mặc định,
`0%` tương ứng pulse width `1000 µs` và `100%` tương ứng `2000 µs`; các giá trị
trung gian được ánh xạ tuyến tính trong khoảng này #cite-ref(refs, "eduframework-esc").

Throttle percentage là giá trị lệnh gửi tới ESC, không phải phần trăm tốc độ quay
thực tế. RPM còn phụ thuộc vào động cơ, ESC, nguồn, tải và điều kiện vận hành.
Nếu cần tốc độ thực tế, hệ thống phải sử dụng cơ chế đo như encoder.

Trước khi điều khiển motor, ESC cần được đưa về trạng thái khởi động an toàn.
Trong EduFramework, `ESC_Arm()` gửi minimum throttle và giữ trạng thái đó
trong `3000 ms` trước khi chương trình tiếp tục #cite-ref(refs, "eduframework-esc").


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng MaaZEDU Development Board với vi điều khiển S32K144 thuộc họ
S32K1xx #cite-ref(refs, "nxp-s32k-datasheet"). ESC được cấp nguồn riêng và điều
khiển động cơ BLDC thông qua ba đầu ra pha.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [Electronic Speed Controller],
      [Nhận RC PWM và điều khiển phần công suất của động cơ BLDC.],
    ),
    (
      [BLDC Motor],
      [Động cơ ba dây pha được kết nối với các đầu `U`, `V`, `W` của ESC.],
    ),
    (
      [External DC Power Supply],
      [Nguồn ngoài phù hợp với ESC và động cơ đang sử dụng.],
    ),
    (
      [Jumper wires],
      [Kết nối GPIO2 và GND giữa MaaZEDU với ESC.],
    ),
    (
      [USB Cable],
      [Kết nối board với máy tính để nạp chương trình.],
    ),
  ),
)

== Ánh xạ chân điều khiển

Bài thực hành sử dụng `GPIO2` làm chân điều khiển ESC. Trên MaaZEDU,
`GPIO2` được ánh xạ tới `PTD14` #cite-ref(refs, "maazedu-guide"). EduFramework
xác nhận Logical Pin này hỗ trợ chức năng PWM cần thiết cho ESC
#cite-ref(refs, "eduframework-esc").

#pin-table(
  caption: [Ánh xạ tín hiệu điều khiển ESC],
  rows: (
    (
      [ESC PWM input],
      "GPIO2",
      "PTD14",
      [Tín hiệu điều khiển ESC],
    ),
  ),
)

== Kết nối ESC và động cơ

`GPIO2` được nối tới chân `PWM` của ESC và GND của MaaZEDU được nối tới GND
phía điều khiển của ESC. Nguồn ngoài được nối tới `B+` và `B-`. Ba đầu ra
`U`, `V`, `W` của ESC được nối trực tiếp tới ba dây của động cơ BLDC.

#figure-block(
  caption: [Sơ đồ kết nối MaaZEDU, ESC và động cơ BLDC],
)[
  #image(
    "../assets/circuits/bldc_motor_esc_circuit.png",
    width: 88%,
  )
]

#note[
  Ngắt nguồn công suất trước khi thay đổi dây nối. Cố định động cơ trước khi chạy
  và bắt đầu kiểm chứng ở mức throttle thấp. Không cấp nguồn nếu chưa xác nhận
  điện áp và khả năng cấp dòng phù hợp với ESC và động cơ.
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài thực hành chính sử dụng ba API của ESC Device: khởi tạo, arming và đặt
throttle #cite-ref(refs, "eduframework-esc").

== `ESC_Init()`

#api-detail(
  name: "ESC_Init",
  syntax: [ESC_Init(pin);],
  description: [Khởi tạo ESC trên một Logical Pin hỗ trợ PWM.],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân điều khiển ESC, trong bài lab sử dụng `GPIO2`.],
    ),
  ),
  returns: [
    `true` nếu khởi tạo thành công; `false` nếu chân không phù hợp hoặc quá trình
    khởi tạo thất bại.
  ],
)

== `ESC_Arm()`

#api-detail(
  name: "ESC_Arm",
  syntax: [ESC_Arm();],
  description: [Gửi minimum throttle và thực hiện khoảng arming của ESC.],
  parameters: (),
  returns: [Không trả về giá trị.],
)

Trong EduFramework, quá trình arming kéo dài `3000 ms` và hàm là blocking.

== `ESC_SetThrottle()`

#api-detail(
  name: "ESC_SetThrottle",
  syntax: [ESC_SetThrottle(percent);],
  description: [Gửi throttle command tới ESC theo phần trăm.],
  parameters: (
    (
      [percent],
      [Throttle],
      [Giá trị từ `0%` tới `100%`; giá trị lớn hơn `100%` được giới hạn về `100%`.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

`ESC_SetThrottle()` điều khiển giá trị command gửi tới ESC; API này không đo RPM
thực tế của động cơ.


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình điều khiển động cơ BLDC thông qua ESC nối với `GPIO2`.
Sau khi khởi tạo và arming, chương trình thay đổi throttle theo chuỗi:

`20%` → `40%` → `60%` → `40%` → `20%` → `0%`

Mỗi mức throttle được giữ trong `3000 ms`. Sau khi trở về `0%`, chuỗi được lặp
lại liên tục. Mục tiêu là quan sát phản ứng của động cơ khi throttle command tăng
và giảm, không yêu cầu đo RPM trong bài thực hành này.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình điều khiển BLDC theo chuỗi throttle],
  )[
    ```c
    #include "Arduino.h"
    #include "esc.h"

    int main(void)
    {
        setup();

        ESC_Init(GPIO2);
        ESC_Arm();

        while (1)
        {
            ESC_SetThrottle(20U);
            delay(3000U);

            ESC_SetThrottle(40U);
            delay(3000U);

            ESC_SetThrottle(60U);
            delay(3000U);

            ESC_SetThrottle(40U);
            delay(3000U);

            ESC_SetThrottle(20U);
            delay(3000U);

            ESC_SetThrottle(0U);
            delay(3000U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo EduFramework. `ESC_Init(GPIO2)` chuẩn bị đường điều khiển,
`ESC_Arm()` thực hiện arming, sau đó `ESC_SetThrottle()` lần lượt gửi các mức
throttle đã quy định. `delay(3000U)` giữ mỗi mức trong ba giây để dễ quan sát
#cite-ref(refs, "arduino-language").

Bài thực hành không sử dụng encoder feedback nên chỉ kiểm chứng phản ứng của motor
theo command, không xác định RPM thực tế.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU. Kiểm tra `GPIO2`, GND, `B+`, `B-` và
ba dây `U/V/W` trước khi cấp nguồn công suất. Sau arming, quan sát motor khi
throttle tăng từ `20%` tới `60%` rồi giảm về `0%`.

#block(breakable: false)[
  #expected-result[
    ESC hoàn thành quá trình arming trước khi motor nhận chuỗi throttle. Động cơ
    phản ứng theo các mức command `20%`, `40%`, `60%`, sau đó giảm về `40%`,
    `20%` và dừng ở `0%`. Chuỗi được lặp lại liên tục. Kết quả cần thể hiện sự
    thay đổi ổn định theo command, không yêu cầu quan hệ tuyến tính giữa throttle
    percentage và RPM thực tế.
  ]
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bên cạnh ba API sử dụng trong bài chính, EduFramework cung cấp thêm các
API để cấu hình và theo dõi command của ESC #cite-ref(refs, "eduframework-esc").

#info-table(
  columns: (1.5fr, 2.8fr),
  alignments: (
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Mục đích],
  ),
  rows: (
    (
      [`ESC_SetPulseRange()`],
      [Thay đổi minimum và maximum pulse dùng để ánh xạ `0%` đến `100%` throttle.],
    ),
    (
      [`ESC_SetMicroseconds()`],
      [Gửi trực tiếp pulse width theo microsecond trong khoảng đã cấu hình.],
    ),
    (
      [`ESC_GetThrottle()`],
      [Đọc lại throttle command gần nhất được lưu trong phần mềm.],
    ),
    (
      [`ESC_GetMicroseconds()`],
      [Đọc lại pulse width command gần nhất.],
    ),
    (
      [`ESC_IsInitialized()`],
      [Kiểm tra ESC Device đã được khởi tạo hay chưa.],
    ),
    (
      [`ESC_End()`],
      [Dừng output do ESC Device quản lý và reset trạng thái nội bộ.],
    ),
  ),
  caption: [Các ESC API nâng cao],
)

#note[
  Các hàm `ESC_GetThrottle()` và `ESC_GetMicroseconds()` chỉ trả về command đã
  gửi, không phải tốc độ hoặc phản hồi vật lý từ động cơ. `ESC_SetPulseRange()`
  chỉ nên thay đổi khi khoảng điều khiển của ESC thực tế đã được xác định.
]

== Bài tập mở rộng

Thay chuỗi throttle cố định bằng potentiometer nối tới Analog Input. Đọc giá trị
ADC, quy đổi thành throttle command trong một giới hạn phù hợp, sau đó sử dụng
`ESC_SetThrottle()` để điều khiển động cơ.

`Potentiometer` → `analogRead()` → `scale ADC` → `ESC_SetThrottle()` → `BLDC`


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
