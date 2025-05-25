import 'dart:convert';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

class AedInfo {
  final int id;
  final String orgName;
  final double latitude;
  final double longitude;
  final String buildAddress;
  final String buildPlace;
  final String manager;
  final String managerTel;
  final String model;

  AedInfo({
    required this.id,
    required this.orgName,
    required this.latitude,
    required this.longitude,
    required this.buildAddress,
    required this.buildPlace,
    required this.manager,
    required this.managerTel,
    required this.model,
  });

  /// JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory AedInfo.fromJson(Map<String, dynamic> json){
    return AedInfo(
      id: json['id'],
      orgName: json['orgName'] ?? '이름 없음',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      buildAddress: json['buildAddress'] ?? '',
      buildPlace: json['buildPlace'] ?? '',
      manager: json['manager'] ?? '',
      managerTel: json['managerTel'] ?? '',
      model: json['model'] ?? '',
  );
  }
}

Future<List<AedInfo>> fetchAedsInBoundsFromMapController(NaverMapController controller) async {
  final bounds = await controller.getContentBounds();
  final south = bounds.southWest.latitude;
  final west = bounds.southWest.longitude;
  final north = bounds.northEast.latitude;
  final east = bounds.northEast.longitude;

  final uri = Uri.parse(
    'http://192.168.219.103:8080/api/aeds?south=$south&west=$west&north=$north&east=$east',
  );

  final response = await http.get(
    uri,
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    print("서버 응답 개수: ${data.length}");
    return data.map((e) => AedInfo.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load AED data');
  }
}

/// Spring Boot API에서 AED 목록을 가져오는 함수
Future<List<AedInfo>> fetchAeds() async {
  final response = await http.get(
    Uri.parse('http://192.168.219.103:8080/api/aeds'), //애뮬레이터용
    headers: {'Accept': 'application/json'}, // 응답 형식 명시
  );
  print("서버 응답: ${response.body}");
  // 요청 성공 시, JSON 파싱 후 AedInfo 리스트 반환
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    print("서버 응답 개수: \${data.length}");
    return data.map((e) => AedInfo.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load AED data');
  }
}