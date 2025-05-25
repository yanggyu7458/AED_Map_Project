import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'AED_info_update_form.dart';
import 'api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterNaverMap().init(
      clientId: 'jwmercsx95',
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) =>
            print("사용량 초과 (message: $message)"),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
            print("인증 실패: $ex"),
      });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AED 지도',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AEDMapPage(),
    );
  }
}

class AEDMapPage extends StatefulWidget {
  const AEDMapPage({super.key});

  @override
  State<AEDMapPage> createState() => _AEDMapPageState();
}

class _AEDMapPageState extends State<AEDMapPage> {
  late NaverMapController _mapController;
  List<NMarker> _markers = [];
  NLocationOverlay? _locationOverlay;

  /// 📌 현재 위치 가져오기
  Future<NLatLng?> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      print("❌ 위치 권한 거부됨");
      return null;
    }

    try {
      final settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(locationSettings: settings);
      return NLatLng(position.latitude, position.longitude);
    } catch (e) {
      print("❌ 위치 가져오기 실패: $e");
      return null;
    }
  }


  /// 📌 현재 지도 범위 기반 AED 데이터 불러오기
  Future<void> _loadMarkersInBounds() async {
    try {
      final aeds = await fetchAedsInBoundsFromMapController(_mapController);

      // 기존 마커 제거
      for (final marker in _markers) {
        _mapController.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: marker.info.id));
      }
      _markers.clear();

      // 새로운 마커 생성
      for (final aed in aeds) {
        final marker = NMarker(
          id: '${aed.id}_${aed.latitude}_${aed.longitude}',
          position: NLatLng(aed.latitude, aed.longitude),
          caption: NOverlayCaption(text: aed.orgName),
        );

        final aedCopy = aed;
        // 마커 클릭 시 상세 정보 다이얼로그 표시
        marker.setOnTapListener((NOverlay overlay) {
          print("🔍 마커 클릭됨: ${marker.info.id}");
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(aedCopy.orgName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("주소: ${aedCopy.buildAddress}"),
                  Text("위치: ${aedCopy.buildPlace}"),
                  Text("모델명: ${aedCopy.model}"),
                  Text("담당자: ${aedCopy.manager}"),
                  Text("전화번호: ${aedCopy.managerTel}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 기존 다이얼로그 닫기
                    showAedEditSuggestionForm(
                      context,
                      {
                        "orgName": aedCopy.orgName,
                        "buildAddress": aedCopy.buildAddress,
                        "buildPlace": aedCopy.buildPlace,
                        "model": aedCopy.model,
                        "manager": aedCopy.manager,
                        "managerTel": aedCopy.managerTel,
                      },
                          (updatedData, selectedImage, position) async {
                        await submitAedSuggestion(aedCopy.id, updatedData, selectedImage, position);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('정보 수정 제안이 제출되었습니다')),
                        );
                      },
                    );
                  },
                  child: const Text('정보 수정 제안'),
                ),
              ],
            ),
          );
        });

        try {
          await _mapController.addOverlay(marker); // 꼭 await로 처리
          _markers.add(marker);
        } catch (e) {
          print("❌ 마커 추가 실패: $e, id=${marker.info.id}");
        }
      }
    } catch (e) {
      print("AED 마커 불러오기 실패: $e");
    }
  }

  /// 📌 현재 위치로 카메라 이동 및 위치 아이콘 표시
  Future<void> _moveToCurrentLocation() async {
    final currentLocation = await _getCurrentLocation();
    if (currentLocation != null) {
      await _mapController.updateCamera(
        NCameraUpdate.withParams(
          target: currentLocation,
          zoom: 14,
        ),
      );

      // 위치 추적 모드 설정 (위치 아이콘 자동 표시)
      await _mapController.setLocationTrackingMode(NLocationTrackingMode.follow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AED 지도'),
          actions: [
          IconButton(
          icon: const Icon(Icons.my_location),
      onPressed: _moveToCurrentLocation,
    ),
    ],),
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5665, 126.9780), // 서울 중심 좌표
            zoom: 14,
          ),
          scrollGesturesEnable:  true,
          zoomGesturesEnable:  true
        ),
        onMapReady: (controller) async {
          _mapController = controller;

          await _moveToCurrentLocation();
          await _loadMarkersInBounds();// 첫 진입 시 로딩

          final currentLocation = await _getCurrentLocation();
          if (currentLocation != null) {
            await _mapController.updateCamera(
              NCameraUpdate.withParams(
                target: currentLocation,
                zoom: 14,
              ),
            );
          }
        },
        onCameraIdle: () {
          _loadMarkersInBounds(); // 지도 이동 완료 시 마커 재로딩
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
