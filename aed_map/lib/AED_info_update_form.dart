/// AED 정보 수정 제안 기능 및 신규 AED 등록 기능 구현 아이디어

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

/// 1. AED 상세 정보 다이얼로그 하단에 '정보 수정 제안' 버튼 추가
void showAedEditSuggestionForm(BuildContext context, Map<String, String> currentData, Function(Map<String, String>, XFile?, Position?) onSubmit) {
  final formKey = GlobalKey<FormState>();
  final updatedData = Map<String, String>.from(currentData);
  XFile? selectedImage;
  Position? currentPosition;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('정보 수정 제안', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Form(
                key: formKey,
                child: Column(
                  children: currentData.entries.map((entry) {
                    return TextFormField(
                      initialValue: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                      onChanged: (value) => updatedData[entry.key] = value,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.photo_camera),
                label: Text('사진 업로드'),
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() => selectedImage = pickedFile);
                  }
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.my_location),
                label: Text('현재 위치 가져오기'),
                onPressed: () async {
                  final position = await Geolocator.getCurrentPosition();
                  setState(() => currentPosition = position);
                },
              ),
              if (currentPosition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('위도: ${currentPosition?.latitude}, 경도: ${currentPosition?.longitude}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('📷 사진이 선택됨: ${selectedImage?.name}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('제출'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    onSubmit(updatedData, selectedImage, currentPosition);
                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 2. AED 미설치 장소에서 'AED 등록 제안' 버튼 제공
///    - 지도 빈 공간을 길게 누르면 등록 제안 폼 표시
///    - 입력값: 위치 좌표 자동 기입, 건물명, 상세주소, 모델명, 담당자, 전화번호
///    - 서버로 POST 전송: /api/aeds/register

/// 3. Flutter UI 구성 제안
///    - showModalBottomSheet 로 등록/수정 제안 폼 띄우기
///    - Form 위젯 + TextFormField 조합
///    - 전송 시 SnackBar 또는 AlertDialog로 완료 안내

/// 4. API 요청 예시 (Dio or http)
Future<void> submitAedSuggestion(int id, Map<String, String> updates, XFile? photo, Position? location) async {
  final uri = Uri.parse('http://192.168.219.103:8080/api/aeds/$id/suggest');
  final request = http.MultipartRequest('POST', uri);
  request.fields.addAll(updates);
  if (location != null) {
    request.fields['latitude'] = location.latitude.toString();
    request.fields['longitude'] = location.longitude.toString();
  }
  if (photo != null) {
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
  }

  final response = await request.send();
  if (response.statusCode == 200) {
    print("✅ 정보 수정 제안 제출 성공");
  } else {
    print("❌ 제출 실패: \${response.statusCode}");
  }
}

Future<void> submitNewAed(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('http://192.168.219.103:8080/api/aeds/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode == 201) {
    // 등록 성공
  } else {
    // 에러 처리
  }
}
