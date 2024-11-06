import 'package:app17000ft_new/helper/api_services.dart';
import 'package:app17000ft_new/helper/shared_prefernce.dart';
import 'package:app17000ft_new/tourDetails/tour_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final List<String> _offlineTaskList = [];
  List<String> get offlineTaskList => _offlineTaskList;

  bool isLoading = true;

  final List<String> _onlineTaskList = [];
  List<String> get onlineTaskList => _onlineTaskList;

  String? _username;
  String? get username => _username;

  String? _email;
  String? get email => _email;

  String? _phone;
  String? get phone => _phone;

  String? _office;
  String? get office => _office;

  String? _empId;
  String? get empId => _empId;

  List<TourDetails> _onlineTourList = [];
  List<TourDetails> get onlineTourList => _onlineTourList;

  @override
  void onInit() {
    super.onInit();
    print('HomeController initialized');
    print('empId at onInit: $empId'); // Debug to ensure empId is accessible
    fetchData();
  }

  Future<void> fetchData() async {
    print('Fetching data...');
    isLoading = true;
    update();

    try {
      final userData = await SharedPreferencesHelper.getUserData();

      if (userData != null) {
        print('User data: $userData'); // Log the entire userData to check its structure
        final user = userData['user'];
        if (user != null) {
          _username = user['name'] as String?;
          _email = user['email'] as String?;
          _phone = user['phone'] as String?;
          _office = user['office_name'] as String?;
          _empId = user['emp_id'] as String?;

          // Log empId to ensure it's being set correctly
          print('empId fetched: $_empId');

          _offlineTaskList.clear(); // Clear list to avoid duplication
          final offlineTask = user['offlineTask'] as String? ?? '';
          _offlineTaskList.addAll(offlineTask.isNotEmpty ? offlineTask.split(',') : []);

          _onlineTourList = await ApiService().fetchTourIds(_office);
          print('Online tour list length: ${_onlineTourList.length}');
        } else {
          throw Exception("User data is missing in response");
        }
      } else {
        throw Exception("No user data available");
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
}
