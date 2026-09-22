#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 13 - Giám sát khoảng cách với TFT
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "nyu-ultrasonic",
    type: "web",
    author: [New York University],
    title: [Lab: Ultrasonic Distance Sensor],
    source: [ITP Physical Computing],
    url: "https://itp.nyu.edu/physcomp/labs/lab-ultrasonic-distance-sensor/",
  ),
  (
    key: "hcsr04-datasheet",
    type: "datasheet",
    author: [SparkFun Electronics],
    title: [HC-SR04 Ultrasonic Sensor Datasheet],
    source: [Technical Datasheet],
    url: "https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf",
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
    key: "eduframework-ultrasonic",
    type: "web",
    author: [EduFramework],
    title: [Ultrasonic Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "eduframework-tft",
    type: "web",
    author: [EduFramework],
    title: [LCD TFT Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "eduframework-digital",
    type: "web",
    author: [EduFramework],
    title: [Digital I/O API and Pin Mapping],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 13,
  language: "vi",
  title: [Giám sát khoảng cách với TFT],
  subtitle: [Tích hợp HC-SR04, màn hình TFT và cảnh báo LED với \
  EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Lab 09 đã sử dụng HC-SR04 để đo khoảng cách, trong khi Lab 12 đã giới thiệu
màn hình TFT và các API hiển thị cơ bản. Bài lab này kết hợp các thành phần đã
học thành một ứng dụng giám sát khoảng cách đơn giản.

HC-SR04 cung cấp giá trị khoảng cách cho application. Giá trị hợp lệ được hiển
thị trực tiếp trên màn hình TFT theo đơn vị centimet. Khi khoảng cách nhỏ hơn
hoặc bằng `5 cm`, LED đỏ tích hợp trên MaaZEDU nhấp nháy để tạo tín hiệu cảnh
báo trực quan.

Bài lab không giới thiệu Device API mới. Trọng tâm là cách phối hợp nhiều API
đã học trong cùng một chương trình để hình thành một luồng xử lý hoàn chỉnh từ
thu nhận dữ liệu tới hiển thị và cảnh báo.

== Mục tiêu

#objectives(
  items: (
    [
      Mô tả luồng xử lý từ dữ liệu cảm biến tới phần hiển thị và tín hiệu cảnh
      báo.
    ],
    [
      Kết hợp Ultrasonic Device API, TFT Device API và Digital I/O API trong
      cùng một ứng dụng.
    ],
    [
      Cập nhật giá trị khoảng cách trên màn hình TFT theo thời gian thực.
    ],
    [
      Xây dựng và kiểm chứng logic cảnh báo bằng LED khi khoảng cách nhỏ hơn
      hoặc bằng `5 cm`.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Tích hợp các khối chức năng

Trong các bài lab trước, cảm biến, màn hình và Digital Output được sử dụng như
những khối chức năng riêng. Khi xây dựng một ứng dụng hoàn chỉnh hơn, các khối
này có thể được ghép lại theo một luồng xử lý chung:

`Sensing` → `Processing` → `Presentation / Indication`

Trong bài thực hành này, HC-SR04 đảm nhiệm bước thu nhận dữ liệu. Application
kiểm tra kết quả đo và sử dụng cùng một giá trị khoảng cách cho hai mục đích:
hiển thị dữ liệu định lượng trên TFT và quyết định trạng thái của LED cảnh báo.

Luồng dữ liệu có thể biểu diễn như sau:

`HC-SR04` → `ultrasonicRead()` → `Application Logic` → `TFT + LED_RED`

Khi phép đo hợp lệ, khoảng cách được hiển thị trên TFT. Nếu giá trị nhỏ hơn hoặc
bằng `5 cm`, LED đỏ được đảo trạng thái theo mỗi chu kỳ cập nhật để tạo hiệu ứng
nhấp nháy. Khi khoảng cách lớn hơn ngưỡng hoặc phép đo không hợp lệ, LED được
đưa về trạng thái tắt.

#note[
  Nguyên lý đo khoảng cách của HC-SR04 đã được trình bày trong Lab 09. Hệ tọa độ,
  màu sắc và các thao tác hiển thị TFT đã được trình bày trong Lab 12 nên không
  được lặp lại trong bài lab này.
]

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng HC-SR04 làm nguồn dữ liệu khoảng cách, LCD TFT làm thiết
bị hiển thị và LED đỏ tích hợp trên MaaZEDU làm tín hiệu cảnh báo.

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [HC-SR04],
      [Cảm biến siêu âm sử dụng để đo khoảng cách.],
    ),
    (
      [LCD TFT],
      [Hiển thị giá trị khoảng cách đo được.],
    ),
    (
      [Jumper wires],
      [Kết nối nguồn và tín hiệu giữa các module với MaaZEDU.],
    ),
    (
      [USB Cable],
      [Kết nối board với máy tính để cấp nguồn và nạp chương trình.],
    ),
  ),
)

== Ánh xạ chân sử dụng

Trong Lab 09, HC-SR04 sử dụng `GPIO2` và `GPIO1`. Hai Logical Pin này hiện được
dùng bởi cấu hình mặc định của TFT Device, vì vậy bài lab chuyển tín hiệu
`TRIG` và `ECHO` sang `GPIO4` và `GPIO5`.

Theo ánh xạ hiện tại của MaaZEDU, `GPIO4` tương ứng với `PTD12`, `GPIO5` tương
ứng với `PTD11` và LED đỏ tích hợp sử dụng `PTD15`
#cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-digital").

#pin-table(
  caption: [Ánh xạ chân HC-SR04 và LED cảnh báo],
  rows: (
    (
      [HC-SR04 TRIG],
      "GPIO4",
      "PTD12",
      [Digital Output],
    ),
    (
      [HC-SR04 ECHO],
      "GPIO5",
      "PTD11",
      [Digital Input],
    ),
    (
      [LED đỏ tích hợp],
      "LED_RED",
      "PTD15",
      [Warning Output],
    ),
  ),
)

== Kết nối phần cứng

HC-SR04 được cấp nguồn từ `5V`, sử dụng chung `GND` với MaaZEDU, `TRIG` nối tới
`GPIO4` và `ECHO` nối tới `GPIO5`. Cấu hình nguồn và các chân `TRIG` / `ECHO`
phù hợp với cách sử dụng cơ bản của HC-SR04
#cite-ref(refs, "hcsr04-datasheet") #cite-ref(refs, "nyu-ultrasonic").

TFT tiếp tục sử dụng cấu hình mặc định đã giới thiệu trong Lab 12. Các tín hiệu
`CS`, `DC`, `RST` và `BLK` sử dụng `GPIO0` đến `GPIO3`; đường clock và dữ liệu
SPI sử dụng `SPI_SCK` và `SPI_SOUT`
#cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.45fr, 1.45fr, 2.1fr),
    align: (left + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Thiết bị / chân*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*MaaZEDU*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Chức năng*]
      ],
    ),

    [HC-SR04 VCC], [`5V`], [Nguồn cho cảm biến.],
    [HC-SR04 GND], [`GND`], [Mass chung.],
    [HC-SR04 TRIG], [`GPIO4`], [Trigger signal.],
    [HC-SR04 ECHO], [`GPIO5`], [Echo signal.],
    [TFT VCC], [`3.3V`], [Nguồn cho TFT.],
    [TFT GND], [`GND`], [Mass chung.],
    [TFT SCL / SCK], [`SPI_SCK`], [SPI clock.],
    [TFT SDA / MOSI], [`SPI_SOUT`], [SPI data từ MCU tới TFT.],
    [TFT CS], [`GPIO0`], [Chip Select.],
    [TFT DC], [`GPIO1`], [Data / Command select.],
    [TFT RES / RST], [`GPIO2`], [Hardware Reset.],
    [TFT BLK / BL], [`GPIO3`], [Backlight control.],
  )
]

#figure-block(
  caption: [Sơ đồ kết nối HC-SR04 và LCD TFT với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/distance_monitor_circuit.png",
    width: 96%,
  )
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Lab 13 không giới thiệu API mới. Chương trình kết hợp các API đã được sử dụng ở
Lab 01, Lab 09 và Lab 12 để hình thành một ứng dụng giám sát hoàn chỉnh
#cite-ref(refs, "eduframework-ultrasonic")
#cite-ref(refs, "eduframework-tft")
#cite-ref(refs, "eduframework-digital").

#info-table(
  columns: (1.35fr, 2.35fr, 1.15fr),
  alignments: (
    left + horizon,
    left + horizon,
    center + horizon,
  ),
  headers: (
    [Chức năng],
    [API chính],
    [Đã giới thiệu],
  ),
  rows: (
    (
      [Đo khoảng cách],
      [`ultrasonicBegin()`, `ultrasonicRead()`],
      [Lab 09],
    ),
    (
      [Hiển thị TFT],
      [`TFT_Begin()`, `TFT_FillRect()`, `TFT_PrintFloat()`],
      [Lab 12],
    ),
    (
      [Điều khiển LED],
      [`pinMode()`, `digitalWrite()`, `digitalToggle()`],
      [Lab 01],
    ),
    (
      [Tạo chu kỳ cập nhật],
      [`delay()`],
      [Lab 01],
    ),
  ),
  caption: [Các nhóm API được kết hợp trong Lab 13],
)

Luồng sử dụng chính trong application:

`ultrasonicRead()` → `Kiểm tra kết quả` → `Cập nhật TFT` → `Điều khiển LED`

Chi tiết cú pháp và tham số của từng API không được lặp lại trong bài lab này.

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình giám sát khoảng cách bằng HC-SR04 và hiển thị kết quả trên
màn hình TFT.

Chương trình cần đáp ứng các yêu cầu sau:

- Khởi tạo `LED_RED`, HC-SR04 và TFT.

- Sử dụng `GPIO4` cho `TRIG` và `GPIO5` cho `ECHO`.

- Đọc và hiển thị khoảng cách hợp lệ trên TFT theo đơn vị centimet.

- Nếu phép đo không hợp lệ, hiển thị `--.- cm`.

- Khi khoảng cách lớn hơn `5 cm`, giữ `LED_RED` ở trạng thái tắt.

- Khi khoảng cách nhỏ hơn hoặc bằng `5 cm`, làm `LED_RED` nhấp nháy để cảnh báo.

- Cập nhật phép đo và trạng thái cảnh báo mỗi `200 ms`.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình giám sát khoảng cách bằng HC-SR04 và TFT],
  )[
    ```c
    #include "Arduino.h"
    #include "ultrasonic.h"
    #include "lcd_tft.h"
    int main(void)
    {
        float distance = ULTRASONIC_INVALID_DISTANCE_CM;
        setup();
        pinMode(LED_RED, OUTPUT);
        digitalWrite(LED_RED, HIGH);
        ultrasonicBegin(GPIO4, GPIO5);
        TFT_Begin();
        TFT_FillScreen(TFT_BLACK);
        TFT_SetTextColor(TFT_WHITE);
        TFT_SetTextBackground(TFT_BLACK);
        TFT_SetTextSize(2U);
        TFT_SetCursor(55U, 40U);
        TFT_Print("DISTANCE");
        while (1)
        {
            distance = ultrasonicRead();
            TFT_FillRect(30U, 100U, 180U, 50U, TFT_BLACK);
            TFT_SetCursor(55U, 110U);
            TFT_SetTextSize(3U);
            if (ULTRASONIC_INVALID_DISTANCE_CM !=distance)
            {
                TFT_PrintFloat(distance, 1U);
                TFT_Print(" cm");
                if (distance <= 5.0f)
                {
                    digitalToggle(LED_RED);
                }
                else
                {
                    digitalWrite(LED_RED, HIGH);
                }
            }
            else
            {
                TFT_Print("--.- cm");
                digitalWrite(LED_RED, HIGH);
            }
            delay(200U);
        }
        return 0;
    }
    ```
  ]
]

== Giải thích chương trình

Sau `setup()`, `LED_RED` được cấu hình làm Digital Output và được đặt ở mức
`HIGH` để giữ LED đỏ tích hợp ở trạng thái tắt. HC-SR04 được khởi tạo với
`GPIO4` làm `TRIG` và `GPIO5` làm `ECHO`, sau đó TFT được khởi tạo và thiết lập
giao diện ban đầu.

Tiêu đề `DISTANCE` chỉ được vẽ một lần trước vòng lặp. Trong mỗi chu kỳ,
`ultrasonicRead()` lấy một phép đo mới. Trước khi hiển thị giá trị tiếp theo,
`TFT_FillRect()` chỉ xóa vùng chứa kết quả cũ thay vì xóa toàn bộ màn hình. Nhờ
đó phần tiêu đề giữ nguyên và application chỉ cập nhật nội dung cần thay đổi.

Nếu phép đo hợp lệ, `TFT_PrintFloat()` hiển thị khoảng cách với một chữ số sau
dấu thập phân. Giá trị sau đó được so sánh với ngưỡng `5.0f`. Khi khoảng cách
nhỏ hơn hoặc bằng ngưỡng, `digitalToggle(LED_RED)` đảo trạng thái LED ở mỗi chu
kỳ cập nhật. Khi khoảng cách lớn hơn ngưỡng, `digitalWrite(LED_RED, HIGH)` đưa
LED trở về trạng thái tắt.

Nếu `ultrasonicRead()` trả về `ULTRASONIC_INVALID_DISTANCE_CM`, chương trình
hiển thị `--.- cm` và giữ LED tắt
#cite-ref(refs, "eduframework-ultrasonic").

Luồng xử lý tổng thể được thể hiện trong sơ đồ sau:

#figure-block(
  caption: [Sơ đồ thuật toán của chương trình giám sát khoảng cách],
)[
  #image(
    "../assets/images/distance_monitor_flowchart.png",
    width: 68%,
  )
]

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Đặt một vật phản xạ
trước HC-SR04 và thay đổi khoảng cách của vật để kiểm tra ba trường hợp chính.

#info-table(
  columns: (1.35fr, 1.45fr, 2.3fr),
  alignments: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Trường hợp],
    [Hiển thị TFT],
    [Trạng thái LED đỏ],
  ),
  rows: (
    (
      [Khoảng cách `> 5 cm`],
      [Giá trị khoảng cách],
      [Tắt.],
    ),
    (
      [Khoảng cách `<= 5 cm`],
      [Giá trị khoảng cách],
      [Nhấp nháy cảnh báo.],
    ),
    (
      [Phép đo không hợp lệ],
      [`--.- cm`],
      [Tắt.],
    ),
  ),
  caption: [Các trường hợp kiểm chứng chính của Lab 13],
)

#block(breakable: false)[
  #expected-result[
    Màn hình TFT cập nhật liên tục giá trị khoảng cách đo được. Khi vật thể ở
    xa hơn `5 cm`, LED đỏ duy trì trạng thái tắt. Khi vật thể được đưa vào vùng
    nhỏ hơn hoặc bằng `5 cm`, LED đỏ nhấp nháy để cảnh báo. Nếu cảm biến không
    trả về phép đo hợp lệ, màn hình hiển thị `--.- cm` và LED đỏ tắt.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính chỉ sử dụng giá trị khoảng cách và một ngưỡng cảnh báo để
giữ chương trình ngắn gọn. Từ cấu trúc này, có thể mở rộng ứng dụng theo nhiều
hướng mà không cần thay đổi kiến trúc cơ bản của chương trình.

*Hiển thị trạng thái và màu sắc:* Bổ sung các trạng thái như `SAFE`, `WARNING`
và `DANGER` trên TFT. Có thể thay đổi màu chữ hoặc phần tử đồ họa theo từng vùng
khoảng cách để thông tin cảnh báo trực quan hơn.

*Cảnh báo nhiều mức:* Thay một ngưỡng duy nhất bằng nhiều vùng khoảng cách hoặc
kết hợp Passive Buzzer đã sử dụng ở Lab 07. Ví dụ, tốc độ phát cảnh báo có thể
thay đổi khi vật thể tiến gần cảm biến.

*Tích hợp các thiết bị đã học:* Các Device API trong những bài trước có thể được
kết hợp để xây dựng các ứng dụng nhỏ khác, chẳng hạn:

- NTC + TFT + Buzzer để giám sát và cảnh báo nhiệt độ.

- RFID + TFT + LED / Buzzer để mô phỏng hệ thống kiểm soát truy cập.

- MPU6050 + TFT để hiển thị dữ liệu chuyển động hoặc trạng thái nghiêng.

- HC-SR04 + Buzzer + TFT để phát triển mô hình cảnh báo khoảng cách trực quan
  hơn.

Các hướng mở rộng trên không yêu cầu thay đổi Device Layer. Application chỉ cần
phối hợp các API đã có và xây dựng logic phù hợp với chức năng mong muốn.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
