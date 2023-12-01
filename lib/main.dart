import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Map')),
        body: FutureBuilder(
          future: rootBundle.loadString('assets/geojson_file_1.geojson'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var geojson = GeoJson();
            geojson.processedLines.listen((GeoJsonLine line) {
              // Handle processed lines here
            });
            geojson.processedPolygons.listen((GeoJsonPolygon polygon) {
              // Handle processed polygons here
            });
            geojson.endSignal.listen((_) => geojson.dispose());
            geojson.parse(snapshot.data, verbose: true);

            return FlutterMap(
              options: MapOptions(
                center: LatLng(43.062087, 141.354404), // 北海道の緯度と経度
                zoom: 13.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(43.062087, 141.354404), // マーカーの位置
                      builder: (ctx) => Container(
                        child: FlutterLogo(),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
