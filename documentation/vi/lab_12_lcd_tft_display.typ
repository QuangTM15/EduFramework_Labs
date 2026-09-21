#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 12 - Hiển thị thông tin trên màn hình TFT
// Vietnamese version
// ============================================================================


// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "cornell-tft",
    type: "web",
    author: [Cornell University],
    title: [TFT LCD Display],
    source: [ECE 4760 - Designing with Microcontrollers],
    url: "https://people.ece.cornell.edu/land/courses/ece4760/PIC32/index_TFT_display.html",
  ),

  (
    key: "uw-tft",
    type: "web",
    author: [University of Wisconsin-Madison],
    title: [ILI9341 LCD Controller],
    source: [ECE353 - Introduction to Microprocessor Systems],
    url: "https://ece353.engr.wisc.edu/external-devices/ili9341/",
  ),

  (
    key: "sitronix-st7789",
    type: "datasheet",
    author: [Sitronix Technology Corporation],
    title: [ST7789V - 240RGB x 320 dot 262K Color with Frame Memory Single-Chip TFT Controller/Driver],
    revision: [1.3],
    year: [2014],
    url: "https://orientdisplay.com/controller-datasheets/sitronix/st7789v-lcd-controller-datasheet/",
  ),

  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https://www\.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
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
    key: "eduframework-tft",
    type: "web",
    author: [EduFramework],
    title: [LCD TFT Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 12,
  language: "vi",
  title: [Hiển thị thông tin trên màn hình TFT],
  subtitle: [Hiển thị văn bản và đồ họa cơ bản bằng TFT Device API với EduFramework],
)


// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Màn hình TFT cho phép hệ thống nhúng biểu diễn thông tin bằng các phần tử đồ họa
như pixel, văn bản, đường thẳng và các hình học cơ bản. Mỗi pixel được xác định
bởi một vị trí trên vùng hiển thị và một giá trị màu; từ các phần tử cơ bản này,
phần mềm có thể xây dựng giao diện trực quan cho trạng thái hệ thống, dữ liệu cảm
biến hoặc thông tin điều khiển #cite-ref(refs, "cornell-tft").

Bài lab này tập trung vào cách sử dụng màn hình TFT thông qua Device API của
EduFramework. Thay vì thao tác trực tiếp với command set của bộ điều khiển màn
hình, ứng dụng sử dụng các API cấp cao để khởi tạo display, thiết lập màu và vị
trí văn bản, cũng như vẽ các primitive graphics.

== Mục tiêu

#objectives(
  items: (
    [
      Mô tả hệ tọa độ pixel và cách xác định vị trí phần tử trên màn hình TFT.
    ],

    [
      Giải thích cách biểu diễn màu 16-bit theo định dạng RGB565.
    ],

    [
      Mô tả cấu hình mặc định của TFT Device trong EduFramework, bao gồm kích
      thước vùng hiển thị và các Logical Pin điều khiển.
    ],

    [
      Sử dụng các API `TFT_Begin()`, text API và graphics API để hiển thị thông
      tin trên màn hình TFT.
    ],

    [
      Nhận biết các khả năng mở rộng của TFT Device API, bao gồm điều khiển
      backlight, hiển thị số, tạo màu tùy chọn và sử dụng Advanced API theo
      context.
    ],
  ),
)


// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Hệ tọa độ và pixel

Màn hình đồ họa được tổ chức thành một lưới pixel. Trong hệ tọa độ được sử dụng
trong bài lab, pixel tại góc trên bên trái có tọa độ `(0, 0)`, tọa độ `x` tăng
theo hướng từ trái sang phải và tọa độ `y` tăng theo hướng từ trên xuống dưới.
Mỗi phần tử đồ họa được xác định từ các tọa độ pixel tương ứng
#cite-ref(refs, "uw-tft").

Có thể hình dung hệ tọa độ như sau:

```text
(0,0) --------------------> x
  |
  |
  |
  |
  v
  y
```

Một pixel riêng lẻ được xác định bởi cặp tọa độ `(x, y)`. Đường thẳng sử dụng
hai điểm đầu-cuối, trong khi hình chữ nhật sử dụng tọa độ góc bắt đầu cùng chiều
rộng và chiều cao. Các primitive graphics như pixel, line, rectangle và circle
là nền tảng để xây dựng các thành phần đồ họa phức tạp hơn
#cite-ref(refs, "cornell-tft").

#note[
  Tọa độ hợp lệ phụ thuộc vào kích thước vùng hiển thị hiện tại. Khi vẽ đồ họa,
  application cần lựa chọn tọa độ và kích thước sao cho phần tử nằm trong vùng
  hiển thị mong muốn.
]


== Màu RGB565

Một cách phổ biến để biểu diễn màu trên màn hình TFT là sử dụng `16 bit` cho mỗi
pixel. Với định dạng RGB565, `5 bit` được dành cho thành phần đỏ, `6 bit` cho
thành phần xanh lá và `5 bit` cho thành phần xanh dương
#cite-ref(refs, "cornell-tft").

Cấu trúc bit có thể biểu diễn như sau:

```text
15            11 10             5 4               0
+---------------+----------------+-----------------+
|  Red - 5 bit  | Green - 6 bit  |  Blue - 5 bit   |
+---------------+----------------+-----------------+
```

EduFramework cung cấp sẵn các hằng màu thường dùng:

```c
TFT_BLACK
TFT_WHITE
TFT_RED
TFT_GREEN
TFT_BLUE
TFT_YELLOW
TFT_CYAN
TFT_MAGENTA
```

Các API đồ họa nhận giá trị màu 16-bit này để xác định màu của pixel hoặc phần
tử được vẽ #cite-ref(refs, "eduframework-tft").

ST7789 hỗ trợ định dạng dữ liệu pixel `16-bit RGB565` bên cạnh các chế độ màu
khác. EduFramework sử dụng RGB565 cho giao diện màu của TFT Device API
#cite-ref(refs, "sitronix-st7789") #cite-ref(refs, "eduframework-tft").


// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng MaaZEDU Development Board và một module LCD TFT được hỗ
trợ bởi cấu hình hiện tại của EduFramework. MaaZEDU là board phát triển dựa trên
vi điều khiển S32K144 #cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],

  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),

    (
      [LCD TFT module],
      [Màn hình TFT sử dụng bộ điều khiển tương thích với implementation hiện tại của EduFramework.],
    ),

    (
      [Jumper wires],
      [Kết nối nguồn, SPI và các tín hiệu điều khiển giữa TFT với MaaZEDU.],
    ),

    (
      [USB Cable],
      [
        Kết nối board với máy tính để cấp nguồn và nạp chương trình.
      ],
    ),
  ),
)


== Cấu hình mặc định của TFT Device

Beginner API của EduFramework sử dụng một cấu hình phần cứng mặc định để
application có thể khởi tạo màn hình chỉ bằng `TFT_Begin()`. Cấu hình hiện tại
sử dụng vùng hiển thị `240 x 280` pixel, `xOffset = 0`, `yOffset = 20` và các
Logical Pin điều khiển như bảng dưới đây
#cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.45fr, 1.35fr, 2.1fr),
    align: (left + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Tham số*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Mặc định*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Vai trò*]
      ],
    ),

    [Width], [`240` pixels], [Chiều rộng vùng hiển thị.],
    [Height], [`280` pixels], [Chiều cao vùng hiển thị.],
    [X Offset], [`0`], [Độ lệch cột bắt đầu trong controller memory.],
    [Y Offset], [`20`], [Độ lệch hàng bắt đầu trong controller memory.],
    [CS], [`GPIO0`], [Chip Select của TFT.],
    [DC], [`GPIO1`], [Phân biệt command và display data.],
    [RST], [`GPIO2`], [Hardware Reset của TFT.],
    [BLK], [`GPIO3`], [Điều khiển backlight.],
  )
]

#note[
  Các giá trị trên là cấu hình mặc định của Beginner API trong phiên bản
  EduFramework hiện tại. Khi phần cứng sử dụng pin hoặc kích thước khác, Advanced
  API cho phép application cung cấp cấu hình riêng.
]


== Kết nối TFT

Màn hình sử dụng `SPI_SCK` làm clock và `SPI_SOUT` làm đường dữ liệu từ MCU tới
TFT. Các tín hiệu `CS`, `DC`, `RST` và `BLK` sử dụng lần lượt `GPIO0` đến
`GPIO3` trong cấu hình mặc định #cite-ref(refs, "eduframework-tft").

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
        #align(center + horizon)[*TFT*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*MaaZEDU*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Chức năng*]
      ],
    ),

    [`VCC`], [`3.3V`], [Nguồn cho module TFT.],
    [`GND`], [`GND`], [Mass chung giữa module và board.],
    [`SCL / SCK`], [`SPI_SCK`], [SPI clock.],
    [`SDA / MOSI`], [`SPI_SOUT`], [SPI data từ MCU tới TFT.],
    [`CS`], [`GPIO0`], [Chip Select.],
    [`DC`], [`GPIO1`], [Data / Command select.],
    [`RES / RST`], [`GPIO2`], [Hardware Reset.],
    [`BLK / BL`], [`GPIO3`], [Backlight control.],
  )
]

#figure-block(
  caption: [Sơ đồ kết nối LCD TFT với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/lcd_tft_circuit.png",
    width: 88%,
  )
]

#note[
  Nhãn `SDA` trên module TFT trong bài lab là đường dữ liệu SPI `MOSI`, không phải
  `SDA` của giao tiếp I2C. TFT không sử dụng đường `SPI_SIN / MISO` trong bài
  thực hành này.
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

TFT Device API của EduFramework tổ chức các thao tác hiển thị thành các nhóm
khởi tạo, text rendering và graphics primitives. Beginner API sử dụng context và
cấu hình phần cứng mặc định bên trong framework, giúp application không cần quản
lý trực tiếp command sequence của bộ điều khiển ST7789
#cite-ref(refs, "eduframework-tft").


== Khởi tạo TFT với `TFT_Begin()`

`TFT_Begin()` khởi tạo TFT Device bằng cấu hình mặc định của EduFramework. API
chuẩn bị giao tiếp SPI, các Logical Pin điều khiển và context hiển thị trước khi
application sử dụng các thao tác đồ họa #cite-ref(refs, "eduframework-tft").

#api-detail(
  name: "TFT_Begin",

  syntax: [TFT_Begin();],

  description: [
    Khởi tạo TFT Device bằng cấu hình mặc định của EduFramework.
  ],

  parameters: (),

  returns: [
    `true` khi TFT được khởi tạo thành công; `false` khi quá trình khởi tạo không
    hoàn tất.
  ],
)

Ví dụ:

```c
if (true == TFT_Begin())
{
    TFT_FillScreen(TFT_BLACK);
}
```


== Màu nền và graphics primitives

`TFT_FillScreen()` tô toàn bộ vùng hiển thị bằng một màu. Các API primitive
graphics cho phép application thao tác với pixel, đường thẳng, hình chữ nhật và
hình tròn. Những primitive tương tự được sử dụng phổ biến trong thư viện đồ họa
TFT để xây dựng các thành phần hiển thị cấp cao hơn
#cite-ref(refs, "cornell-tft") #cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.55fr, 2.45fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*API*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Chức năng*]
      ],
    ),

    [`TFT_FillScreen(color)`], [Tô toàn bộ màn hình bằng một màu.],
    [`TFT_DrawPixel(x, y, color)`], [Vẽ một pixel tại tọa độ được chỉ định.],
    [`TFT_DrawLine(x0, y0, x1, y1, color)`], [Vẽ đường thẳng giữa hai điểm.],
    [`TFT_DrawRect(x, y, width, height, color)`], [Vẽ đường viền hình chữ nhật.],
    [`TFT_FillRect(x, y, width, height, color)`], [Vẽ hình chữ nhật được tô kín.],
    [`TFT_DrawCircle(x, y, radius, color)`], [Vẽ đường tròn theo tâm và bán kính.],
    [`TFT_FillCircle(x, y, radius, color)`], [Vẽ hình tròn được tô kín.],
  )
]


== Hiển thị văn bản

TFT Device duy trì trạng thái cursor, màu chữ, màu nền và kích thước chữ. Sau khi
các thuộc tính này được thiết lập, `TFT_Print()` hoặc `TFT_Println()` sử dụng
trạng thái hiện tại để render chuỗi lên màn hình
#cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.65fr, 2.35fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*API*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Chức năng*]
      ],
    ),

    [`TFT_SetCursor(x, y)`], [Đặt vị trí bắt đầu cho lần hiển thị văn bản tiếp theo.],
    [`TFT_SetTextColor(color)`], [Thiết lập màu ký tự.],
    [`TFT_SetTextBackground(color)`], [Thiết lập màu nền của ký tự.],
    [`TFT_SetTextSize(size)`], [Thiết lập hệ số kích thước của font.],
    [`TFT_Print(text)`], [Hiển thị chuỗi tại cursor hiện tại.],
    [`TFT_Println(text)`], [Hiển thị chuỗi và chuyển cursor sang dòng tiếp theo.],
  )
]

Ví dụ:

```c
TFT_SetCursor(20U, 30U);
TFT_SetTextColor(TFT_YELLOW);
TFT_SetTextBackground(TFT_BLACK);
TFT_SetTextSize(3U);
TFT_Println("EduFramework");
```

#note[
  Font được quản lý bên trong implementation của TFT Device. Application không
  cần truy cập trực tiếp bitmap font để thực hiện các thao tác text cơ bản.
]


// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình hiển thị một giao diện tĩnh trên TFT bằng Beginner API của
EduFramework. Giao diện gồm hai dòng văn bản, một đường phân cách, một hình chữ
nhật chỉ có đường viền, một hình chữ nhật được tô kín, một đường tròn và một
hình tròn được tô kín.

Chương trình phải sử dụng cấu hình TFT mặc định của EduFramework và không sử
dụng trực tiếp các hàm `ST7789_*` trong bài thực hành chính.


== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng như
sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình hiển thị văn bản và đồ họa cơ bản trên TFT],
  )[
    ```c
    #include "Arduino.h"
    #include "lcd_tft.h"

    int main(void)
    {
        setup();

        if (false == TFT_Begin())
        {
            while (1)
            {
                /* TFT initialization failed. */
            }
        }

        TFT_FillScreen(TFT_BLACK);

        TFT_SetCursor(20U, 30U);
        TFT_SetTextColor(TFT_YELLOW);
        TFT_SetTextBackground(TFT_BLACK);
        TFT_SetTextSize(3U);
        TFT_Println("EduFramework");

        TFT_SetCursor(20U, 75U);
        TFT_SetTextColor(TFT_CYAN);
        TFT_SetTextSize(2U);
        TFT_Println("S32K144 TFT");

        TFT_DrawLine(20U, 105U, 220U, 105U, TFT_WHITE);

        TFT_DrawRect(20U, 125U, 80U, 50U, TFT_GREEN);
        TFT_FillRect(140U, 125U, 80U, 50U, TFT_BLUE);

        TFT_DrawCircle(60U, 220U, 25U, TFT_RED);
        TFT_FillCircle(180U, 220U, 25U, TFT_MAGENTA);

        while (1)
        {
            /* Display remains unchanged. */
        }
    }
    ```
  ]
]


== Giải thích chương trình

`setup()` khởi tạo các thành phần nền tảng của EduFramework. `TFT_Begin()` sau đó
khởi tạo TFT Device bằng cấu hình mặc định; nếu quá trình này thất bại, chương
trình giữ nguyên tại vòng lặp lỗi và không thực hiện các thao tác hiển thị tiếp
theo #cite-ref(refs, "eduframework-tft").

Sau khi Device sẵn sàng, `TFT_FillScreen(TFT_BLACK)` tạo nền đen cho toàn bộ vùng
hiển thị. Nhóm text API thiết lập cursor, màu chữ, màu nền và kích thước trước khi
hai chuỗi `"EduFramework"` và `"S32K144 TFT"` được render.

Các lệnh tiếp theo sử dụng graphics primitives để tạo một đường phân cách, hai
hình chữ nhật và hai hình tròn. `TFT_DrawRect()` và `TFT_DrawCircle()` chỉ vẽ
đường biên, trong khi `TFT_FillRect()` và `TFT_FillCircle()` tô toàn bộ vùng bên
trong bằng màu được chỉ định #cite-ref(refs, "eduframework-tft").

Sau khi toàn bộ nội dung đã được vẽ, chương trình không cần cập nhật display
thêm. Vòng lặp cuối giữ application hoạt động trong khi nội dung đã ghi trên TFT
được giữ nguyên.


== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board. Quan sát màn hình sau
khi board khởi động.

Màn hình phải hiển thị nền đen với hai dòng văn bản ở phần trên. Bên dưới văn bản
là một đường ngang màu trắng, tiếp theo là một hình chữ nhật viền xanh lá và một
hình chữ nhật tô xanh dương. Phần dưới cùng hiển thị một đường tròn màu đỏ và một
hình tròn tô màu magenta.

Kết quả hiển thị mong đợi trên màn hình TFT được minh họa ở hình bên dưới:

#figure-block(
  image("../assets/images/lcd_tft_display_example.png", width: 50%),
  caption: [Kết quả hiển thị mong đợi trên màn hình TFT.],
)

#block(breakable: false)[
  #expected-result[
    TFT được khởi tạo thành công và hiển thị đầy đủ hai dòng văn bản cùng các phần tử tại vị trí mong muốn. Màu sắc, vị trí và kiểu fill của
    các phần tử tương ứng với các tham số được truyền vào TFT Device API.
  ]
]


// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Beginner API cung cấp các thao tác phổ biến với cấu hình TFT mặc định. Ngoài các
API đã sử dụng trong bài thực hành, TFT Device còn hỗ trợ điều khiển backlight,
hiển thị dữ liệu số, tạo màu RGB565 tùy chọn, truy vấn kích thước màn hình và
một Advanced API theo context cho các cấu hình phần cứng khác
#cite-ref(refs, "eduframework-tft").


== Điều khiển backlight

Backlight có thể được điều khiển trực tiếp bằng:

```c
TFT_BacklightOn();
TFT_BacklightOff();
```

Trong cấu hình mặc định, tín hiệu backlight sử dụng `GPIO3`
#cite-ref(refs, "eduframework-tft").

Hai API này cho phép application tắt ánh sáng nền khi không cần hiển thị hoặc bật
lại khi cần tương tác với display.


== Hiển thị giá trị số

Ngoài chuỗi ký tự, Beginner API cung cấp các hàm hiển thị số nguyên và số thực:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.65fr, 2.35fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*API*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Chức năng*]
      ],
    ),

    [`TFT_PrintInt(value)`], [Hiển thị một số nguyên.],
    [`TFT_PrintlnInt(value)`], [Hiển thị số nguyên và chuyển sang dòng tiếp theo.],
    [`TFT_PrintFloat(value, decimals)`], [Hiển thị số thực với số chữ số thập phân được chọn.],
    [`TFT_PrintlnFloat(value, decimals)`], [Hiển thị số thực và chuyển sang dòng tiếp theo.],
  )
]

Ví dụ:

```c
TFT_SetCursor(20U, 30U);
TFT_SetTextColor(TFT_WHITE);
TFT_SetTextBackground(TFT_BLACK);
TFT_SetTextSize(2U);

TFT_Print("Temperature: ");
TFT_PrintFloat(23.56F, 2U);
```

Các API này phù hợp cho các ứng dụng hiển thị dữ liệu cảm biến vì application
không cần tự chuyển đổi số sang chuỗi trước khi render
#cite-ref(refs, "eduframework-tft").


== Tạo màu tùy chọn với `TFT_Color565()`

`TFT_Color565()` chuyển ba thành phần màu đỏ, xanh lá và xanh dương sang một giá
trị RGB565 `16-bit` dùng bởi các API đồ họa. Mỗi thành phần đầu vào được biểu
diễn trong khoảng `0` đến `255`, sau đó framework thực hiện phép đóng gói màu
theo định dạng RGB565 #cite-ref(refs, "eduframework-tft").

Ví dụ:

```c
uint16_t orange;

orange = TFT_Color565(255U, 128U, 0U);

TFT_FillRect(20U, 20U, 80U, 40U, orange);
```

API này cho phép tạo màu ngoài nhóm hằng màu được định nghĩa sẵn.


== Truy vấn kích thước hiển thị

Application có thể đọc kích thước hiện tại của TFT Device bằng:

```c
uint16_t width;
uint16_t height;

width = TFT_Width();
height = TFT_Height();
```

`TFT_Width()` và `TFT_Height()` giúp code tránh phụ thuộc trực tiếp vào các giá
trị `240` và `280`, đặc biệt khi application được sử dụng với cấu hình display
khác #cite-ref(refs, "eduframework-tft").


== Address window trong bộ điều khiển TFT

Bộ điều khiển TFT không nhất thiết phải cập nhật toàn bộ màn hình cho mỗi thao
tác. Một vùng hình chữ nhật có thể được xác định bằng giới hạn cột và hàng; dữ
liệu pixel tiếp theo được ghi vào vùng đã chọn. Cách tổ chức này cho phép chỉ cập
nhật khu vực cần thay đổi thay vì ghi lại toàn bộ frame
#cite-ref(refs, "uw-tft").

ST7789 cung cấp các command `CASET` để thiết lập vùng cột, `RASET` để thiết lập
vùng hàng và `RAMWR` để bắt đầu ghi dữ liệu pixel vào frame memory
#cite-ref(refs, "sitronix-st7789").

EduFramework Advanced API expose cơ chế này thông qua:

```c
ST7789_SetAddressWindow(&tft, x0, y0, x1, y1);
```

Trong các ứng dụng thông thường, các graphics API của framework tự xử lý thao tác
này; application chỉ cần gọi trực tiếp `ST7789_SetAddressWindow()` khi xây dựng
chức năng đồ họa cấp thấp hoặc tối ưu riêng.


== Advanced API theo context

Beginner API quản lý một TFT context mặc định và sử dụng cấu hình pin, kích thước
và offset cố định. Khi application cần cấu hình khác, Advanced API cho phép tạo
một context `ST7789_t` riêng #cite-ref(refs, "eduframework-tft").

Ví dụ khởi tạo:

#block(breakable: false)[
  #code-listing(
    caption: [Khởi tạo TFT bằng Advanced API],
  )[
    ```c
    ST7789_t tft;

    ST7789_Init(
        &tft,
        GPIO0,
        GPIO1,
        GPIO2,
        240U,
        280U,
        0U,
        20U
    );
    ```
  ]
]

Các tham số tương ứng với context, `CS`, `DC`, `RST`, chiều rộng, chiều cao,
`xOffset` và `yOffset`. Application có thể thay đổi các giá trị này khi phần cứng
TFT sử dụng cách kết nối hoặc vùng hiển thị khác
#cite-ref(refs, "eduframework-tft").

Các graphics API chính ở tầng Advanced gồm:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.8fr, 2.2fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Advanced API*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Vai trò*]
      ],
    ),

    [`ST7789_Init()`], [Khởi tạo một TFT context với cấu hình được lựa chọn.],
    [`ST7789_SetAddressWindow()`], [Thiết lập vùng frame memory cho thao tác ghi pixel.],
    [`ST7789_DrawPixel()`], [Vẽ một pixel.],
    [`ST7789_DrawLine()`], [Vẽ đường thẳng.],
    [`ST7789_DrawRect()`], [Vẽ đường viền hình chữ nhật.],
    [`ST7789_FillRect()`], [Vẽ hình chữ nhật được tô kín.],
    [`ST7789_FillScreen()`], [Tô toàn bộ vùng hiển thị.],
    [`ST7789_DrawCircle()`], [Vẽ đường tròn.],
    [`ST7789_FillCircle()`], [Vẽ hình tròn được tô kín.],
    [`ST7789_DrawChar()`], [Vẽ một ký tự với vị trí và thuộc tính được chỉ định.],
    [`ST7789_DrawString()`], [Vẽ một chuỗi với vị trí và thuộc tính được chỉ định.],
  )
]

#note[
  Beginner API được đặt tên tổng quát `TFT_*`, nhưng Advanced API hiện tại expose
  trực tiếp implementation `ST7789_*`. Vì vậy, một display khác chỉ có thể sử
  dụng Advanced API này khi controller và cách điều khiển tương thích với
  implementation ST7789 hiện có.
]


== Bài tập mở rộng

Xây dựng một màn hình thông tin đơn giản sử dụng Beginner API để:

- tạo một màu tùy chọn bằng `TFT_Color565()`;
- hiển thị một số nguyên bằng `TFT_PrintInt()`;
- hiển thị một số thực bằng `TFT_PrintFloat()`;
- sử dụng `TFT_Width()` và `TFT_Height()` thay cho việc hard-code kích thước màn hình;
- tắt backlight trong một khoảng thời gian và bật lại bằng các API backlight.

Sau đó, lựa chọn một phần tử đồ họa và thử viết lại bằng Advanced API với một
`ST7789_t` context riêng.

#block(breakable: false)[
  #expected-result[
    Màn hình hiển thị đúng dữ liệu số và màu tùy chọn, kích thước display được
    lấy từ TFT Device thay vì hard-code, backlight có thể được bật hoặc tắt bằng
    API, và một graphics primitive được thực hiện thành công thông qua
    `ST7789_t` context.
  ]
]


// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
