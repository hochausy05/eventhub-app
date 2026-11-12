import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_button.dart';
import 'package:eventhub_app/core/widgets/app_category_chip.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/core/widgets/app_event_card.dart';
import 'package:eventhub_app/core/widgets/app_section_header.dart';
import 'package:eventhub_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class DesignSystemPreviewPage extends StatefulWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  State<DesignSystemPreviewPage> createState() =>
      _DesignSystemPreviewPageState();
}

class _DesignSystemPreviewPageState extends State<DesignSystemPreviewPage> {
  bool _selected = true;

  void _showSampleMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bộ giao diện EventHub')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bản xem trước thành phần dùng chung.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Màu sắc'),
                  const SizedBox(height: AppSpacing.x3),
                  const Wrap(
                    spacing: AppSpacing.x2,
                    runSpacing: AppSpacing.x2,
                    children: [
                      _ColorToken(label: 'Indigo', color: AppColors.primary),
                      _ColorToken(label: 'Violet', color: AppColors.secondary),
                      _ColorToken(
                        label: 'Nền',
                        color: AppColors.background,
                        outlined: true,
                      ),
                      _ColorToken(
                        label: 'Thành công',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Kiểu chữ'),
                  const SizedBox(height: AppSpacing.x2),
                  Text('Tiêu đề màn hình', style: textTheme.headlineSmall),
                  Text('Tiêu đề mục', style: textTheme.titleLarge),
                  Text('Tiêu đề thẻ', style: textTheme.titleMedium),
                  Text(
                    'Nội dung dễ đọc bằng tiếng Việt.',
                    style: textTheme.bodyMedium,
                  ),
                  Text('Văn bản hỗ trợ', style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Nút'),
                  const SizedBox(height: AppSpacing.x2),
                  Wrap(
                    spacing: AppSpacing.x2,
                    runSpacing: AppSpacing.x2,
                    children: [
                      AppButton(
                        label: 'Nút chính',
                        leadingIcon: Icons.arrow_forward,
                        onPressed: () => _showSampleMessage('Mẫu nút chính.'),
                      ),
                      AppButton(
                        label: 'Nút phụ',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _showSampleMessage('Mẫu nút phụ.'),
                      ),
                      const AppButton(label: 'Đã tắt', onPressed: null),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Danh mục'),
                  const SizedBox(height: AppSpacing.x2),
                  Wrap(
                    spacing: AppSpacing.x2,
                    runSpacing: AppSpacing.x2,
                    children: [
                      AppCategoryChip(
                        label: 'Âm nhạc',
                        icon: Icons.music_note,
                        selected: _selected,
                        onSelected: (value) =>
                            setState(() => _selected = value),
                      ),
                      AppCategoryChip(
                        label: 'Công nghệ',
                        selected: !_selected,
                        onSelected: (value) =>
                            setState(() => _selected = !value),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Trường nhập liệu'),
                  const SizedBox(height: AppSpacing.x2),
                  const AppTextField(
                    label: 'Tên trường',
                    hint: 'Nhập nội dung mẫu',
                    leadingIcon: Icons.edit_outlined,
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Thẻ sự kiện'),
                  const SizedBox(height: AppSpacing.x2),
                  AppEventCard(
                    title: 'Đêm nhạc mùa hè — nội dung minh họa',
                    dateTimeLabel: '20:00, Thứ Bảy · 21/11',
                    locationLabel: 'Nhà hát Thành phố',
                    priceLabel: 'Từ 350.000 ₫',
                    categoryLabel: 'Âm nhạc',
                    onTap: () => _showSampleMessage('Thẻ minh họa giao diện.'),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Trạng thái trống'),
                  const SizedBox(height: AppSpacing.x2),
                  const AppEmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'Chưa có sự kiện',
                    description:
                        'Thành phần minh họa cho trạng thái chưa có nội dung.',
                  ),
                  const SizedBox(height: AppSpacing.x8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorToken extends StatelessWidget {
  const _ColorToken({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.button / 2),
              border: outlined ? Border.all(color: AppColors.border) : null,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
