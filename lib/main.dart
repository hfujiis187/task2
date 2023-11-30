import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PopupController _popupController = PopupController();

  Future<List<LatLng>> loadGeoJson(String fileName) async {
    String data = await rootBundle.loadString('assets/$fileName');
    var jsonData = json.decode(data);
    List<LatLng> points = [];
    for (var feature in jsonData['features']) {
      var coords = feature['geometry']['coordinates'];
      points.add(LatLng(coords[1], coords[0]));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        loadGeoJson('geojson_file_1.geojson'),
        loadGeoJson('geojson_file_2.geojson'),
        loadGeoJson('geojson_file_3.geojson'),
        loadGeoJson('geojson_file_4.geojson'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return CircularProgressIndicator();
        }
        List<Marker> markers = [];
        for (var points in snapshot.data!) { // Use null check operator (!)
          for (var point in points) {
            markers.add(Marker(
              width: 80.0,
              height: 80.0,
              point: point,
              builder: (ctx) => Container(
                child: FlutterLogo(),
              ),
            ));
          }
        }
        return FlutterMap(
          options: MapOptions(
            center: LatLng(35.6895, 139.6917), // Tokyo
            zoom: 13.0,
            plugins: [
              MarkerClusterPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              size: Size(40, 40),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: markers,
              polygonOptions: PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              popupOptions: PopupOptions(
                  popupSnap: PopupSnap.markerTop, // Use PopupSnap.markerTop instead of PopupSnap.top
                  popupController: _popupController,
                  popupBuilder: (_, marker) => Text('Popup')),
              builder: (context, markers) {
                return FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: null,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
