import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: <NavigatorObserver>[
          routeObserver
        ],
        routes: {
          '/MapSample': (_) =>
              MapSample(
                  CameraPosition(
                    target: LatLng(0.0, 0.0),
                    zoom: 14.4746,
                  ),
                  routeObserver),
        },
        home: Scaffold(
          appBar: AppBar(title: Text('充電スポット一覧')),
          body: ListPage(),
        ));
  }
}

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery
        .of(context)
        .size;
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
            width: _screenSize.width * 0.8,
            height: _screenSize.height * 0.4,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'lib/images/image1.png',
                        width: 150,
                      ),
                      Image.asset(
                        'lib/images/image1.png',
                        width: 150,
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('日本ビル'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('利用可能'),
                      const SizedBox(width: 50),
                      Text('6'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('充電出力'),
                      const SizedBox(width: 50),
                      Text('3.2kW, 6.0kW')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('営業中'),
                      const SizedBox(width: 50),
                      Text('10:00 ~ 20:00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('定休日'),
                      const SizedBox(width: 50),
                      Text('第三土曜日')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              text: '地図アプリで経路を見る',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return MapSample(
                                            CameraPosition(
                                              target: LatLng(35.685255491019944,
                                                  139.76962079504972),
                                              zoom: 14.4746,
                                            ),
                                            routeObserver);
                                      }));
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

///Mapウェジェット
class MapSample extends StatefulWidget {
  final CameraPosition _selectedCameraPosition;
  final RouteObserver<PageRoute> routeObserver;

  MapSample(this._selectedCameraPosition, this.routeObserver);

  @override
  State<MapSample> createState() =>
      MapSampleState(_selectedCameraPosition, routeObserver);
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
    controller
        .animateCamera(CameraUpdate.newCameraPosition(_selectedCameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery
        .of(context)
        .size;
    Set<Marker> _markers = {
      Marker(
        markerId: MarkerId("marker1"),
        position: LatLng(35.685255491019944, 139.76962079504972),
      )
    };
    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: _markers,
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
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'lib/images/image1.png',
                        width: 150,
                      ),
                      Image.asset(
                        'lib/images/image1.png',
                        width: 150,
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('日本ビル'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('利用可能'),
                      const SizedBox(width: 50),
                      Text('6'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('充電出力'),
                      const SizedBox(width: 50),
                      Text('3.2kW, 6.0kW')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('営業中'),
                      const SizedBox(width: 50),
                      Text('10:00 ~ 20:00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text('定休日'),
                      const SizedBox(width: 50),
                      Text('第三土曜日')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              text: '地図アプリで経路を見る',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return MapSample(
                                            CameraPosition(
                                              target: LatLng(35.685255491019944,
                                                  139.76962079504972),
                                              zoom: 14.4746,
                                            ),
                                            routeObserver);
                                      }));
                                },
                            ),
                          ],
                        ),
                      ),
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