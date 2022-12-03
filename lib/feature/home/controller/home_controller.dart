import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:moneyp/feature/home/controller/expense_controller.dart';
import 'package:moneyp/feature/home/model/expense_model.dart';
import 'package:moneyp/feature/home/model/list_item_model.dart';
import 'package:moneyp/services/firestoredb.dart';
import 'package:moneyp/feature/home/controller/auth_controller.dart';
import 'package:moneyp/feature/home/model/user_model.dart';

class HomeController extends GetxController with StateMixin {
  Rx<HomeModel> homeModel = HomeModel().obs;
  HomeModel get homeModelValue => homeModel.value;
  set user(HomeModel value) => homeModel.value = value;

  Rx<int> grafikToplam = Rx<int>(0);
  Rx<List> expenseListYuzdeOran = Rx<List>([]);

  RxList<ListItemModel> expenseList = RxList<ListItemModel>([]);
  List<ListItemModel> get expenses => expenseList.value;

  AuthController controller = Get.find<AuthController>();

  @override
  void onInit() async {
    super.onInit();
    change(null, status: RxStatus.loading());
    expenseList.bindStream(FireStoreDb().expenseStream(controller
        .firebaseUser
        .value!
        .uid)); //Harcama listesini veritabanından anlık olarak izlemek için.
    getUserData();
  }

  getUserData() async {
    user = await FireStoreDb().getUser(controller.firebaseUser.value!.uid);
    do {
      if (expenseList.value.isNotEmpty) {
        grafikYuzdeHesaplama();
        change(null, status: RxStatus.success());
      }
    } while (expenseList.value.isEmpty);
  }

  grafikYuzdeHesaplama() {
    expenseListYuzdeOran.value.clear();
    grafikToplam.value = 0;
    int travelToplam = 0;
    int foodToplam = 0;
    int shoppingToplam = 0;
    int billingToplam = 0;
    int otherToplam = 0;
    expenseList.value.forEach((element) {
      if (element.expenseType == ExpenseModel.expenseItems[0][0]) {
        travelToplam = travelToplam + int.parse(element.expenseTotal!);
      } else if (element.expenseType == ExpenseModel.expenseItems[1][0]) {
        foodToplam = foodToplam + int.parse(element.expenseTotal!);
      } else if (element.expenseType == ExpenseModel.expenseItems[2][0]) {
        shoppingToplam = shoppingToplam + int.parse(element.expenseTotal!);
      } else if (element.expenseType == ExpenseModel.expenseItems[3][0]) {
        billingToplam = billingToplam + int.parse(element.expenseTotal!);
      } else {
        otherToplam = otherToplam + int.parse(element.expenseTotal!);
      }
    });
    grafikToplam.value = grafikToplam.value +
        travelToplam +
        foodToplam +
        shoppingToplam +
        billingToplam +
        otherToplam;

    expenseListYuzdeOran.value
        .insert(0, (travelToplam * 100) / grafikToplam.value);
    expenseListYuzdeOran.value
        .insert(1, (foodToplam * 100) / grafikToplam.value);

    expenseListYuzdeOran.value
        .insert(2, (shoppingToplam * 100) / grafikToplam.value);
    expenseListYuzdeOran.value
        .insert(3, (billingToplam * 100) / grafikToplam.value);
    expenseListYuzdeOran.value
        .insert(4, (otherToplam * 100) / grafikToplam.value);
  }
}