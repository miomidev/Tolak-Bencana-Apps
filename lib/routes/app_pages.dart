import 'package:get/get.dart';
import '../modules/map/controllers/map_controller.dart';
import '../modules/map/views/map_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.map;

  static final routes = [
    GetPage(
      name: Routes.map,
      page: () => const MapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MapController>(() => MapController());
      }),
    ),
  ];
}
