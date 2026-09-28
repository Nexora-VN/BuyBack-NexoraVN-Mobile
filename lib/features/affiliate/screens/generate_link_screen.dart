import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/generate_link_panel.dart';

class GenerateLinkScreen extends StatelessWidget {
  const GenerateLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Tạo link cashback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GenerateLinkPanel(),
            const SizedBox(height: 18),

            // Guidelines & Notes Card (Matching FE generate-link-notes.tsx)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.helpCircle, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Lưu ý quan trọng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem(
                    icon: LucideIcons.check,
                    title: 'Chỉ mua hàng qua link đã tạo',
                    description: 'Sau khi tạo link, hãy bấm "Mua ngay" hoặc dán vào trình duyệt để mở Shopee/TikTok.',
                  ),
                  const SizedBox(height: 10),
                  _buildNoteItem(
                    icon: LucideIcons.clock3,
                    title: 'Thời gian đối soát đơn hàng',
                    description: 'Đơn hàng sẽ được hệ thống ghi nhận sau khi đơn hoàn tất và sàn đối soát chu kỳ thanh toán.',
                  ),
                  const SizedBox(height: 10),
                  _buildNoteItem(
                    icon: LucideIcons.wallet,
                    title: 'Hoa hồng chia sẻ 85%',
                    description: 'Bạn nhận 85% hoa hồng nhận được từ sàn thương mại điện tử, có thể rút về tài khoản ngân hàng bất cứ lúc nào khi đạt mức tối thiểu 50.000 ₫.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.softSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
