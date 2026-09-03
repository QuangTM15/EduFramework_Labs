#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Full Vietnamese Template Test
// ============================================================================
//
// Mục đích:
//   - Kiểm tra toàn bộ bố cục tài liệu bài lab.
//   - Kiểm tra cover, mục lục, đánh số trang, heading, bảng, hình, mã nguồn.
//   - Kiểm tra hệ thống caption theo Lab.Section.Sequence.
//   - Kiểm tra component API, procedure, expected result và references.
//
// LƯU Ý:
// Nội dung lý thuyết dưới đây chỉ phục vụ kiểm thử bố cục.
// Phiên bản Lab 01 chính thức sẽ được viết lại dựa trên tài liệu tham khảo
// đã được kiểm chứng.
//
// ============================================================================


// ============================================================================
// 1. TÀI LIỆU THAM KHẢO DÙNG ĐỂ TEST HỆ THỐNG
// ============================================================================

#let refs = (
  (
    key: "nxp-s32k-rm",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Reference Manual],
    type: "manual",
    publisher: [NXP Semiconductors],
    document: [S32K1xx Series Reference Manual],
    url: "https://www.nxp.com/",
  ),

  (
    key: "nxp-s32k-ds",
    author: [NXP Semiconductors],
    title: [S32K1xx Data Sheet],
    type: "datasheet",
    publisher: [NXP Semiconductors],
    url: "https://www.nxp.com/",
  ),

  (
    key: "arduino-pinmode",
    author: [Arduino],
    title: [pinMode()],
    type: "web",
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/",
    accessed: [31/08/2026],
  ),

  (
    key: "arduino-digitalwrite",
    author: [Arduino],
    title: [digitalWrite()],
    type: "web",
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/",
    accessed: [31/08/2026],
  ),

  (
    key: "arduino-delay",
    author: [Arduino],
    title: [delay()],
    type: "web",
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/",
    accessed: [31/08/2026],
  ),
)


// ============================================================================
// 2. DOCUMENT WRAPPER
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

Digital Output là một trong những chức năng cơ bản nhất khi bắt đầu làm việc
với vi điều khiển. Thông qua một chân GPIO được cấu hình ở chế độ output,
chương trình có thể tạo ra các mức logic để điều khiển các phần tử phần cứng
bên ngoài hoặc các phần tử tích hợp trực tiếp trên board.

Trong bài thực hành này, LED tích hợp trên MaaZEDU Development Board được sử
dụng như một công cụ trực quan để minh họa cách cấu hình và điều khiển một
Digital Output bằng EduFramework. Trọng tâm của bài lab không nằm ở thao tác
nhấp nháy LED, mà nằm ở việc hiểu cấu trúc chương trình EduFramework, cách
sử dụng Logical Pin và cách ứng dụng điều khiển một GPIO output.

Bài lab cũng giới thiệu cấu trúc chương trình C cơ bản được sử dụng xuyên suốt
EduFramework Laboratory Series. Mỗi chương trình bắt đầu từ hàm `main()`, gọi
`setup()` để thực hiện phần khởi tạo nền tảng trước khi cấu hình và chạy logic
ứng dụng trong vòng lặp chính.


== Mục tiêu

#objectives(
  items: (
    [Trình bày được vai trò cơ bản của GPIO và Digital Output trong hệ thống nhúng.],
    [Nhận biết được sự khác nhau giữa Logical Pin của EduFramework và chân MCU tương ứng.],
    [Hiểu được cấu trúc cơ bản của một chương trình EduFramework viết bằng ngôn ngữ C.],
    [Giải thích được vai trò của hàm `setup()` trong quá trình khởi tạo chương trình.],
    [Sử dụng được `pinMode()` để cấu hình một chân digital ở chế độ output.],
    [Sử dụng được `digitalWrite()` để thay đổi mức logic của Digital Output.],
    [Sử dụng được `delay()` để tạo khoảng thời gian giữa các trạng thái của ứng dụng.],
  ),
)

#note[
  Bản tài liệu này đang được sử dụng để kiểm thử cấu trúc và trình bày của hệ
  thống tài liệu EduFramework Laboratory Series. Nội dung lý thuyết của bản phát
  hành chính thức sẽ được đối chiếu với tài liệu kỹ thuật của NXP, tài liệu API
  và mã nguồn thực tế của EduFramework trước khi công bố.
]


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Cấu trúc cơ bản của chương trình EduFramework

Một ứng dụng EduFramework được viết bằng ngôn ngữ C và bắt đầu từ hàm
`main()`. Khác với mô hình sketch sử dụng `setup()` và `loop()` như hai entry
point độc lập, chương trình EduFramework vẫn sử dụng cấu trúc C truyền thống
với một hàm `main()` duy nhất.

Trong `main()`, hàm `setup()` phải được gọi trước khi ứng dụng cấu hình hoặc sử
dụng các chức năng khác của framework. Sau giai đoạn khởi tạo, chương trình có
thể cấu hình các ngoại vi cần thiết và thực hiện logic ứng dụng trong vòng lặp
`while (1)`.

Cấu trúc tổng quát có thể biểu diễn như sau:

#code-listing(
  caption: [Cấu trúc cơ bản của một chương trình EduFramework],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      setup();

      /* Application initialization */

      while (1)
      {
          /* Application logic */
      }

      return 0;
  }
  ```
]


== Hàm setup()

Trong các bài lab của EduFramework, `setup()` được gọi một lần ở đầu hàm
`main()` trước khi các API khác được sử dụng. Vai trò chi tiết của hàm này sẽ
được mô tả dựa trên mã nguồn thực tế của framework trong phiên bản tài liệu
chính thức.

Ở góc nhìn của người sử dụng framework, quy tắc quan trọng trong bài lab đầu
tiên là: *gọi `setup()` trước khi thực hiện phần cấu hình và logic ứng dụng*.

#warning[
  Không bỏ qua lời gọi `setup()` trong cấu trúc chương trình EduFramework.
  Các bài lab sau sẽ mặc định rằng phần khởi tạo nền tảng đã được thực hiện
  trước khi các API ngoại vi được sử dụng.
]


== GPIO và Digital Output

General-Purpose Input/Output, thường được viết tắt là GPIO, là cơ chế cơ bản
cho phép vi điều khiển tương tác với các tín hiệu số. Tùy theo cấu hình, một
chân GPIO có thể được sử dụng để nhận trạng thái từ bên ngoài hoặc tạo ra một
mức logic để điều khiển phần cứng.

Trong bài thực hành này, chân điều khiển LED được sử dụng ở chế độ Digital
Output. Chương trình sẽ thay đổi trạng thái logic của chân này để tạo ra hai
trạng thái phần cứng có thể quan sát trực tiếp.

Các đặc điểm cụ thể về cấu trúc GPIO, thanh ghi, điện áp và giới hạn điện của
S32K144 cần được đối chiếu với tài liệu kỹ thuật chính thức của NXP
#cite-refs(refs, ("nxp-s32k-rm", "nxp-s32k-ds")).


== Mức logic HIGH và LOW

Ở tầng ứng dụng, EduFramework sử dụng các giá trị logic như `HIGH` và `LOW`
để biểu diễn trạng thái của Digital Output. Cách biểu diễn này giúp mã nguồn
ứng dụng dễ đọc hơn so với việc thao tác trực tiếp trên thanh ghi phần cứng.

Tuy nhiên, mức logic phần mềm không nhất thiết đồng nghĩa trực tiếp với trạng
thái hiển thị của thiết bị. Cách phần cứng được mắc quyết định việc `HIGH` hay
`LOW` tương ứng với trạng thái bật của thiết bị.

Khái niệm `HIGH` và `LOW` cũng được sử dụng trong mô hình Digital I/O của
Arduino #cite-ref(refs, "arduino-digitalwrite").


== LED Active-Low

LED tích hợp trên board có thể được thiết kế theo cơ chế active-high hoặc
active-low. Với phần cứng active-low, thiết bị được kích hoạt khi tín hiệu điều
khiển ở mức logic thấp.

Trong bài lab chính thức, trạng thái điện của LED trên MaaZEDU sẽ được xác nhận
lại từ schematic hoặc board documentation trước khi đưa ra kết luận cuối cùng.

#note[
  Việc dùng LED chỉ là phương tiện trực quan để quan sát Digital Output. Kiến
  thức cốt lõi của bài lab là cấu hình GPIO output và điều khiển mức logic của
  chân thông qua API EduFramework.
]


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng phần cứng tối thiểu để người học có thể tập trung vào
cấu trúc chương trình và Digital Output.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144 và LED tích hợp phục vụ cho bài thực hành.],
    ),

    (
      [USB Cable],
      [Kết nối board với hệ thống phát triển và cung cấp kết nối cần thiết trong quá trình làm bài lab.],
    ),

    (
      [J-Link Debug Probe],
      [Thiết bị hỗ trợ nạp và debug chương trình trên S32K144.],
    ),
  ),
)


== Ánh xạ chân

EduFramework cung cấp các Logical Pin để ứng dụng không cần sử dụng trực tiếp
tên port/pin vật lý của MCU trong mã nguồn mức cao.

#pin-table(
  caption: [Ánh xạ chân LED sử dụng trong bài thực hành],
  rows: (
    (
      [LED đỏ tích hợp],
      "LED_RED",
      "PTD15",
      [Digital Output],
    ),
  ),
)

Trong mã nguồn ứng dụng, `LED_RED` được sử dụng như Logical Pin của
EduFramework. Phần ánh xạ tới `PTD15` giúp liên hệ abstraction của framework
với chân GPIO thực tế trên S32K144.


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

== Tổng quan API

Các API cần thiết cho bài thực hành Digital Output được tổng hợp trong bảng
dưới đây. Phần mô tả chi tiết chỉ tập trung vào những thông tin cần thiết để
thực hiện bài lab.

#api-table(
  caption: [Các API EduFramework sử dụng trong bài thực hành],
  rows: (
    (
      "pinMode",
      "(pin, mode)",
      [Cấu hình chế độ hoạt động của một Logical Pin digital.],
    ),

    (
      "digitalWrite",
      "(pin, value)",
      [Thiết lập mức logic đầu ra cho một chân digital đã được cấu hình.],
    ),

    (
      "delay",
      "(ms)",
      [Tạo khoảng thời gian chờ theo đơn vị millisecond.],
    ),
  ),
)


== pinMode()

`pinMode()` được sử dụng để cấu hình chế độ hoạt động của một chân digital
trước khi chân đó được sử dụng trong logic ứng dụng.

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
      [Chân digital cần cấu hình.],
    ),

    (
      [mode],
      [`OUTPUT`],
      [Chế độ hoạt động cần thiết cho bài thực hành Digital Output.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Thông tin chính xác về kiểu dữ liệu và toàn bộ tập giá trị được hỗ trợ của từng
tham số sẽ được lấy trực tiếp từ header/source EduFramework khi viết bản Lab 01
chính thức. Mô hình sử dụng API có thể được đối chiếu thêm với tài liệu
`pinMode()` của Arduino #cite-ref(refs, "arduino-pinmode").


== digitalWrite()

`digitalWrite()` thay đổi mức logic của một chân digital output.

#api-detail(
  name: "digitalWrite",
  syntax: [digitalWrite(pin, value);],

  description: [
    Thiết lập mức logic đầu ra cho Logical Pin đã được cấu hình ở chế độ
    Digital Output.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Chân output cần điều khiển.],
    ),

    (
      [value],
      [`HIGH` / `LOW`],
      [Mức logic cần thiết lập cho chân output.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Tài liệu chính thức sẽ đối chiếu định nghĩa, kiểu tham số và hành vi API với mã
nguồn EduFramework thay vì suy luận từ API Arduino
#cite-ref(refs, "arduino-digitalwrite").


== delay()

`delay()` được sử dụng trong bài lab để giữ một trạng thái của ứng dụng trong
một khoảng thời gian có thể quan sát được.

#api-detail(
  name: "delay",
  syntax: [delay(ms);],

  description: [
    Tạo khoảng thời gian chờ cho luồng thực thi chương trình.
  ],

  parameters: (
    (
      [ms],
      [millisecond],
      [Khoảng thời gian chờ yêu cầu.],
    ),
  ),

  returns: [Không trả về giá trị.],
)

Trong các bài lab phức tạp hơn, cách tạo thời gian không blocking có thể được
giới thiệu riêng. Ở bài đầu tiên, `delay()` được sử dụng để giữ ví dụ trực
quan và tập trung vào Digital Output #cite-ref(refs, "arduino-delay").


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu bài toán

Hãy xây dựng một chương trình EduFramework điều khiển LED đỏ tích hợp trên
MaaZEDU Development Board thay đổi trạng thái theo chu kỳ.

Chương trình cần đáp ứng các yêu cầu sau:

- sử dụng cấu trúc chương trình C với `main()`;
- gọi `setup()` trước khi sử dụng các API của EduFramework;
- sử dụng Logical Pin của framework để truy cập LED;
- cấu hình chân LED ở chế độ Digital Output;
- thay đổi trạng thái LED giữa hai mức logic;
- duy trì mỗi trạng thái trong khoảng 500 ms;
- lặp lại hành vi liên tục trong quá trình chương trình hoạt động.

Ở bước này, tài liệu chưa cung cấp lời giải hoàn chỉnh. Người học cần sử dụng
kiến thức và thông tin API đã được trình bày ở các phần trước để xây dựng
chương trình.


== Tư duy thiết kế

Trước khi viết mã nguồn, có thể phân tích bài toán theo các bước tư duy sau:

#procedure(
  steps: (
    (
      [Xác định tài nguyên cần điều khiển],
      [
        Xác định Logical Pin đại diện cho LED tích hợp và liên hệ Logical Pin
        đó với phần cứng thực tế trên board.
      ],
    ),

    (
      [Xác định bước khởi tạo chương trình],
      [
        Xác định thứ tự gọi `setup()` và cấu hình Digital Output trước khi
        chương trình bắt đầu thay đổi mức logic của LED.
      ],
    ),

    (
      [Xác định hai trạng thái đầu ra],
      [
        Xác định hai mức logic cần được sử dụng để tạo ra hai trạng thái quan
        sát được của LED.
      ],
    ),

    (
      [Xác định khoảng thời gian],
      [
        Xác định vị trí cần áp dụng khoảng chờ 500 ms để mỗi trạng thái được
        giữ đủ lâu trước khi chuyển sang trạng thái tiếp theo.
      ],
    ),

    (
      [Tổ chức vòng lặp chính],
      [
        Tổ chức logic trong `while (1)` để chuỗi trạng thái được lặp lại liên
        tục trong suốt thời gian chương trình hoạt động.
      ],
    ),
  ),
)

Các bước trên chỉ mô tả hướng tư duy. Người học vẫn cần tự chuyển chúng thành
mã nguồn hoàn chỉnh.


== Khung chương trình

Hoàn thiện phần còn thiếu trong chương trình sau:

#code-listing(
  caption: [Khung chương trình cho bài thực hành Digital Output],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      setup();

      /* Configure the digital output here. */

      while (1)
      {
          /* Implement the required output sequence here. */
      }

      return 0;
  }
  ```
]

Hãy kiểm tra kết quả trên phần cứng trước khi xem phần lời giải tham khảo.


// ============================================================================
// 6. LỜI GIẢI THAM KHẢO VÀ KIỂM CHỨNG
// ============================================================================

= Lời giải tham khảo và kiểm chứng

== Mã nguồn tham khảo

Một cách triển khai đáp ứng yêu cầu của bài thực hành được trình bày dưới đây.

#code-listing(
  caption: [Mã nguồn tham khảo cho ứng dụng Digital Output],
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


== Giải thích chương trình

Chương trình bắt đầu từ `main()` và gọi `setup()` trước khi thực hiện phần cấu
hình của ứng dụng. Sau đó, `pinMode()` cấu hình `LED_RED` thành Digital Output.

Trong vòng lặp `while (1)`, chương trình lần lượt ghi hai mức logic khác nhau
ra LED bằng `digitalWrite()`. Sau mỗi lần thay đổi trạng thái, `delay(500U)`
giữ trạng thái hiện tại trong khoảng thời gian đủ để quan sát.

Khi kết thúc lần thực thi cuối của vòng lặp, chương trình quay lại đầu
`while (1)` và tiếp tục chuỗi hoạt động. Vì vậy trạng thái LED được thay đổi
tuần hoàn trong suốt thời gian ứng dụng hoạt động.

Phần mô tả chính thức sẽ xác nhận trạng thái `LOW`/`HIGH` tương ứng với LED bật
hay tắt dựa trên schematic và tài liệu MaaZEDU thay vì chỉ dựa vào quan sát.


== Kết quả thực nghiệm

#expected-result[
  Sau khi chương trình được nạp và chạy thành công, LED tích hợp phải thay đổi
  trạng thái theo chu kỳ tương ứng với khoảng thời gian đã được cấu hình trong
  chương trình.
]

Bản phát hành chính thức sẽ sử dụng ảnh chụp thực tế trên MaaZEDU Development
Board để làm bằng chứng kiểm chứng phần cứng.

#figure-block(
  caption: [Kết quả thực nghiệm của ứng dụng Digital Output],
)[
  #rect(
    width: 78%,
    height: 5.0cm,
    fill: soft-gray,
    stroke: 0.6pt + border-gray,
  )[
    #align(center + horizon)[
      #text(
        font: "Calibri",
        size: 10pt,
        style: "italic",
        fill: text-gray,
      )[
        Ảnh kiểm chứng phần cứng sẽ được đặt tại đây
      ]
    ]
  ]
]


// ============================================================================
// 7. MỞ RỘNG
// ============================================================================

= Mở rộng

Sau khi hoàn thành bài thực hành cơ bản, người học có thể tiếp tục thay đổi
chương trình để quan sát và phân tích thêm hành vi của Digital Output.

Các hướng mở rộng gợi ý:

- Thay đổi khoảng thời gian giữa hai trạng thái của LED và quan sát sự thay đổi
  của chu kỳ.

- Sử dụng hai khoảng thời gian khác nhau cho trạng thái bật và tắt.

- Thay `LED_RED` bằng một LED tích hợp khác được EduFramework hỗ trợ.

- Điều khiển nhiều LED theo một chuỗi trạng thái xác định.

- Thêm một hoạt động khác vào vòng lặp chính và quan sát ảnh hưởng của
  `delay()` tới luồng thực thi chương trình.

Phần mở rộng không cung cấp lời giải tham khảo nhằm khuyến khích người học tự
thử nghiệm và phát triển chương trình từ kiến thức đã học.


// ============================================================================
// 8. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

Danh sách dưới đây chỉ được sử dụng để kiểm tra bố cục reference của template.
Khi viết bài Lab 01 chính thức, tên tài liệu, revision, metadata và URL sẽ được
xác nhận từ nguồn chính thức trước khi đưa vào tài liệu.

#references(refs)
