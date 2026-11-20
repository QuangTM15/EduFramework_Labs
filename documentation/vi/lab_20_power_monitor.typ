#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 20 - Power Monitoring with INA219
// Vietnamese version
// ============================================================================

// ============================================================================
// 0. TÀI LIỆU THAM KHẢO
// ============================================================================

#let refs = (
  (
    key: "ti-ina219",
    type: "datasheet",
    author: [Texas Instruments],
    title: [INA219 Zerø-Drift, Bidirectional Current/Power Monitor With I2C Interface],
    document: [SBOS448G],
    revision: [G],
    year: [2015],
    url: "https://www.ti.com/lit/ds/symlink/ina219.pdf",
  ),
  (
    key: "ti-power-monitor",
    type: "application-note",
    author: [Patrick Simmons, Texas Instruments],
    title: [Getting Started with Digital Power Monitors],
    document: [SBOA511A],
    revision: [A],
    year: [2021],
    url: "https://www.ti.com/lit/an/sboa511a/sboa511a.pdf",
  ),
  (
    key: "openstax-power",
    type: "web",
    author: [OpenStax],
    title: [University Physics Volume 2 - 9.5 Electrical Energy and Power],
    source: [Rice University, OpenStax],
    url: "https://openstax.org/books/university-physics-volume-2/pages/9-5-electrical-energy-and-power",
  ),
  (
    key: "nxp-s32k",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1xx],
    url: "https://www.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZ Edu Development Board - User Manual],
    revision: [1.0],
    year: [2025],
  ),
  (
    key: "eduframework-ina219",
    type: "web",
    author: [EduFramework],
    title: [INA219 Device API - ina219.h, Release v3.1.2],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework/blob/v3.1.2/eduframework/include/ina219.h",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 20,
  language: "vi",
  title: [Giám sát điện áp, dòng điện và công suất với INA219],
  subtitle: [Đo công suất tiêu thụ của tải dùng nguồn pin qua EduFramework],
)

// ============================================================================
// 1. GIỚI THIỆU
// ============================================================================

= Giới thiệu

== Tổng quan bài lab

Trong một mạch điện một chiều, điện áp và dòng điện là hai đại lượng cần thiết
để xác định công suất điện tại tải. Theo quan hệ công suất điện, việc quan sát
đồng thời các đại lượng này cho phép đánh giá mức tiêu thụ điện tức thời của
mạch #cite-ref(refs, "openstax-power").

INA219 là mạch tích hợp giám sát điện áp, dòng điện và công suất. Thiết bị đo
điện áp trên điện trở shunt mắc nối tiếp đường cấp nguồn và điện áp bus, sau đó
cung cấp dữ liệu đo qua giao diện số #cite-ref(refs, "ti-ina219").

Bài lab sử dụng INA219 Device API của EduFramework để giám sát một tải được
cấp nguồn từ bộ pin Li-ion hai cell mắc nối tiếp (2S). Chương trình đọc điện
áp bus, dòng điện và công suất, rồi hiển thị kết quả trên Serial Monitor.
Các thao tác cấu hình trực tiếp thanh ghi không thuộc phạm vi bài thực hành
chính #cite-ref(refs, "eduframework-ina219").

== Mục tiêu

#objectives(
  items: (
    [Phân biệt điện áp bus và điện áp trên điện trở shunt của INA219.],
    [Giải thích quan hệ giữa điện áp, dòng điện và công suất trong mạch tải DC.],
    [Kết nối INA219 với MaaZEDU và bố trí đường dòng điện qua tải.],
    [Sử dụng `INA_Begin()`, `INA_ReadBusVoltage()`, `INA_ReadCurrent()` và
      `INA_ReadPower()` để đọc và hiển thị các đại lượng đo.],
    [Đối chiếu kết quả khi đóng/ngắt tải và nhận biết giới hạn của phép đo.],
  ),
)

// ============================================================================
// 2. KIẾN THỨC NỀN
// ============================================================================

= Kiến thức nền

== Điện áp, dòng điện và công suất

Trong mạch điện DC, công suất điện tại một phần tử được xác định từ điện áp
đặt trên phần tử và dòng điện đi qua nó. Đối với tải thuần trở, quan hệ giữa
ba đại lượng được mô tả bởi định luật Ohm và công thức công suất
#cite-ref(refs, "openstax-power").

$ I = V / R $

$ P = V times I $

Trong đó, $V$ là điện áp (`V`), $I$ là dòng điện (`A`), $R$ là điện trở
(`Ω`) và $P$ là công suất (`W`). Khi báo cáo ở đơn vị `mA` và `mW`, tích của
điện áp tính bằng `V` với dòng điện tính bằng `mA` có đơn vị `mW`
#cite-ref(refs, "openstax-power").

#note[
  `P = V × I` là quan hệ vật lý dùng để kiểm tra tính hợp lý của kết quả.
  Giá trị công suất INA219 trả về được lấy từ thanh ghi tính toán của thiết
  bị, có lượng tử hóa theo hệ số hiệu chuẩn; vì vậy số hiển thị có thể không
  bằng chính xác tích hai số đã làm tròn trên Serial Monitor
  #cite-ref(refs, "ti-ina219").
]

== Nguyên lý đo dòng điện bằng điện trở shunt

INA219 đo điện áp chênh lệch giữa hai đầu điện trở shunt, với quy ước
$V_"shunt" = V_"IN+" - V_"IN−"$. Điện trở này nằm trên đường cấp nguồn tới
tải; dòng đi qua shunt cũng là dòng đi qua tải nếu mạch không có nhánh dòng
khác #cite-ref(refs, "ti-ina219").

$ I = V_"shunt" / R_"shunt" $

Module sử dụng trong bài thực hành có điện trở shunt ký hiệu `R100`, tương ứng
`0.1 Ω`. EduFramework Beginner API được cấu hình mặc định với giá trị này,
địa chỉ thiết bị `0x40` và mức dòng kỳ vọng `2 A`
#cite-ref(refs, "eduframework-ina219").

Ví dụ, nếu dòng điện đi qua shunt là `8 mA`, điện áp chênh lệch trên shunt
`0.1 Ω` chỉ khoảng `0.8 mV`. Datasheet INA219 quy định bước lượng tử hóa điện
áp shunt là `10 µV`; sai số offset và việc chọn shunt vì thế cần được chú ý
khi đo dòng nhỏ #cite-ref(refs, "ti-ina219")
#cite-ref(refs, "ti-power-monitor").

== Điện áp bus và dữ liệu công suất

INA219 đo *bus voltage* tại `VIN−` so với `GND`, đồng thời đo *shunt voltage*
giữa `VIN+` và `VIN−`. Hai phép đo không đồng nhất: khi có dòng điện đi qua
shunt, điện áp phía nguồn `VIN+` chênh lệch với điện áp bus một lượng bằng
điện áp shunt #cite-ref(refs, "ti-ina219").

$ V_"source" = V_"bus" + V_"shunt" $

Thanh ghi dòng điện và công suất sử dụng hệ số hiệu chuẩn do phần mềm thiết
lập. INA219 hỗ trợ đo điện áp bus trong miền hoạt động đến `26 V` ở đầu vào
đo và được cấp nguồn logic từ `3 V` đến `5.5 V`; đây là hai điện áp khác nhau,
không được nối nhầm #cite-ref(refs, "ti-ina219").

#note[
  Cơ chế truyền dữ liệu I2C đã được giới thiệu ở Lab 11. Lab 20 chỉ sử dụng
  hai đường `SDA`, `SCL` và API thiết bị, không trình bày lại giao thức I2C.
]

// ============================================================================
// 3. THIẾT LẬP PHẦN CỨNG
// ============================================================================

= Thiết lập phần cứng

== Phần cứng sử dụng

Bài thực hành sử dụng MaaZEDU Development Board với vi điều khiển S32K144
#cite-ref(refs, "nxp-s32k"), module INA219 có shunt `R100`, một bộ pin Li-ion `2S` có công tắc và một tải
điện trở. Trong lần kiểm thử đã thực hiện, tải được thay bằng quang trở (LDR);
do điện trở LDR phụ thuộc điều kiện chiếu sáng, kết quả dòng điện không được
xem là thông số cố định của tải #cite-ref(refs, "maazedu-guide")
#cite-ref(refs, "ti-ina219") #cite-ref(refs, "openstax-power").

#hardware-table(
  caption: [Phần cứng sử dụng trong Lab 20],
  rows: (
    ([MaaZEDU Development Board], [Board điều khiển S32K144 và giao tiếp Serial Monitor.]),
    ([INA219 module (`R100`)], [Đo điện áp bus và điện áp trên shunt `0.1 Ω`.]),
    ([Bộ pin Li-ion 2S có công tắc], [Nguồn điện DC cho nhánh tải được giám sát.]),
    ([Tải điện trở], [Tạo dòng điện qua shunt; nên ưu tiên điện trở cố định để đối chiếu định lượng.]),
    ([Dây nối và cáp USB], [Kết nối nguồn logic, I2C và máy tính.]),
  ),
)

== Ánh xạ chân và kết nối

Theo cấu hình chân của EduFramework trên MaaZEDU, `I2C0_SDA` dùng `PTA2`
và `I2C0_SCL` dùng `PTA3`. `INA_Begin()` tự khởi tạo tầng Wire; ứng dụng
không cần gọi `Wire_begin()` riêng khi dùng Beginner API
#cite-ref(refs, "eduframework-ina219").

#pin-table(
  caption: [Ánh xạ tín hiệu giữa INA219 và MaaZEDU],
  rows: (
    ([INA219 `SDA`], "I2C0_SDA", "PTA2", [Đường dữ liệu cảm biến.]),
    ([INA219 `SCL`], "I2C0_SCL", "PTA3", [Đường xung nhịp cảm biến.]),
  ),
)

Nối `VCC` của INA219 với `3.3V`, `GND` với `GND`, `SDA` với `I2C0_SDA` và
`SCL` với `I2C0_SCL`. Đường công suất của mạch tải phải được mắc theo thứ
tự: `Pin 2S (+) → VIN+ → VIN− → tải → Pin 2S (−)`. Cực âm pin phải nối
về `GND` chung với module INA219 và MaaZEDU; không nối cực dương bộ pin vào
đường `3.3V` của board #cite-ref(refs, "ti-ina219")
#cite-ref(refs, "maazedu-guide").

#figure-block(
  caption: [Sơ đồ kết nối MaaZEDU, INA219, tải và bộ pin 2S],
)[
  #image("../assets/circuits/power_monitor_circuit.png", width: 94%)
]

#warning[
  Phải ngắt pin trước khi lắp hoặc thay dây. Không nối tắt hai cực pin,
  không đấu trực tiếp pin vào hai đầu `VIN+` và `VIN−` khi thiếu tải.
  Sử dụng bộ pin có mạch bảo vệ phù hợp và kiểm tra điện trở, khả năng chịu
  công suất của tải trước khi đóng công tắc. Sơ đồ hình chỉ là minh họa;
  kết nối `GND` chung giữa cực âm pin và MaaZEDU phải được thực hiện đầy đủ
  #cite-ref(refs, "ti-ina219") #cite-ref(refs, "ti-power-monitor").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework v3.1.2 cung cấp Beginner API quản lý một INA219 ở địa chỉ
`0x40` với shunt mặc định `0.1 Ω`. Bài thực hành chính đọc từng đại lượng
qua ba hàm riêng và không cần tự tạo `INA219_t`
#cite-ref(refs, "eduframework-ina219").

== `INA_Begin()`

`INA_Begin()` khởi tạo bus Wire (nếu cần), thiết bị INA219 và hệ số hiệu
chuẩn mặc định. Hàm phải được gọi thành công trước các thao tác đọc
#cite-ref(refs, "eduframework-ina219").

#api-detail(
  name: "INA_Begin",
  syntax: [INA_Begin();],
  description: [Khởi tạo module INA219 mặc định trên bus I2C0.],
  parameters: (),
  returns: [`true` khi khởi tạo thành công; `false` nếu không thể khởi tạo thiết bị.],
)

== `INA_ReadBusVoltage()`

Hàm đọc điện áp tại `VIN−` so với `GND`, trả về đơn vị `V`. Kết quả chỉ được
sử dụng khi hàm trả về `true` #cite-ref(refs, "eduframework-ina219")
#cite-ref(refs, "ti-ina219").

#api-detail(
  name: "INA_ReadBusVoltage",
  syntax: [INA_ReadBusVoltage(voltage);],
  description: [Đọc điện áp bus của thiết bị mặc định.],
  parameters: (
    ([voltage], [Địa chỉ biến nhận kết quả], [Địa chỉ biến lưu điện áp theo `V`, ví dụ `&voltage`.]),
  ),
  returns: [`true` nếu đọc thành công; `false` khi không thể lấy dữ liệu.],
)

== `INA_ReadCurrent()` và `INA_ReadPower()`

`INA_ReadCurrent()` đọc dòng điện đã được hiệu chuẩn theo `mA`;
`INA_ReadPower()` đọc công suất từ thanh ghi của INA219 theo `mW`.
Giá trị dòng điện có dấu, phụ thuộc chiều dòng qua shunt
#cite-ref(refs, "eduframework-ina219") #cite-ref(refs, "ti-ina219").

#api-detail(
  name: "INA_ReadCurrent",
  syntax: [INA_ReadCurrent(current);],
  description: [Đọc dòng điện đã hiệu chuẩn theo `mA`.],
  parameters: (
    ([current], [Địa chỉ biến nhận kết quả], [Địa chỉ biến lưu dòng điện theo `mA`.]),
  ),
  returns: [`true` nếu đọc thành công; `false` nếu phép đọc thất bại.],
)

#api-detail(
  name: "INA_ReadPower",
  syntax: [INA_ReadPower(power);],
  description: [Đọc công suất tính toán theo `mW`.],
  parameters: (
    ([power], [Địa chỉ biến nhận kết quả], [Địa chỉ biến lưu công suất theo `mW`.]),
  ),
  returns: [`true` nếu đọc thành công; `false` nếu phép đọc thất bại.],
)

// ============================================================================
// 5. BÀI THỰC HÀNH
// ============================================================================

= Bài thực hành

== Yêu cầu

Viết chương trình khởi tạo INA219 và hiển thị ba đại lượng: điện áp bus (`V`),
dòng điện (`mA`) và công suất (`mW`). Sử dụng Serial1 với tốc độ `9600 baud`;
các lần in kết quả cách nhau một lệnh `delay(1000U)`. Khi khởi tạo không
thành công, chương trình thông báo lỗi và dừng thao tác đọc. Nếu một lần đọc
thất bại, chương trình báo lỗi và thử lại trong vòng lặp kế tiếp
#cite-ref(refs, "eduframework-ina219").

== Chương trình

Trong `src/main.c`, sử dụng chương trình với Beginner API đã kiểm thử trên
MaaZEDU:

#block(breakable: false)[
  #code-listing(
    caption: [Chương trình Lab 20 - giám sát điện áp, dòng điện và công suất],
  )[
    ```c
    #include "Arduino.h"
    #include "ina219.h"

    int main(void)
    {
        float voltage = 0.0f;
        float current = 0.0f;
        float power = 0.0f;

        setup();
        Serial1_begin(9600U);
        Serial1_println("=== Lab 20: INA219 Power Monitor ===");

        if (false == INA_Begin())
        {
            Serial1_println("INA219 initialization failed.");
            while (1)
            {
                delay(1000U);
            }
        }
        Serial1_println("INA219 initialized.");

        while (1)
        {
            if ((true == INA_ReadBusVoltage(&voltage)) &&
                (true == INA_ReadCurrent(&current)) &&
                (true == INA_ReadPower(&power)))
            {
                Serial1_print("Voltage: ");
                Serial1_printFloat(voltage);
                Serial1_println(" V");
                Serial1_print("Current: ");
                Serial1_printFloat(current);
                Serial1_println(" mA");
                Serial1_print("Power: ");
                Serial1_printFloat(power);
                Serial1_println(" mW");
                Serial1_println("------------------------");
            }
            else
            {
                Serial1_println("INA219 read failed.");
            }
            delay(1000U);
        }
        return 0;
    }
    ```
  ]
]

== Giải thích chương trình

`setup()` chuẩn bị môi trường EduFramework và `Serial1_begin(9600U)` mở cổng
giám sát. `INA_Begin()` thiết lập cảm biến tại địa chỉ mặc định. Khi khởi tạo
thành công, ba hàm đọc lần lượt ghi giá trị vào `voltage`, `current` và
`power` #cite-ref(refs, "eduframework-ina219").

Điều kiện `&&` yêu cầu cả ba phép đọc thành công trước khi in dữ liệu.
Các giá trị được lấy bằng những giao dịch đọc liên tiếp, không phải một
khung mẫu đồng thời. `delay(1000U)` là thời gian chờ giữa hai lượt xử lý;
chu kỳ hiển thị còn phụ thuộc thời gian đọc và xuất Serial
#cite-ref(refs, "eduframework-ina219").

== Kiểm chứng

Biên dịch và nạp chương trình, mở Serial Monitor ở `9600 baud`. Khi công tắc
nguồn tải đang ngắt, không có dòng qua nhánh tải lý tưởng; khi đóng công tắc,
điện áp bus, dòng điện và công suất được cập nhật theo điều kiện mạch thực tế
#cite-ref(refs, "openstax-power") #cite-ref(refs, "ti-ina219").

Ví dụ dữ liệu quan sát được trong lần kiểm thử với tải quang trở, khi đóng
công tắc bộ pin 2S:

```text
Voltage: 7.952 V
Current: 1.200 mA
Power: 10.000 mW
------------------------
```

Các giá trị trên là *dữ liệu thực nghiệm tham khảo*, không phải thông số
chuẩn hoặc giới hạn bảo đảm của INA219. Điện trở tải, ánh sáng, trạng thái
pin và sai số phép đo có thể làm kết quả thay đổi. Mức công suất hiển thị
cũng chịu ảnh hưởng của độ phân giải thanh ghi công suất
#cite-ref(refs, "ti-ina219") #cite-ref(refs, "ti-power-monitor").

#block(breakable: false)[
  #expected-result[
    Khi cấp điện cho nhánh tải, Serial Monitor hiển thị điện áp bus, dòng điện
    và công suất bằng các đơn vị tương ứng. Khi ngắt tải, dòng điện và công suất
    đo được có xu hướng về gần không; số liệu nhỏ khác không có thể xuất hiện
    do giới hạn đo và offset của cảm biến.
  ]
]

// ============================================================================
// 6. MỞ RỘNG
// ============================================================================

= Mở rộng

Bài thực hành chính sử dụng một cảm biến ở cấu hình mặc định. Các API khác
của EduFramework cho phép đọc điện áp shunt, đọc gộp nhiều đại lượng hoặc
quản lý một đối tượng INA219 riêng khi cần thay đổi shunt và cấu hình đo
#cite-ref(refs, "eduframework-ina219").

== Đọc điện áp shunt và một khung dữ liệu

Nhóm Beginner API bổ sung các chức năng sau:

#info-table(
  columns: (2.0fr, 3.0fr),
  alignments: (left + horizon, left + horizon),
  headers: ([API], [Chức năng]),
  rows: (
    ([`INA_IsInitialized()`], [Kiểm tra trạng thái khởi tạo thiết bị mặc định.]),
    ([`INA_ReadShuntVoltage()`], [Đọc điện áp chênh lệch `VIN+ − VIN−` theo `mV`.]),
    ([`INA_ReadData()`], [Đọc bốn đại lượng vào một biến `INA_Data_t`.]),
    ([`INA_GetLastStatus()`], [Lấy mã trạng thái gần nhất để hỗ trợ chẩn đoán.]),
  ),
  caption: [Các Beginner API bổ sung của INA219],
)

Để quan sát điện áp trên điện trở shunt, khai báo một biến `float` và truyền
địa chỉ biến vào `INA_ReadShuntVoltage()`. Kết quả dương khi chiều dòng phù
hợp với quy ước từ `VIN+` sang `VIN−`
#cite-ref(refs, "eduframework-ina219") #cite-ref(refs, "ti-ina219").

```c
float shuntMv = 0.0f;
if (true == INA_ReadShuntVoltage(&shuntMv))
{
    Serial1_printFloat(shuntMv);
}
```

Khi cần cả bốn đại lượng, `INA_ReadData()` nhận địa chỉ của `INA_Data_t`.
Biến này chỉ lưu kết quả đo; trạng thái và hiệu chuẩn của thiết bị mặc định
vẫn do driver quản lý nội bộ #cite-ref(refs, "eduframework-ina219").

```c
INA_Data_t data = {0};
if (true == INA_ReadData(&data))
{
    Serial1_printFloat(data.busVoltageV);
    Serial1_printFloat(data.shuntVoltageMv);
    Serial1_printFloat(data.currentMa);
    Serial1_printFloat(data.powerMw);
}
```

== Advanced API và ngữ cảnh thiết bị

Khác với Beginner API, nhóm Advanced API sử dụng `INA219_t` do ứng dụng
khai báo. Mỗi ngữ cảnh lưu địa chỉ I2C, điện trở shunt, hệ số hiệu chuẩn và
cấu hình chuyển đổi. Tầng Wire phải được khởi tạo trước bằng `Wire_begin()`
#cite-ref(refs, "eduframework-ina219").

#info-table(
  columns: (2.2fr, 2.8fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Advanced API], [Vai trò]),
  rows: (
    ([`INA219_begin()`], [Khởi tạo ngữ cảnh với địa chỉ, shunt và dòng kỳ vọng.]),
    ([`INA219_readData()`], [Đọc bốn đại lượng vào `INA_Data_t`.]),
    ([`INA219_setCalibration()`], [Tính lại hiệu chuẩn theo shunt và dòng kỳ vọng.]),
    ([`INA219_getDefaultConfig()`], [Lấy cấu hình mặc định vào `INA219_Config_t`.]),
    ([`INA219_configure()`], [Ghi cấu hình dải đo, ADC và chế độ hoạt động.]),
    ([`INA219_readSourceVoltage()`], [Đọc điện áp ước tính tại `VIN+`.]),
  ),
  caption: [Các Advanced API tiêu biểu của INA219],
)

Ví dụ, khi sử dụng một module có điện trở shunt thực tế `0.02 Ω`, ứng dụng
phải truyền đúng điện trở này trong lời gọi `INA219_begin()` thay vì tiếp tục
giả định `0.1 Ω`. Hàm trả về mã `INA219_STATUS_OK` nếu khởi tạo thành công;
các hàm Advanced API khác cũng sử dụng mã trạng thái thay cho giá trị
`true`/`false` #cite-ref(refs, "eduframework-ina219").

#block(breakable: false)[
  #code-listing(
    caption: [Ví dụ nguyên tắc sử dụng Advanced API với shunt tùy chọn],
  )[
    ```c
    INA219_t ina = {0};
    INA_Data_t data = {0};

    Wire_begin();
    if (INA219_STATUS_OK == INA219_begin(
            &ina, 0x40U, 0.02f, 2.0f))
    {
        if (INA219_STATUS_OK == INA219_readData(&ina, &data))
        {
            Serial1_printFloat(data.currentMa);
        }
    }
    ```
  ]
]

Đây là đoạn minh họa cách sử dụng API bên trong một ứng dụng đã khởi tạo
`Serial1`; không thay thế toàn bộ `main.c` của bài thực hành chính. Chỉ sử
dụng giá trị `0.02 Ω` khi module thực tế mang shunt tương ứng. Thay đổi tham
số trong chương trình không làm thay đổi điện trở hoặc khả năng chịu dòng
của phần cứng #cite-ref(refs, "eduframework-ina219")
#cite-ref(refs, "ti-power-monitor").

== Bài tập mở rộng

Thay tải quang trở bằng một điện trở cố định có giá trị đã đo bằng đồng hồ
vạn năng và công suất định mức phù hợp. Sau khi xác nhận mạch không có kết nối
sai, thực hiện các phép đo điện áp, dòng điện, công suất rồi tính dòng điện
và công suất lý thuyết theo giá trị điện trở. Ghi lại độ chênh lệch và nêu
những nguyên nhân có thể ảnh hưởng phép đo như sai số điện trở, offset và
độ phân giải của INA219 #cite-ref(refs, "openstax-power")
#cite-ref(refs, "ti-power-monitor").

#expected-result[
  Có bảng đối chiếu giữa giá trị tính toán từ tải cố định và giá trị hiển thị
  trên Serial Monitor. Không kết luận độ chính xác của cảm biến chỉ từ một
  lượt đo; cần biết giá trị tham chiếu và điều kiện đo thực tế.
]

// ============================================================================
// 7. TÀI LIỆU THAM KHẢO
// ============================================================================

= Tài liệu tham khảo

#references(refs)
