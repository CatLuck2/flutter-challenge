import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(
    MyApp()
  );
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// 充電器に関するクラス郡
/// 各充電スポットのデータ
class ChargerSpot {
  final String name;
  final Set<String> power;
  final String startTime;
  final String endTime;
  final String businessHoliday;
  final double latitude;
  final double longitude;

  ChargerSpot(
      this.name,
      this.power,
      this.startTime,
      this.endTime,
      this.businessHoliday,
      this.latitude,
      this.longitude);
}

/// 充電器に関するメソッド郡
/// APIからデータを取得
Future<List<ChargerSpot>> fetch() async {
  final _url = 'https://stg.evene.jp/api/charger_spots/?results=20';
  try {
    final response = await http.get(Uri.parse(_url));
    final responseJson = await json.decode(response.body);
    print(responseJson);
    // 取得したjsonをsetJsonDataへ渡す
    return createChargerSpots(responseJson);
  } on Exception catch (e) {
    print(e);
    return [];
  }
}
Future<List<ChargerSpot>> createChargerSpots(Map<String, dynamic> json) async {
  List<ChargerSpot> chargersSpots = [];
  // charger_spotsの各要素で処理を行う
  for (var i = 0; i < json['charger_spots'].length; i++) {
    // nameを取得
    String name = json['charger_spots'][i]['name'];
    // powerを取得
    Set<String> power = <String>{};
    final chargerDevices = json['charger_spots'][i]['charger_devices'];
    for (var b = 0; b < chargerDevices.length; b++) {
      power.add(chargerDevices[b]['power']);
    }
    // startTime, endTimeを取得
    String startTime = '';
    String endTime = '';
    final serviceTimes = json['charger_spots'][i]['charger_spot_service_times'];
    for (var v = 0; v < serviceTimes.length; v++) {
      if (serviceTimes[v]['business_day'] == 'yes') {
        startTime = serviceTimes[v]['start_time'];
        endTime = serviceTimes[v]['end_time'];
      }
    }
    // businessHolidayを取得
    String businessHoliday = '';
    for (var a = 0; a < serviceTimes.length; a++) {
      if (serviceTimes[a]['business_day'] == 'no') {
        businessHoliday = serviceTimes[a]['day'];
      }
    }
    // latitude, lontitudeを取得
    final double latitude = json['charger_spots'][i]['latitude'];
    final double longitude = json['charger_spots'][i]['longitude'];
    ChargerSpot chargerSpot = ChargerSpot(
      name,
      power,
      startTime,
      endTime,
      businessHoliday,
      latitude,
      longitude
    );
    chargersSpots.add(chargerSpot);
  }
  return chargersSpots;
}

  /// MyApp
class MyApp extends StatelessWidget {

  // Widget projectWidget() {
  //   return FutureBuilder(
  //     future: fetch(),
  //     builder: (BuildContext context, AsyncSnapshot<List<ChargerSpot>> snapshot) {
  //       if (snapshot.connectionState != ConnectionState.done) {
  //         return CircularProgressIndicator();
  //       }
  //
  //       if (snapshot.hasData) {
  //         return ListView.builder(
  //             itemCount: snapshot.data!.length,
  //             itemBuilder: (context, index) {
  //               return ListPage(snapshot.data![index]);
  //             }
  //         );
  //       } else {
  //         return Text("データが存在しません");
  //       }
  //     },
  //   );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: <NavigatorObserver>[routeObserver],
        routes: {
          '/MapSample' : (_) => MapSample(
              CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 14.4746,
              ),
              routeObserver),
        },
        home: Scaffold(
          appBar: AppBar(title: Text('ListView')),
          body: ListPage(),
        )
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {

  late final List<ChargerSpot> chargerSpots;

  @override
  void initState() {
    super.initState();
    chargerSpots = fetch() as List<ChargerSpot>;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return MapSample(
      //         CameraPosition(
      //           target: LatLng(chargerSpot.latitude, chargerSpot.longitude),
      //           zoom: 14.4746,
      //         ),
      //         routeObserver
      //     );
      //   }));
      // },
      child: ListView.builder(
        itemCount: chargerSpots.length,
        itemBuilder: (context, index) {
          return Container(
            child: Card(
              color: Colors.orange,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage("lib/images/image1.png")
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage("lib/images/image1.png")
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(chargerSpots[index].name),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('利用可能'),
                      const SizedBox(width: 50),
                      Text(''),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('充電出力'),
                      const SizedBox(width: 50),
                      Text('$chargerSpots[index].power')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('営業中'),
                      const SizedBox(width: 50),
                      Text(chargerSpots[index].startTime + '~' + chargerSpots[index].endTime),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('定休日'),
                      const SizedBox(width: 50),
                      Text(chargerSpots[index].businessHoliday)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        child: const Text('地図アプリで経路を見る'),
                        onPressed: () {/* ... */},
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

// ///ListViewウィジェット
// class ListPage extends StatelessWidget {
//   // const ListPage({Key? key}) : super(key: key);
//   final ChargerSpot chargerSpot;
//
//   ListPage(this.chargerSpot);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(builder: (context) {
//             return MapSample(
//               CameraPosition(
//                 target: LatLng(chargerSpot.latitude, chargerSpot.longitude),
//                 zoom: 14.4746,
//               ),
//               routeObserver
//             );
//           }));
//         },
//         child: Container(
//           child: Card(
//             color: Colors.orange,
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Container(
//                       height: 100,
//                       width: 100,
//                       decoration: const BoxDecoration(
//                         // color: Colors.green,
//                         image: DecorationImage(
//                             fit: BoxFit.fitWidth,
//                             image: AssetImage("lib/images/image1.png")
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 100,
//                       width: 100,
//                       decoration: const BoxDecoration(
//                         // color: Colors.green,
//                         image: DecorationImage(
//                             fit: BoxFit.fitWidth,
//                             image: AssetImage("lib/images/image1.png")
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 ListTile(
//                   title: Text(chargerSpot.name),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     const SizedBox(width: 10),
//                     Text('利用可能'),
//                     const SizedBox(width: 50),
//                     Text('dddd')
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     const SizedBox(width: 10),
//                     Text('充電出力'),
//                     const SizedBox(width: 50),
//                     Text(chargerSpot.power.first),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     const SizedBox(width: 10),
//                     Text('営業中'),
//                     const SizedBox(width: 50),
//                     Text(chargerSpot.startTime + '~' + chargerSpot.endTime),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     const SizedBox(width: 10),
//                     Text('定休日'),
//                     const SizedBox(width: 50),
//                     Text(chargerSpot.businessHoliday)
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     TextButton(
//                       child: const Text('地図アプリで経路を見る'),
//                       onPressed: () {/* ... */},
//                     ),
//                     const SizedBox(width: 8)
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//     );
//   }



///Mapウェジェット
class MapSample extends StatefulWidget {
  final CameraPosition _selectedCameraPosition;
  final RouteObserver<PageRoute> routeObserver;

  MapSample(this._selectedCameraPosition, this.routeObserver);

  @override
  State<MapSample> createState() => MapSampleState(_selectedCameraPosition, routeObserver);
}

class MapSampleState extends State<MapSample> with RouteAware {
  Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _selectedCameraPosition;
  final RouteObserver<PageRoute> routeObserver;

  MapSampleState(this._selectedCameraPosition, this.routeObserver);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  Future<void> didPush() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_selectedCameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment(1.0, -0.8),
            child: Form(
              child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.lightGreenAccent,
                    filled: true,
                    hintText: 'このエリアでポートを検索',
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Card(
              color: Colors.orange,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage("lib/images/image1.png")
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage("lib/images/image1.png")
                          ),
                        ),
                      ),
                    ],
                  ),
                  const ListTile(
                    title: Text('The Enchanted Nightingale'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('利用可能'),
                      const SizedBox(width: 50),
                      Text('10')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('充電出力'),
                      const SizedBox(width: 50),
                      Text('10')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('営業中'),
                      const SizedBox(width: 50),
                      Text('10')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('定休日'),
                      const SizedBox(width: 50),
                      Text('10')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        child: const Text('地図アプリで経路を見る'),
                        onPressed: () {/* ... */},
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}