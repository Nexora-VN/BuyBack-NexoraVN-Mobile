import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';

class GenerateLinkNotes extends StatelessWidget {
  const GenerateLinkNotes({super.key});

  @override
  Widget build(BuildContext context) {
    const notes = [
      'Nếu sản phẩm có trong giỏ hàng, bạn nhớ xóa ra khỏi giỏ nhe',
      'Nhấn “Mua ngay” trên trang này.',
      'Thêm lại sản phẩm và tiến hành đặt hàng.',
      '3 Điều trên giúp bạn hoàn tiền chính xác hơn đó!',
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.shoppingCart,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Vài lưu ý Piggy gửi tới bạn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < notes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.softSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notes[i],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pageTint,
              borderRadius: AppDimensions.roundedControl,
            ),
            child: const Text(
              'Đây là các bước giúp bạn thuận lợi hơn trong việc được hoàn tiền nè. Tuy nhiên vẫn sẽ dựa vào trạng thái đơn hàng Shopee, TikTok nếu có dấu hiệu gian lận đó nhen.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
