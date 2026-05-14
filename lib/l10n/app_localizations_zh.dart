// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'IPOT POS';

  @override
  String get scanQrTitle => '扫描二维码';

  @override
  String get scanQrSubtitle => '将相机对准餐桌二维码';

  @override
  String get torch => '手电筒';

  @override
  String get flip => '翻转';

  @override
  String get useDemoTable => '使用演示餐桌 (T001)';

  @override
  String get invalidQrTitle => '无效的二维码';

  @override
  String get invalidQrDesc => '请扫描有效的餐厅餐桌二维码。';

  @override
  String get retry => '重试';

  @override
  String get menu => '菜单';

  @override
  String get searchMenu => '搜索菜单...';

  @override
  String get noItems => '未找到商品';

  @override
  String get loadingMenu => '正在加载菜单...';

  @override
  String get viewCart => '查看购物车';

  @override
  String get itemNotFound => '未找到商品';

  @override
  String get customizationsAvailable => '可选定制';

  @override
  String get addToCart => '加入购物车';

  @override
  String get myCart => '我的购物车';

  @override
  String get clear => '清除';

  @override
  String get clearCart => '清空购物车';

  @override
  String get clearCartConfirm => '从购物车中移除所有商品？';

  @override
  String get cancel => '取消';

  @override
  String get subtotal => '小计';

  @override
  String get tax => '税费 (10%)';

  @override
  String get taxDesc => '结账时计算';

  @override
  String get total => '总计';

  @override
  String get placeOrder => '下单';

  @override
  String get cartEmpty => '您的购物车是空的';

  @override
  String get browseMenuAdd => '浏览菜单并添加商品！';

  @override
  String get browseMenu => '浏览菜单';

  @override
  String get orderStatusTitle => '订单状态';

  @override
  String get orderMore => '继续点餐';

  @override
  String get orderReceivedDesc => '您的订单已收到！';

  @override
  String get orderConfirmedDesc => '太棒了！您的订单已确认。';

  @override
  String get orderPreparingDesc => '我们的厨师正在为您准备食物 🍳';

  @override
  String get orderReadyDesc => '您的订单已准备好！🎉';

  @override
  String get orderServedDesc => '祝您用餐愉快！😋';

  @override
  String get trackingOrder => '正在跟踪您的订单...';

  @override
  String get orderConfirmedMsg => '订单已确认！';

  @override
  String get autoUpdating => '每8秒自动更新';

  @override
  String get noActiveOrderQueued => '目前无进行中的订单 — 请查看下方排队订单';

  @override
  String get noActiveOrder => '目前无活动订单';

  @override
  String ordersInQueue(int count) {
    return '排队中的订单数：$count';
  }

  @override
  String get retryAll => '全部重试';

  @override
  String get willRetryWhenOnline => '连网时将重试';

  @override
  String get remove => '移除';

  @override
  String get offline => '离线';

  @override
  String get noInternet => '无网络连接';

  @override
  String get backOnline => '网络已恢复';

  @override
  String get requiredLabel => '必选';

  @override
  String get optionalLabel => '可选';

  @override
  String upToN(int max) {
    return '最多 $max 项';
  }

  @override
  String get specialInstructions => '特别说明（可选）';

  @override
  String addToCartPrice(String price) {
    return '加入购物车 — $price';
  }

  @override
  String get increaseQuantity => '增加数量';

  @override
  String get decreaseQuantity => '减少数量';

  @override
  String get orderReceivedState => '订单\n已收到';

  @override
  String get orderConfirmedState => '订单\n已确认';

  @override
  String get beingPreparedState => '正在\n准备';

  @override
  String get readyToServeState => '准备\n上餐';

  @override
  String get servedState => '已上餐!';
}
