#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 08 - Đo nhiệt độ với NTC
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "mit-thermistor",
    type: "web",
    author: [Massachusetts Institute of Technology],
    title: [Introduction to Electronics, Signals and Measurement],
    source: [MIT OpenCourseWare],
    year: [2006],
    url: "https://ocw.mit.edu/courses/6-071j-introduction-to-electronics-signals-and-measurement-spring-2006/837566791a647fbcef525979e34dc9bd_intro_to_elctro.pdf",
  ),
  (
    key: "psu-thermistor",
    type: "web",
    author: [Gerald Recktenwald],
    title: [Temperature Measurement with a Thermistor and an Arduino],
    source: [Portland State University],
    year: [2010],
    url: "https://web.cecs.pdx.edu/~gerry/class/EAS199B/howto/thermistorArduino/thermistorArduino.pdf",
  ),
  (
    key: "microchip-an897",
    type: "application-note",
    author: [Microchip Technology Inc.],
    title: [Thermistor Temperature Sensing with MCP6SX2 PGAs],
    document: [AN897],
    year: [2015],
    url: "https://www.microchip.com/en-us/application-notes/an897",
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
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
  ),
  (
    key: "eduframework-ntc",
    type: "web",
    author: [EduFramework],
    title: [NTC Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 8,
  language: "vi",
  title: [Đo nhiệt độ với NTC],
  subtitle: [Đọc nhiệt độ bằng NTC Device API với EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Nhiệt độ là một đại lượng vật lý thường được giám sát trong các hệ thống đo
lường và điều khiển. Thermistor là phần tử điện trở có giá trị thay đổi theo
nhiệt độ; với loại NTC (Negative Temperature Coefficient), điện trở giảm khi
nhiệt độ tăng #cite-ref(refs, "mit-thermistor").

Trong các bài lab trước, tín hiệu analog được đọc dưới dạng giá trị ADC hoặc
được sử dụng trực tiếp để điều khiển một đầu ra. Bài lab này chuyển sang tầng
Device của EduFramework: tín hiệu điện từ module NTC được xử lý qua ADC, sau đó
được chuyển thành điện trở và nhiệt độ để ứng dụng có thể làm việc trực tiếp
với đại lượng vật lý theo độ C #cite-ref(refs, "psu-thermistor")
#cite-ref(refs, "eduframework-ntc").

Bài thực hành sử dụng `NTC_ReadCelsius()` để đọc nhiệt độ từ module NTC và hiển
thị kết quả lên Serial Monitor. Các giá trị trung gian như điện áp và điện trở
được dành cho phần mở rộng.

== Mục tiêu

#objectives(
  items: (
    [
      Mô tả nguyên lý cơ bản của NTC thermistor và quan hệ giữa nhiệt độ với
      điện trở.
    ],
    [
      Giải thích cách mạch chia áp chuyển sự thay đổi điện trở của NTC thành
      điện áp analog có thể đưa vào ADC.
    ],
    [
      Mô tả luồng chuyển đổi từ tín hiệu analog của module NTC đến giá trị
      nhiệt độ trong EduFramework.
    ],
    [
      Sử dụng `NTC_Init()` và `NTC_ReadCelsius()` để đọc nhiệt độ theo độ C.
    ],
    [
      Xây dựng và kiểm chứng ứng dụng giám sát nhiệt độ bằng Serial Monitor.
    ],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== NTC thermistor

Thermistor là điện trở phụ thuộc nhiệt độ và thường được sử dụng như một phần
tử cảm biến nhiệt độ. Hai nhóm cơ bản là NTC và PTC. Với NTC, điện trở giảm khi
nhiệt độ tăng; với PTC, điện trở tăng khi nhiệt độ tăng. Đặc tuyến điện trở theo
nhiệt độ của thermistor là phi tuyến #cite-ref(refs, "mit-thermistor").

Trong phép đo nhiệt độ, sự thay đổi điện trở của NTC là đại lượng trung gian.
Vi điều khiển không đo trực tiếp điện trở bằng ADC; trước hết cần chuyển sự thay
đổi điện trở thành một điện áp có thể đo được #cite-ref(refs, "psu-thermistor").

#note[
  NTC là phần tử nhạy nhiệt có đặc tuyến phi tuyến. Giá trị điện trở không thể
  được xem như nhiệt độ theo một quan hệ tuyến tính đơn giản trên toàn dải đo
  #cite-ref(refs, "mit-thermistor").
]

== Mạch chia áp và tín hiệu analog

Một phương pháp phổ biến để đo thermistor bằng vi điều khiển là mắc NTC cùng một
điện trở cố định thành mạch chia áp. Khi điện trở NTC thay đổi, điện áp tại điểm
giữa của mạch cũng thay đổi và có thể được đưa vào ADC
#cite-ref(refs, "psu-thermistor") #cite-ref(refs, "microchip-an897").

Với cấu hình được sử dụng bởi NTC Device của EduFramework:

`VREF` → `R_FIXED` → `ADC(AO)` → `NTC` → `GND`

điện áp tại đầu vào ADC được xác định bởi quan hệ chia áp:

$ V_"ADC" = V_"REF" times (R_"NTC" / (R_"FIXED" + R_"NTC")) $

Từ điện áp đã đo, điện trở NTC có thể được suy ra theo:

$ R_"NTC" = R_"FIXED" times (V_"ADC" / (V_"REF" - V_"ADC")) $

Quan hệ này tương ứng với cách `NTC_ReadResistance()` chuyển điện áp đo được
thành điện trở trong implementation hiện tại của EduFramework
#cite-ref(refs, "psu-thermistor") #cite-ref(refs, "eduframework-ntc").

S32K144 tích hợp bộ ADC để chuyển điện áp analog thành dữ liệu số.EduFramework sử dụng tầng Analog API để thực hiện quá trình đọc ADC
cho Device NTC #cite-ref(refs, "nxp-s32k-cookbook")
#cite-ref(refs, "eduframework-ntc").

== Từ tín hiệu analog đến nhiệt độ

Luồng đo nhiệt độ trong bài lab có thể được mô tả như sau:

`Nhiệt độ` → `Điện trở NTC` → `Điện áp AO` → `ADC` → `Điện trở` → `Nhiệt độ`

Các bước đo ADC và tính điện trở được đóng gói trong Device API. Vì vậy, ứng
dụng không cần tự đọc ADC rồi tự thực hiện phép tính chia áp trước khi lấy giá
trị nhiệt độ #cite-ref(refs, "eduframework-ntc").

Trong implementation hiện tại, `NTC_ReadCelsius()` gọi
`NTC_ReadResistance()` để lấy điện trở, sau đó sử dụng bảng tra của NTC `10 kΩ`
B3950 và nội suy tuyến tính giữa các điểm lân cận để xác định nhiệt độ. Bảng tra
bao phủ các mốc từ `-20 °C` đến `80 °C`; khi điện trở nằm ngoài hai đầu bảng,
implementation trả về giá trị nhiệt độ tại biên tương ứng
#cite-ref(refs, "eduframework-ntc").

Tài liệu của MIT trình bày đặc tuyến NTC dưới dạng dữ liệu điện trở theo nhiệt
độ, cho thấy mỗi vùng nhiệt độ tương ứng với một vùng điện trở khác nhau
#cite-ref(refs, "mit-thermistor"). EduFramework hiện sử dụng dữ liệu rời rạc
theo nguyên tắc này trong bảng tra nội bộ và nội suy giữa hai điểm lân cận
#cite-ref(refs, "eduframework-ntc").

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng MaaZEDU Development Board cùng một module NTC có ngõ ra
analog `AO`. MaaZEDU sử dụng vi điều khiển S32K144; đường `AO` của module được
nối với một Logical Pin ADC của EduFramework và kết quả nhiệt độ được quan sát
qua Serial Monitor #cite-ref(refs, "maazedu-guide")
#cite-ref(refs, "eduframework-ntc").

#hardware-table(
  caption: [Phần cứng sử dụng trong bài thực hành],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board phát triển sử dụng vi điều khiển S32K144.],
    ),
    (
      [NTC temperature sensor module],
      [Module thermistor NTC có ngõ ra analog `AO` để đo nhiệt độ.],
    ),
    (
      [Jumper wires],
      [Kết nối nguồn, GND và tín hiệu analog giữa module NTC và MaaZEDU.],
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

== Ánh xạ chân sử dụng

NTC Device API nhận Logical Pin analog làm tham số đầu vào. Bài thực hành sử
dụng `ADC0_SE13` để nhận tín hiệu `AO` của module NTC
#cite-ref(refs, "eduframework-ntc").

#pin-table(
  caption: [Ánh xạ tín hiệu NTC sử dụng trong bài thực hành],
  rows: (
    (
      [NTC `AO`],
      "ADC0_SE13",
      "PTC15",
      [Analog Input / ADC0 Channel 13],
    ),
  ),
)

== Kết nối module NTC

Trong cấu hình phần cứng đã được kiểm chứng cho bài thực hành, module NTC được
cấp nguồn từ `3.3V`, sử dụng chung `GND` với MaaZEDU và đưa tín hiệu `AO` vào
`ADC0_SE13`. Chân `DO` của module không được sử dụng trong bài thực hành chính.
Đường đo analog của NTC Device hỗ trợ các Logical Pin ADC như `ADC0_SE12` và
`ADC0_SE13` #cite-ref(refs, "maazedu-guide")
#cite-ref(refs, "eduframework-ntc").

#figure-block(
  caption: [Sơ đồ kết nối module NTC với MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/ntc_temperature_circuit.png",
    width: 82%,
  )
]

#note[
  Bài thực hành chính chỉ sử dụng ngõ ra analog `AO`. Ngõ ra số `DO` của một số
  module NTC có thể được sử dụng cho chức năng ngưỡng và được giới thiệu ở phần
  Mở rộng #cite-ref(refs, "eduframework-ntc").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

Bài thực hành chính chỉ cần hai API của NTC Device: `NTC_Init()` và
`NTC_ReadCelsius()`. Các phép đọc điện áp, điện trở và các chức năng bổ sung
được dành cho phần Mở rộng #cite-ref(refs, "eduframework-ntc").

== `NTC_Init()`

`NTC_Init()` khởi tạo cấu hình mặc định của Device NTC.

#api-detail(
  name: "NTC_Init",
  syntax: [NTC_Init();],
  description: [
    Khởi tạo cấu hình mặc định cho NTC Device trước khi thực hiện phép đo.
  ],
  parameters: (),
  returns: [
    Không có giá trị trả về.
  ],
)

Ví dụ:

```c
NTC_Init();
```

== `NTC_ReadCelsius()`

`NTC_ReadCelsius()` đọc đường analog của NTC, tính điện trở và trả về nhiệt độ
đã chuyển đổi theo độ C. API nhận Logical Pin analog được nối với chân `AO` của
module #cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadCelsius",
  syntax: [NTC_ReadCelsius(pin);],
  description: [
    Đọc module NTC thông qua Analog Input và trả về nhiệt độ theo độ C.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [
        Chân analog nối với `AO` của module NTC, ví dụ `ADC0_SE13`.
      ],
    ),
  ),
  returns: [
    Nhiệt độ theo độ C khi phép đo thành công; `-273.15F` khi phép đo hoặc phép
    chuyển đổi thất bại.
  ],
)

Ví dụ:

```c
float temperature = NTC_ReadCelsius(ADC0_SE13);
```

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Xây dựng chương trình đọc nhiệt độ từ module NTC qua `ADC0_SE13` và hiển thị
kết quả trên Serial Monitor. Chương trình khởi tạo `Serial1` ở baud rate `9600`,
khởi tạo NTC Device một lần và cập nhật giá trị nhiệt độ sau mỗi khoảng `1000 ms`.

Sau khi chương trình hoạt động ổn định, thay đổi nhiệt độ tại thermistor bằng
cách chạm nhẹ hoặc đưa cảm biến gần một nguồn nhiệt an toàn để quan sát xu
hướng thay đổi của kết quả. Không yêu cầu một giá trị nhiệt độ cố định; mục tiêu
là kiểm chứng phép đo phản ứng hợp lý khi điều kiện nhiệt thay đổi.

== Chương trình

Trong `src/main.c`, triển khai chương trình đã được kiểm chứng trên phần cứng
như sau:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình đọc nhiệt độ từ module NTC],
  )[
    ```c
    #include "Arduino.h"
    #include "ntc.h"

    int main(void)
    {
        float temperature = 0.0F;

        setup();

        Serial1_begin(9600U);
        NTC_Init();

        Serial1_println("NTC Temperature Monitor");

        while (1)
        {
            temperature = NTC_ReadCelsius(ADC0_SE13);

            Serial1_print("Temperature: ");
            Serial1_printFloat(temperature);
            Serial1_println(" C");

            delay(1000U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` khởi tạo các thành phần nền tảng của EduFramework. `Serial1_begin()`
khởi tạo kênh Serial Monitor theo cấu hình đã sử dụng ở Lab 03, còn `NTC_Init()`
khởi tạo cấu hình mặc định của NTC Device #cite-ref(refs, "eduframework-ntc").

Trong vòng lặp chính, `NTC_ReadCelsius(ADC0_SE13)` thực hiện toàn bộ đường đọc
cần thiết của Device NTC và trả về nhiệt độ theo độ C. Kết quả được in lên
Serial Monitor, sau đó `delay(1000U)` tạo khoảng thời gian một giây giữa hai lần
cập nhật.

Luồng xử lý của ứng dụng có thể tóm tắt:

`Nhiệt độ` → `NTC module` → `ADC0_SE13` → `NTC_ReadCelsius()` → `Serial1` →
`Serial Monitor` #cite-ref(refs, "eduframework-ntc").

== Kiểm chứng

Build và nạp chương trình xuống MaaZEDU Development Board, sau đó mở Serial
Monitor với baud rate `9600`. Quan sát giá trị nhiệt độ khi cảm biến ở điều kiện
môi trường ổn định, sau đó làm ấm thermistor ở mức an toàn và kiểm tra xu hướng
thay đổi của giá trị hiển thị.

Dữ liệu trên Serial Monitor có dạng:

```text
NTC Temperature Monitor
Temperature: 28.91 C
Temperature: 29.02 C
Temperature: 29.14 C
Temperature: 29.27 C
```

#block(breakable: false)[
  #expected-result[
    Serial Monitor cập nhật nhiệt độ khoảng mỗi `1000 ms`. Ở điều kiện nhiệt
    ổn định, các giá trị liên tiếp dao động quanh một vùng gần nhau. Khi
    thermistor được làm ấm, giá trị nhiệt độ hiển thị có xu hướng tăng; khi
    nguồn nhiệt được loại bỏ và cảm biến nguội dần, giá trị có xu hướng trở lại
    gần nhiệt độ môi trường. Phản ứng này phù hợp với nguyên lý NTC và đường
    chuyển đổi được triển khai trong NTC Device
    #cite-ref(refs, "mit-thermistor") #cite-ref(refs, "eduframework-ntc").
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính chỉ sử dụng giá trị nhiệt độ cuối cùng để giữ chương trình
ngắn gọn. NTC Device còn cung cấp các API cho phép quan sát các đại lượng trung
gian của quá trình đo hoặc sử dụng các chế độ khác của module
#cite-ref(refs, "eduframework-ntc").

== Quan sát điện áp với `NTC_ReadMilliVolts()`

`NTC_ReadMilliVolts()` đọc ngõ ra analog của module và trả về giá trị đã được
quy đổi sang millivolt thông qua Analog API của EduFramework
#cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadMilliVolts",
  syntax: [NTC_ReadMilliVolts(pin);],
  description: [
    Đọc điện áp tại ngõ ra analog của module NTC và trả về giá trị theo
    millivolt.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Chân analog nối với `AO` của module NTC.],
    ),
  ),
  returns: [
    Điện áp theo millivolt khi thành công; `-1` nếu chân không hợp lệ hoặc phép
    đọc ADC thất bại.
  ],
)

Ví dụ:

```c
int voltageMv = NTC_ReadMilliVolts(ADC0_SE13);
```

== Quan sát điện trở với `NTC_ReadResistance()`

`NTC_ReadResistance()` sử dụng điện áp đo được và cấu hình mạch chia áp của NTC
Device để tính điện trở thermistor #cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadResistance",
  syntax: [NTC_ReadResistance(pin);],
  description: [
    Tính điện trở NTC từ phép đo analog và trả về kết quả theo ohm.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Chân analog nối với `AO` của module NTC.],
    ),
  ),
  returns: [
    Điện trở theo ohm khi phép đo hợp lệ; `-1.0F` nếu phép đọc hoặc phép tính
    thất bại.
  ],
)

Ví dụ:

```c
float resistance = NTC_ReadResistance(ADC0_SE13);
```

*Mở rộng:* Sửa chương trình để in đồng thời điện áp, điện trở và nhiệt độ nhằm
quan sát chuỗi xử lý:

`Điện áp AO` → `Điện trở NTC` → `Nhiệt độ`.

Kết quả có thể trình bày theo dạng:

```text
Voltage: ... mV
Resistance: ... Ohm
Temperature: ... C
```

== Một số API NTC khác

EduFramework còn cung cấp các API bổ sung sau
#cite-ref(refs, "eduframework-ntc"):

- `NTC_ReadRaw(pin)` trả về giá trị ADC thô của ngõ vào analog.
- `NTC_ReadFahrenheit(pin)` trả về nhiệt độ theo độ Fahrenheit.
- `NTC_ReadThreshold(pin)` đọc trạng thái ngõ ra số `DO` của module NTC nếu
  phần cứng có comparator và chân này được kết nối.
- `NTC_SetConfig()` cho phép thay đổi cấu hình tính toán của NTC Device.
- `NTC_GetConfig()` đọc lại cấu hình NTC đang được sử dụng.

Các API cấu hình và ngõ ra `DO` không cần thiết cho bài thực hành chính. Chúng
phù hợp khi cần sử dụng loại NTC, mạch chia áp hoặc chế độ phát hiện ngưỡng khác
với cấu hình cơ bản #cite-ref(refs, "eduframework-ntc").

*Mở rộng:* Chọn một trong các API trên và bổ sung vào chương trình mà không thay
đổi chức năng đọc nhiệt độ chính. Ví dụ, hiển thị thêm nhiệt độ theo Fahrenheit
hoặc kết nối chân `DO` với một Digital Input để quan sát trạng thái ngưỡng.

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
