import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_application_with_figma/dio_setup.dart';

// 관측소 모델
class ObservationStation {
  final String id;
  final String name;
  final String lat;
  final String lon;

  ObservationStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });
}

// 51개의 관측소 정보
final List<ObservationStation> stations = [
  ObservationStation(id: "DT_0063", name: "가덕도", lat: "35.024", lon: "128.81"),
  ObservationStation(
      id: "DT_0032", name: "강화대교", lat: "37.731", lon: "126.522"),
  ObservationStation(id: "DT_0031", name: "거문도", lat: "34.028", lon: "127.308"),
  ObservationStation(id: "DT_0029", name: "거제도", lat: "34.801", lon: "128.699"),
  ObservationStation(
      id: "DT_0026", name: "고흥발포", lat: "34.481", lon: "127.342"),
  ObservationStation(id: "DT_0049", name: "광양", lat: "34.903", lon: "127.754"),
  ObservationStation(id: "DT_0042", name: "교본초", lat: "34.704", lon: "128.306"),
  ObservationStation(id: "DT_0018", name: "군산", lat: "35.975", lon: "126.563"),
  ObservationStation(id: "DT_0017", name: "대산", lat: "37.007", lon: "126.352"),
  ObservationStation(id: "DT_0057", name: "동해항", lat: "37.494", lon: "129.143"),
  ObservationStation(id: "DT_0062", name: "마산", lat: "35.197", lon: "128.576"),
  ObservationStation(id: "DT_0023", name: "모슬포", lat: "33.214", lon: "126.251"),
  ObservationStation(id: "DT_0007", name: "목포", lat: "34.779", lon: "126.375"),
  ObservationStation(id: "DT_0006", name: "묵호", lat: "37.55", lon: "129.116"),
  ObservationStation(id: "DT_0025", name: "보령", lat: "36.406", lon: "126.486"),
  ObservationStation(id: "DT_0005", name: "부산", lat: "35.096", lon: "129.035"),
  ObservationStation(
      id: "DT_0056", name: "부산항신항", lat: "35.077", lon: "128.784"),
  ObservationStation(id: "DT_0061", name: "삼천포", lat: "34.924", lon: "128.069"),
  ObservationStation(id: "DT_0010", name: "서귀포", lat: "33.24", lon: "126.561"),
  ObservationStation(
      id: "DT_0051", name: "서천마량", lat: "36.128", lon: "126.495"),
  ObservationStation(id: "DT_0022", name: "성산포", lat: "33.474", lon: "126.927"),
  ObservationStation(id: "DT_0093", name: "소무의도", lat: "37.373", lon: "126.44"),
  ObservationStation(id: "DT_0012", name: "속초", lat: "38.207", lon: "128.594"),
  ObservationStation(
      id: "IE_0061", name: "신안가거초", lat: "33.941", lon: "124.592"),
  ObservationStation(id: "DT_0008", name: "안산", lat: "37.192", lon: "126.647"),
  ObservationStation(id: "DT_0067", name: "안흥", lat: "36.674", lon: "126.129"),
  ObservationStation(id: "DT_0037", name: "어청도", lat: "36.117", lon: "125.984"),
  ObservationStation(id: "DT_0016", name: "여수", lat: "34.747", lon: "127.765"),
  ObservationStation(id: "DT_0092", name: "여호항", lat: "34.661", lon: "127.469"),
  ObservationStation(id: "DT_0003", name: "영광", lat: "35.426", lon: "126.42"),
  ObservationStation(
      id: "DT_0044", name: "영종대교", lat: "37.545", lon: "126.584"),
  ObservationStation(id: "DT_0043", name: "영흥도", lat: "37.238", lon: "126.428"),
  ObservationStation(
      id: "IE_0062", name: "옹진소청초", lat: "37.423", lon: "124.738"),
  ObservationStation(id: "DT_0027", name: "완도", lat: "34.315", lon: "126.759"),
  ObservationStation(id: "DT_0039", name: "왕돌초", lat: "36.719", lon: "129.732"),
  ObservationStation(id: "DT_0013", name: "울릉도", lat: "37.491", lon: "130.913"),
  ObservationStation(id: "DT_0020", name: "울산", lat: "35.501", lon: "129.387"),
  ObservationStation(id: "DT_0068", name: "위도", lat: "35.618", lon: "126.301"),
  ObservationStation(id: "IE_0060", name: "이어도", lat: "32.122", lon: "125.182"),
  ObservationStation(id: "DT_0001", name: "인천", lat: "37.451", lon: "126.592"),
  ObservationStation(
      id: "DT_0052", name: "인천송도", lat: "37.338", lon: "126.586"),
  ObservationStation(id: "DT_0024", name: "장항", lat: "36.006", lon: "126.687"),
  ObservationStation(id: "DT_0004", name: "제주", lat: "33.527", lon: "126.543"),
  ObservationStation(id: "DT_0028", name: "진도", lat: "34.377", lon: "126.308"),
  ObservationStation(id: "DT_0021", name: "추자도", lat: "33.961", lon: "126.3"),
  ObservationStation(id: "DT_0050", name: "태안", lat: "36.913", lon: "126.238"),
  ObservationStation(id: "DT_0014", name: "통영", lat: "34.827", lon: "128.434"),
  ObservationStation(id: "DT_0002", name: "평택", lat: "36.966", lon: "126.822"),
  ObservationStation(id: "DT_0091", name: "포항", lat: "36.051", lon: "129.376"),
  ObservationStation(id: "DT_0011", name: "후포", lat: "36.677", lon: "129.453"),
  ObservationStation(id: "DT_0035", name: "흑산도", lat: "34.684", lon: "125.435"),
]..sort((a, b) => a.name.compareTo(b.name));

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? selectedStationId;
  String apiResult = "";

  // API 호출 함수 (Dio 사용)
  Future<void> fetchData(String stationId) async {
    final String url = "/api/tide_combined?obsCode=$stationId";
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          apiResult = jsonEncode(response.data);
        });
      } else {
        setState(() {
          apiResult = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        apiResult = "Exception: $e";
      });
    }
  }

  /// 물때표(음력 정보) 위젯: 제목, 양력(측정일의 년월일)과 음력, 물때식을 표시
  Widget _buildLunarInfo(Map<String, dynamic> lunarInfo, String solarDate) {
    final lunarYear = lunarInfo["lunar_year"];
    final lunarMonth = lunarInfo["lunar_month"];
    final lunarDay = lunarInfo["lunar_day"];
    final tideInfo = lunarInfo["tide_info"];
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 영역
            Row(
              children: [
                Icon(Icons.table_chart, color: Color(0xFF4A68EA)),
                SizedBox(width: 8),
                Text(
                  "물때표",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A68EA),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color(0xFF4A68EA),
              thickness: 1,
              height: 16,
            ),
            // 양력 날짜 (측정일의 년월일; 물때식과 동일 스타일)

            const SizedBox(height: 8),
            // 음력 날짜 (기존 스타일)
            Text(
              "음력: $lunarYear-$lunarMonth-$lunarDay",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            // 물때식
            Text(
              "물때식: $tideInfo",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  /// 과거/예보 데이터(List) 디자인
  Widget _buildPastData(dynamic dataList) {
    if (dataList is! List) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "조석 예보",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (var item in dataList)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                (item["hl_code"] ?? "") == "고조"
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: (item["hl_code"] ?? "") == "고조"
                    ? Colors.redAccent
                    : Colors.blueAccent,
              ),
              title: Text(
                  "${item["hl_code"] ?? ""} / ${item["tph_level"] ?? ""} cm"),
              subtitle: Text("측정시각: ${item["tph_time"] ?? ""}"),
            ),
          ),
      ],
    );
  }

  /// 실시간 데이터(Map) 디자인 (추가 정보를 3행, 3행, 1행으로 배치)
  Widget _buildRecentData(dynamic dataMap) {
    if (dataMap is! Map) return const SizedBox();

    final recordTime = dataMap["record_time"] ?? "";
    final tideLevel = dataMap["tide_level"] ?? "";
    final waterTemp = dataMap["water_temp"] ?? "null";
    final airTemp = dataMap["air_temp"] ?? "null";
    final airPress = dataMap["air_press"] ?? "null";
    final windDir = dataMap["wind_dir"] ?? "null";
    final windSpeed = dataMap["wind_speed"] ?? "null";
    final currentDir = dataMap["current_dir"] ?? "null";
    final currentSpeed = dataMap["current_speed"] ?? "null";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "실시간",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 조위 정보와 측정 시각
                Row(
                  children: [
                    const Icon(Icons.water, color: Colors.blueAccent, size: 32),
                    const SizedBox(width: 8),
                    const Text(
                      "조위",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      "$tideLevel cm",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      recordTime,
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 추가 정보: 1행 (3개 항목)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem("기온 (℃)", airTemp),
                    _buildInfoItem("수온 (℃)", waterTemp),
                    _buildInfoItem("기압 (hPa)", airPress),
                  ],
                ),
                const SizedBox(height: 12),
                // 추가 정보: 2행 (3개 항목)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem("풍향 (°)", windDir),
                    _buildInfoItem("풍속 (m/s)", windSpeed),
                    _buildInfoItem("유향 (°)", currentDir),
                  ],
                ),
                const SizedBox(height: 12),
                // 추가 정보: 3행 (1개 항목, 왼쪽 정렬)
                _buildInfoItem("유속 (m/s)", currentSpeed),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 기타 정보 표시용 헬퍼 위젯
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// API 응답의 combined JSON (past, recent, lunar_info)를 파싱하여 섹션별 위젯 생성
  /// 순서: 관측소 정보 → 물때표 → 과거/예보 → 실시간
  Widget _buildTideDataView(String jsonString) {
    if (jsonString.isEmpty) return const SizedBox();

    try {
      final decoded = json.decode(jsonString);
      final pastSection = decoded["past"];
      final recentSection = decoded["recent"];
      final lunarInfo = decoded["lunar_info"];

      // meta 정보는 두 섹션 중 한 곳에서 추출 (우선 past)
      final pastMeta = pastSection?["result"]?["meta"] ?? {};
      final recentMeta = recentSection?["result"]?["meta"] ?? {};
      final meta = pastMeta.isNotEmpty ? pastMeta : recentMeta;

      final stationName = meta["obs_post_name"] ?? "알 수 없음";
      final stationLat = meta["obs_lat"] ?? "위도 없음";
      final stationLon = meta["obs_lon"] ?? "경도 없음";

      final pastDataList = pastSection?["result"]?["data"];
      final recentDataMap = recentSection?["result"]?["data"];

      // 양력 날짜(최근 측정 시간에서 년-월-일만 추출)
      String solarDate = "";
      if (recentDataMap != null && recentDataMap["record_time"] != null) {
        solarDate = (recentDataMap["record_time"] as String).split(" ")[0];
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2) 물때표 섹션 (양력 날짜는 물때식과 같은 스타일로 표시)
          if (lunarInfo != null) _buildLunarInfo(lunarInfo, solarDate),
          const SizedBox(height: 16),
          // 3) 과거/예보 섹션
          if (pastDataList != null) _buildPastData(pastDataList),
          const SizedBox(height: 16),
          // 4) 실시간 섹션
          if (recentDataMap != null) _buildRecentData(recentDataMap),

          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "$stationName\n위도: $stationLat, 경도: $stationLon",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Center(child: Text("JSON 파싱 오류: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA),
        title: const Text(
          "조석 예보",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF4F5F7),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 관측소 선택 영역
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("관측소 선택"),
                          value: selectedStationId,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStationId = newValue;
                            });
                          },
                          items: stations.map((station) {
                            return DropdownMenuItem<String>(
                              value: station.id,
                              child: Text(station.name),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 117, 141, 247),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (selectedStationId != null) {
                              fetchData(selectedStationId!);
                            } else {
                              setState(() {
                                apiResult = "관측소를 선택해주세요.";
                              });
                            }
                          },
                          child: const Text("데이터 요청"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 조위 데이터 출력 영역
                _buildTideDataView(apiResult),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
