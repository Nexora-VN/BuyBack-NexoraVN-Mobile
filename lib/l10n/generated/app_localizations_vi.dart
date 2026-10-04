// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get homeTitle => 'Xin chào!';

  @override
  String get homeDescription =>
      'Dán link Shopee để tạo link hoàn tiền và nhận lại một phần giá trị đơn hàng nhé.';

  @override
  String get linkCardTitle => 'Dán link Shopee';

  @override
  String get linkCardHint => 'Dán link sản phẩm để tạo link hoàn tiền';

  @override
  String get createCashbackLink => 'Tạo link hoàn tiền';

  @override
  String get creatingCashbackLink => 'Đang tạo link...';

  @override
  String get linkTitle => 'Tạo link mua sắm';

  @override
  String get linkLabel => 'Link sản phẩm Shopee';

  @override
  String get linkPlaceholder => 'Dán link Shopee vào đây';

  @override
  String get pasteLink => 'Dán link từ bộ nhớ tạm';

  @override
  String get clearLink => 'Xóa link';

  @override
  String get linkSuccess => 'Tạo link mua sắm thành công';

  @override
  String get shopeeOnly => 'Chỉ hỗ trợ link Shopee hợp lệ';

  @override
  String get estimatedCashback => 'Tiền hoàn ước tính';

  @override
  String get estimateUnavailable => 'Chưa có ước tính tiền hoàn';

  @override
  String get estimateNote =>
      'Số thực nhận có thể thay đổi sau khi Shopee xác nhận và đối soát đơn hàng.';

  @override
  String get helpTitle => 'Cách nhận tiền hoàn';

  @override
  String get helpStepOne =>
      'Nếu sản phẩm đã có trong giỏ, hãy xóa sản phẩm đó.';

  @override
  String get helpStepTwo => 'Tạo link tại Piggy Back và nhấn “Mua ngay”.';

  @override
  String get helpStepThree =>
      'Thêm sản phẩm vào giỏ và đặt hàng qua link vừa mở.';

  @override
  String get helpNote =>
      'Tiền hoàn phụ thuộc vào trạng thái đơn hàng và kết quả đối soát của Shopee.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navOrders => 'Đơn hàng';

  @override
  String get navWallet => 'Ví';

  @override
  String get navAccount => 'Tài khoản';

  @override
  String get walletAvailable => 'Bạn có thể rút';

  @override
  String get walletPending => 'Chờ xác nhận';

  @override
  String get walletReserved => 'Đang giữ để rút';

  @override
  String get withdraw => 'Rút tiền';

  @override
  String get recentOrders => 'Đơn hàng gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get creditedToWallet => 'Đã ghi nhận vào ví';

  @override
  String get walletReady => 'Tiền hoàn đã được ghi nhận vào ví';

  @override
  String get awaitingWallet => 'Chờ hoàn tất đối soát';
}
