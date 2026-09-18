#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 07 - Cơ bản về Tone
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "umn-pitch",
    type: "web",
    author: [University of Minnesota],
    title: [Pitch is Frequency],
    source: [Introduction to Sensation and Perception],
    url: "https://pressbooks.umn.edu/sensationandperception/chapter/pitch-is-frequency/",
  ),

  (
    key: "usc-buzzer",
    type: "web",
    author: [University of Southern California],
    title: [EE 109 Unit H - Timers],
    source: [EE 109 - Introduction to Embedded Systems],
    url: "https://bytes.usc.edu/files/ee109/slides/EE109UnitH_Ultrasonic.pdf",
  ),

  (
    key: "augusta-buzzer",
    type: "manual",
    author: [Augusta University],
    title: [PHYS 1111L Laboratory Manual],
    source: [PHYS 1111L],
    year: [2023],
    url: "https://spots.augusta.edu/tcolbert/PHYS1111L-Lab/Spring2023/PHYS1111L_LabManual.pdf",
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
    key: "eduframework-tone",
    type: "web",
    author: [EduFramework],
    title: [Tone, PWM and Logical Pin API],
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
  number: 7,
  language: "vi",
  title: [Cơ bản về Tone],
  subtitle: [Tạo âm thanh với Passive Buzzer bằng EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Âm thanh thường được sử dụng trong hệ thống nhúng để báo trạng thái, phát cảnh
báo hoặc cung cấp phản hồi cho người sử dụng. Với passive buzzer, âm thanh có
thể được tạo bằng một tín hiệu tuần hoàn; thay đổi tần số của tín hiệu làm thay
đổi cao độ nghe được #cite-ref(refs, "usc-buzzer")
#cite-ref(refs, "augusta-buzzer").

Bài lab này giới thiệu cách tạo các tone đơn giản bằng EduFramework. Passive
buzzer được kết nối với `GPIO7`, sau đó chương trình lần lượt phát các tần số
khác nhau để tạo một chuỗi âm có cao độ tăng dần. Nội dung tập trung vào ba yếu
tố chính: tín hiệu tuần hoàn, quan hệ giữa tần số và cao độ, và cách điều khiển
buzzer bằng API của framework.

== Mục tiêu

#objectives(
  items: (
    [
      Giải thích nguyên lý cơ bản của việc tạo âm thanh bằng passive buzzer.
    ],

    [
      Mô tả mối quan hệ giữa chu kỳ, tần số và cao độ của âm thanh.
    ],

    [
      Sử dụng `tone()` và `noTone()` để điều khiển tone bằng EduFramework.
    ],

    [
      Xây dựng và kiểm chứng chương trình phát một chuỗi âm liên tiếp trên
      passive buzzer.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Passive Buzzer và tín hiệu điều khiển

Passive buzzer không tự tạo một tone cố định khi được cấp một mức logic không
đổi. Để phát âm, buzzer cần được kích bằng một tín hiệu thay đổi tuần hoàn theo
thời gian. Trong các bài thực hành hệ thống nhúng, tín hiệu vuông là một cách
phổ biến để tạo tín hiệu kích này #cite-ref(refs, "usc-buzzer")
#cite-ref(refs, "augusta-buzzer").

Tín hiệu vuông luân phiên giữa hai mức logic. Khi quá trình chuyển mức được lặp
lại đều đặn, tín hiệu có một tần số xác định. Bằng cách thay đổi tần số điều
khiển, cùng một buzzer có thể phát ra các tone có cao độ khác nhau
#cite-ref(refs, "usc-buzzer").

Trong phạm vi bài lab, buzzer được sử dụng như một thiết bị phát âm đơn giản.
Các đặc tính chuyên sâu như đáp tuyến tần số, mức áp suất âm hoặc mô hình điện
của phần tử buzzer không được xét đến.

== Chu kỳ và tần số

Một tín hiệu tuần hoàn lặp lại sau một khoảng thời gian xác định. Khoảng thời
gian để hoàn thành một lần lặp được gọi là chu kỳ và thường ký hiệu là $T$.
Tần số cho biết số chu kỳ xảy ra trong một giây và được biểu diễn bằng đơn vị
hertz (Hz) #cite-ref(refs, "umn-pitch").

Đối với một tín hiệu tuần hoàn, tần số và chu kỳ có quan hệ nghịch đảo:

$ f = 1 / T $

Trong đó:

- $f$ là tần số, đơn vị hertz.
- $T$ là chu kỳ, đơn vị giây.

Vì vậy, tần số càng lớn thì thời gian của một chu kỳ càng ngắn. Ví dụ, một tín
hiệu `500 Hz` lặp lại nhanh hơn một tín hiệu `250 Hz`, nên khoảng thời gian giữa
các chu kỳ của tín hiệu `500 Hz` nhỏ hơn.

== Tần số và cao độ

Cao độ là cảm nhận cho biết một âm nghe cao hay thấp. Đối với các tone tuần
hoàn đơn giản, cao độ có quan hệ chặt chẽ với tần số: tần số tăng làm cao độ
cảm nhận tăng, còn tần số giảm làm cao độ cảm nhận giảm
#cite-ref(refs, "umn-pitch").

Quan hệ này là cơ sở của bài thực hành. Khi buzzer lần lượt nhận các tín hiệu có
tần số tăng dần, chuỗi âm nghe được cũng tăng dần về cao độ
#cite-ref(refs, "usc-buzzer").

#info-table(
  columns: (1.4fr, 1.6fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Tần số],
    [Chu kỳ],
    [Cao độ cảm nhận],
  ),
  rows: (
    (
      [Thấp hơn],
      [Dài hơn],
      [Âm có cao độ thấp hơn.],
    ),
    (
      [Cao hơn],
      [Ngắn hơn],
      [Âm có cao độ cao hơn.],
    ),
  ),
  caption: [Quan hệ định tính giữa tần số, chu kỳ và cao độ],
)

== Tần số và thời lượng của một tone

Tần số xác định cao độ của tone, còn thời lượng xác định tone được duy trì trong
bao lâu. Hai đại lượng này có vai trò khác nhau: một tone có thể giữ nguyên tần
số nhưng được phát trong thời gian ngắn hoặc dài tùy yêu cầu của ứng dụng. Các
bài thực hành với buzzer thường mô tả riêng tần số theo hertz và thời lượng theo
millisecond #cite-ref(refs, "augusta-buzzer").

Trong Lab 07, mỗi tone được giữ trong `500 ms`. Sau chuỗi tone, buzzer được dừng
trong `1000 ms` để tạo khoảng im lặng trước khi chuỗi bắt đầu lại.


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài lab sử dụng MaaZEDU Development Board với vi điều khiển S32K144 và một
passive buzzer bên ngoài #cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),

    (
      [Passive Buzzer],
      [Thiết bị phát âm được điều khiển bằng tín hiệu tuần hoàn.],
    ),

    (
      [Jumper wires],
      [Kết nối buzzer với board.],
    ),

    (
      [USB Cable],
      [Kết nối board với máy tính để cấp nguồn và nạp chương trình.],
    ),
  ),
)

== Kết nối Passive Buzzer

`GPIO7` là một Logical Pin có khả năng PWM trong EduFramework và được sử dụng
làm đầu ra điều khiển buzzer trong bài thực hành
#cite-ref(refs, "eduframework-tone").

#info-table(
  columns: (1.5fr, 1.2fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Thiết bị],
    [Kết nối],
    [Chức năng],
  ),
  rows: (
    (
      [Passive Buzzer],
      [`GPIO7`],
      [Nhận tín hiệu điều khiển để tạo âm thanh.],
    ),
    (
      [Passive Buzzer],
      [`GND`],
      [Nối về GND của MaaZEDU Development Board.],
    ),
  ),
  caption: [Kết nối Passive Buzzer trong Lab 07],
)

#figure-block(
  caption: [Sơ đồ kết nối Passive Buzzer với GPIO7],
)[
  #image(
    "../assets/circuits/tone_passive_buzzer_circuit.png",
    width: 74%,
  )
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Arduino Language Reference sử dụng `tone()` và `noTone()` cho nhóm thao tác tạo
và dừng tone #cite-ref(refs, "arduino-language-reference"). EduFramework cung
cấp hai API cùng tên với giao diện phù hợp cho MaaZEDU.

== `tone()`

`tone()` bắt đầu tạo tín hiệu vuông với tần số được chỉ định trên một Logical
Pin có khả năng PWM. Trong implementation hiện tại, tín hiệu được tạo với duty
cycle `50%` #cite-ref(refs, "eduframework-tone").

#api-detail(
  name: "tone",
  syntax: [tone(pin, frequency);],
  description: [
    Bắt đầu phát tone ở tần số được chỉ định trên một PWM Logical Pin.
  ],
  parameters: (
    (
      [pin],
      [PWM Logical Pin],
      [
        Chân được sử dụng để điều khiển buzzer, ví dụ `GPIO7`.
      ],
    ),

    (
      [frequency],
      [Tần số (Hz)],
      [
        Tần số của tone cần phát, tính bằng hertz.
      ],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
tone(GPIO7, 440U);
```

Trong EduFramework, `tone()` không có tham số thời lượng. Tín hiệu tiếp tục được
duy trì cho tới khi tần số được thay đổi bằng một lần gọi `tone()` khác hoặc
được dừng bằng `noTone()` #cite-ref(refs, "eduframework-tone"). Vì vậy, thời
lượng của một tone trong bài lab được xác định bằng cách đặt `delay()` sau lời
gọi `tone()`.

`tone()` sử dụng tầng PWM của framework để chuẩn bị đầu ra tương ứng, do đó
chương trình không cần gọi `pinMode(GPIO7, OUTPUT)` trước khi phát tone
#cite-ref(refs, "eduframework-tone").

== `noTone()`

`noTone()` dừng tín hiệu đang được tạo trên Logical Pin được chỉ định
#cite-ref(refs, "eduframework-tone").

#api-detail(
  name: "noTone",
  syntax: [noTone(pin);],
  description: [
    Dừng tone trên PWM Logical Pin được chỉ định.
  ],
  parameters: (
    (
      [pin],
      [PWM Logical Pin],
      [Chân đang được sử dụng để phát tone.],
    ),
  ),
  returns: [Không trả về giá trị.],
)

Ví dụ:

```c
noTone(GPIO7);
```

Trong bài thực hành, API này được gọi sau tone cuối để tạo khoảng im lặng trước
khi chuỗi được lặp lại.

== Lưu ý về tài nguyên PWM

Các channel trong cùng một FTM của S32K1xx sử dụng chung một bộ đếm 16-bit
#cite-ref(refs, "nxp-s32k-cookbook"). Vì tần số đầu ra phụ thuộc vào bộ đếm
chung này, các chức năng cần thiết lập tần số khác nhau không nên được sử dụng
đồng thời trên những pin thuộc cùng một FTM.

Theo bảng ánh xạ PWM hiện tại của EduFramework, các Logical Pin được chia thành
các nhóm sau #cite-ref(refs, "eduframework-tone"):

#info-table(
  columns: (1.2fr, 3.8fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Nhóm PWM],
    [Logical Pin],
  ),
  rows: (
    (
      [Group 1],
      [`LED_RED`, `LED_BLUE`, `LED_GREEN`],
    ),
    (
      [Group 2],
      [`GPIO7`, `GPIO8`],
    ),
    (
      [Group 3],
      [`GPIO2`, `GPIO3`, `GPIO4`, `GPIO5`, `GPIO6`],
    ),
  ),
  caption: [Các nhóm Logical Pin chia sẻ tài nguyên PWM],
)

#note[
  Không sử dụng `tone()` và `analogWrite()` đồng thời trên hai pin thuộc cùng
  một nhóm PWM. Ví dụ, `GPIO7` và `GPIO8` cùng thuộc Group 2. EduFramework
  hiện không thực hiện cơ chế khóa tài nguyên ở runtime, vì vậy việc lựa chọn
  pin phù hợp thuộc về ứng dụng.
]


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình sử dụng passive buzzer trên `GPIO7` để phát một chuỗi âm
có cao độ tăng dần.

Chương trình cần đáp ứng các yêu cầu sau:

- Phát lần lượt bảy tone tương ứng với C, D, E, F, G, A và B.
- Duy trì mỗi tone trong `500 ms`.
- Sau tone cuối, dừng buzzer trong `1000 ms`.
- Lặp lại toàn bộ chuỗi liên tục.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình phát chuỗi tone bằng Passive Buzzer],
  )[
    ```c
    #include "Arduino.h"

    int main(void)
    {
        setup();

        while (1)
        {
            tone(GPIO7, 262U);    /* C */
            delay(500U);

            tone(GPIO7, 294U);    /* D */
            delay(500U);

            tone(GPIO7, 330U);    /* E */
            delay(500U);

            tone(GPIO7, 349U);    /* F */
            delay(500U);

            tone(GPIO7, 392U);    /* G */
            delay(500U);

            tone(GPIO7, 440U);    /* A */
            delay(500U);

            tone(GPIO7, 494U);    /* B */
            delay(500U);

            noTone(GPIO7);
            delay(1000U);
        }

        return 0;
    }
    ```
  ]
]

Mỗi cặp lệnh gồm một giá trị tần số và một khoảng chờ `500 ms`. Khi chương
trình chuyển từ giá trị tần số hiện tại sang giá trị lớn hơn, cao độ nghe được
tăng theo quan hệ giữa frequency và pitch
#cite-ref(refs, "umn-pitch").

Sau `494 Hz`, chương trình dừng tín hiệu trên buzzer và chờ `1000 ms`. Khoảng
im lặng này tạo ranh giới rõ ràng giữa hai lần lặp của chuỗi. Khi vòng lặp bắt
đầu lại, buzzer tiếp tục phát từ tần số đầu tiên.

Các giá trị tần số được viết trực tiếp trong chương trình để phần thực hành tập
trung vào ảnh hưởng của tham số `frequency`. Cách đặt tên các tần số để làm mã
nguồn dễ đọc hơn được giới thiệu trong phần Mở rộng.

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Quan sát âm thanh
phát ra từ passive buzzer và kiểm tra:

- Có bảy tone liên tiếp trong mỗi chuỗi.
- Cao độ tăng dần từ tone đầu tới tone cuối.
- Mỗi tone kéo dài khoảng `500 ms`.
- Sau tone cuối có khoảng im lặng khoảng `1000 ms`.
- Chuỗi được lặp lại liên tục.

#block(breakable: false)[
  #expected-result[
    Passive buzzer phát bảy tone có cao độ tăng dần. Mỗi tone được duy trì
    khoảng `500 ms`. Sau tone cuối, buzzer im lặng khoảng `1000 ms`, sau đó
    chuỗi bắt đầu lại.
  ]
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Khi một chương trình sử dụng nhiều tone, việc viết trực tiếp các giá trị tần số
ở mọi vị trí có thể làm mã nguồn khó đọc. Một cách đơn giản là đặt tên cho các
giá trị thường dùng bằng hằng số.

== Đặt tên tần số bằng hằng số

Ví dụ, tần số đầu tiên của bài thực hành có thể được định nghĩa:

```c
#define NOTE_C4 262U
```

Khi đó lời gọi trong chương trình có thể viết:

```c
tone(GPIO7, NOTE_C4);
```

Tên hằng số giúp thể hiện ý nghĩa của giá trị trong chương trình mà không làm
thay đổi tần số được truyền cho API.

== Bài tập mở rộng: tạo một giai điệu ngắn

Thay chuỗi tăng dần của bài thực hành bằng một giai điệu ngắn tự thiết kế.

Yêu cầu:

- Sử dụng ít nhất bốn tần số khác nhau.
- Sử dụng ít nhất hai thời lượng tone khác nhau.
- Có ít nhất một khoảng im lặng giữa các phần của giai điệu.
- Có thể định nghĩa các hằng số `NOTE_...` để mã nguồn dễ đọc hơn.
- Lặp lại giai điệu để có thể kiểm chứng nhiều lần trên phần cứng.

Không cung cấp lời giải cố định cho phần mở rộng. Tần số, thứ tự tone và thời
lượng được lựa chọn theo giai điệu cần tạo.

#expected-result[
  Passive buzzer phát được một giai điệu khác với chuỗi của bài thực hành
  chính, trong đó có thể nhận biết sự thay đổi về cao độ, thời lượng và các
  khoảng im lặng.
]


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
