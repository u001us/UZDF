import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  
  // Координаты центра Ташкента
  final LatLng _tashkent = const LatLng(41.3111, 69.2406);

  // Рисуем одну тестовую запретную зону (например, район Алайского рынка)
  final Set<Polygon> _zones = {
    Polygon(
      polygonId: const PolygonId("restricted_1"),
      points: const [
        LatLng(41.3200, 69.2800),
        LatLng(41.3250, 69.2800),
        LatLng(41.3250, 69.2900),
        LatLng(41.3200, 69.2900),
      ],
      fillColor: Colors.red.withOpacity(0.4),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
  };

  // Функция проверки статуса
  Future<void> _checkFlightStatus() async {
    // Просим разрешение на геолокацию
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied) return;

    // Получаем текущие координаты
    Position position = await Geolocator.getCurrentPosition();

    // В будущем тут будет запрос к твоему Бэкенду (http.post)
    // А пока показываем красивое окно результата
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "АНАЛИЗ ЗОНЫ ПОЛЕТА",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("ОГРАНИЧЕННЫЙ ПОЛЕТ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Желтая зона", style: TextStyle(color: Colors.orange)),
                  ],
                )
              ],
            ),
            const Divider(height: 30),
            const Text("• Максимальная высота: 50 метров"),
            const Text("• Ограничение: Близость к гос. объектам"),
            const Text("• Требуется уведомление органов контроля"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("ПОНЯТНО", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _tashkent, zoom: 13),
            onMapCreated: (controller) => mapController = controller,
            polygons: _zones,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _checkFlightStatus,
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.flight_takeoff, color: Colors.white),
              label: const Text(
                "МОЖНО ЛИ ТУТ ЛЕТАТЬ?",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}