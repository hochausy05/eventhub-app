import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/organizer/domain/services/event_management_service.dart';
import 'package:eventhub_app/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizerEventFormPage extends ConsumerWidget {
  const OrganizerEventFormPage({this.eventId, super.key});
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventId == null) return const _OrganizerEventForm();
    return ref
        .watch(eventByIdProvider(eventId!))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) => const _FormNotFound(),
          data: (event) => event == null || event.organizerId != demoOrganizerId
              ? const _FormNotFound()
              : _OrganizerEventForm(event: event),
        );
  }
}

class _OrganizerEventForm extends ConsumerStatefulWidget {
  const _OrganizerEventForm({this.event});
  final Event? event;
  @override
  ConsumerState<_OrganizerEventForm> createState() =>
      _OrganizerEventFormState();
}

class _OrganizerEventFormState extends ConsumerState<_OrganizerEventForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late EventCategory _category;
  late EventStatus _status;
  late String? _bannerPath;
  late DateTime _startsAt;
  late DateTime _endsAt;
  bool _saving = false;
  String? _saveError;

  List<Event> get _imageChoices => sampleEvents
      .where((event) => event.bannerAssetPath != null)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final start = DateTime.now().add(const Duration(days: 7));
    _startsAt =
        event?.startsAt ?? DateTime(start.year, start.month, start.day, 9);
    _endsAt = event?.endsAt ?? _startsAt.add(const Duration(hours: 3));
    _category = event?.category ?? EventCategory.technology;
    _status = event?.status == EventStatus.cancelled
        ? EventStatus.draft
        : event?.status ?? EventStatus.draft;
    _bannerPath = event?.bannerAssetPath ?? _imageChoices.first.bannerAssetPath;
    _controllers = {
      'title': TextEditingController(text: event?.title ?? ''),
      'summary': TextEditingController(text: event?.summary ?? ''),
      'description': TextEditingController(text: event?.description ?? ''),
      'venue': TextEditingController(text: event?.venueName ?? ''),
      'address': TextEditingController(text: event?.address ?? ''),
      'city': TextEditingController(text: event?.city ?? ''),
      'ticketName': TextEditingController(
        text: event?.ticketTypes.firstOrNull?.name ?? 'Vé tham dự',
      ),
      'price': TextEditingController(
        text: event?.ticketTypes.firstOrNull?.priceVnd.toString() ?? '0',
      ),
      'capacity': TextEditingController(
        text: event?.ticketTypes.firstOrNull?.capacity.toString() ?? '100',
      ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Vui lòng nhập $label.' : null;

  String? _nonNegativePrice(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) return 'Nhập giá vé bằng số nguyên VND.';
    if (parsed < 0) return 'Giá vé không được âm.';
    return null;
  }

  String? _capacity(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return 'Sức chứa phải là số nguyên lớn hơn 0.';
    }
    return null;
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('vi'),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final service = ref.read(eventManagementServiceProvider);
      final repository = ref.read(eventRepositoryProvider);
      final event = widget.event;
      if (event == null) {
        final created = service.createEvent(
          title: _controllers['title']!.text,
          summary: _controllers['summary']!.text,
          description: _controllers['description']!.text,
          category: _category,
          venueName: _controllers['venue']!.text,
          address: _controllers['address']!.text,
          city: _controllers['city']!.text,
          startsAt: _startsAt,
          endsAt: _endsAt,
          bannerAssetPath: _bannerPath,
          status: _status,
          ticketName: _controllers['ticketName']!.text,
          priceVnd: int.parse(_controllers['price']!.text.trim()),
          capacity: int.parse(_controllers['capacity']!.text.trim()),
        );
        await repository.createEvent(created);
      } else {
        final edited = Event(
          id: event.id,
          organizerId: event.organizerId,
          organizerName: event.organizerName,
          title: _controllers['title']!.text.trim(),
          summary: _controllers['summary']!.text.trim(),
          description: _controllers['description']!.text.trim(),
          category: _category,
          venueName: _controllers['venue']!.text.trim(),
          address: _controllers['address']!.text.trim(),
          city: _controllers['city']!.text.trim(),
          startsAt: _startsAt,
          endsAt: _endsAt,
          bannerAssetPath: _bannerPath,
          isFeatured: event.isFeatured,
          status: _status,
          ticketTypes: event.ticketTypes,
        );
        await service.updateEvent(original: event, edited: edited);
      }
      ref.invalidate(allEventsProvider);
      ref.invalidate(organizerEventsProvider);
      ref.invalidate(publishedEventsProvider);
      if (event != null) ref.invalidate(eventByIdProvider(event.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event == null ? 'Sự kiện đã được lưu.' : 'Đã cập nhật sự kiện.',
          ),
        ),
      );
      context.go(
        _status == EventStatus.published ? '/discovery' : '/organizer',
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _saveError = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      appBar: AppBar(
        title: Text(event == null ? 'Tạo sự kiện' : 'Chỉnh sửa sự kiện'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x2,
            AppSpacing.x4,
            AppSpacing.x8,
          ),
          children: [
            const _DemoNotice(),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Thông tin sự kiện',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.x2),
            _field(
              'title',
              'Tên sự kiện',
              validator: (value) => _required(value, 'tên sự kiện'),
            ),
            _field(
              'summary',
              'Mô tả ngắn',
              validator: (value) => _required(value, 'mô tả ngắn'),
            ),
            _field(
              'description',
              'Nội dung chi tiết',
              maxLines: 4,
              validator: (value) => _required(value, 'nội dung sự kiện'),
            ),
            const SizedBox(height: AppSpacing.x2),
            DropdownButtonFormField<EventCategory>(
              key: const ValueKey('event-category'),
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: EventCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: AppSpacing.x2),
            DropdownButtonFormField<String>(
              key: const ValueKey('event-banner'),
              initialValue:
                  _imageChoices.any(
                    (event) => event.bannerAssetPath == _bannerPath,
                  )
                  ? _bannerPath
                  : _imageChoices.first.bannerAssetPath,
              decoration: const InputDecoration(
                labelText: 'Ảnh minh họa có sẵn',
              ),
              items: _imageChoices
                  .map(
                    (event) => DropdownMenuItem(
                      value: event.bannerAssetPath,
                      child: Text(event.title, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _bannerPath = value),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text('Địa điểm', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.x2),
            _field(
              'venue',
              'Tên địa điểm',
              validator: (value) => _required(value, 'địa điểm'),
            ),
            _field(
              'address',
              'Địa chỉ',
              validator: (value) => _required(value, 'địa chỉ'),
            ),
            _field(
              'city',
              'Thành phố',
              validator: (value) => _required(value, 'thành phố'),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text('Thời gian', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.x2),
            _dateButton(
              'Bắt đầu',
              _startsAt,
              (value) => setState(() => _startsAt = value),
            ),
            _dateButton(
              'Kết thúc',
              _endsAt,
              (value) => setState(() => _endsAt = value),
            ),
            if (!_startsAt.isBefore(_endsAt))
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.x1),
                child: Text(
                  'Thời gian kết thúc phải sau thời gian bắt đầu.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Trạng thái xuất bản',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.x2),
            DropdownButtonFormField<EventStatus>(
              key: const ValueKey('event-status'),
              initialValue: _status == EventStatus.cancelled
                  ? EventStatus.draft
                  : _status,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items: const [
                DropdownMenuItem(
                  value: EventStatus.draft,
                  child: Text('Bản nháp'),
                ),
                DropdownMenuItem(
                  value: EventStatus.published,
                  child: Text('Đã xuất bản'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            if (_status == EventStatus.published)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.x2),
                child: Text(
                  'Sự kiện đã xuất bản cần có ngày bắt đầu trong tương lai.',
                ),
              ),
            const SizedBox(height: AppSpacing.x4),
            Text('Vé cơ bản', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.x2),
            if (event == null) ...[
              _field(
                'ticketName',
                'Tên loại vé',
                validator: (value) => _required(value, 'tên loại vé'),
              ),
              _field(
                'price',
                'Giá vé (VND)',
                keyboardType: TextInputType.number,
                validator: _nonNegativePrice,
              ),
              _field(
                'capacity',
                'Sức chứa',
                keyboardType: TextInputType.number,
                validator: _capacity,
              ),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.x3),
                  child: Text(
                    'Loại vé hiện tại được giữ nguyên. Thay đổi loại vé nằm ngoài phạm vi DEMO-06.',
                  ),
                ),
              ),
            if (_saveError != null) ...[
              const SizedBox(height: AppSpacing.x3),
              Text(_saveError!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.x5),
            FilledButton.icon(
              key: const ValueKey('save-event'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _saving
                    ? 'Đang lưu...'
                    : event != null
                    ? 'Lưu thay đổi'
                    : _status == EventStatus.published
                    ? 'Lưu và xuất bản'
                    : 'Lưu bản nháp',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.x2),
    child: TextFormField(
      key: ValueKey('field-$key'),
      controller: _controllers[key],
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _dateButton(
    String label,
    DateTime value,
    ValueChanged<DateTime> onSelected,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.x2),
    child: OutlinedButton.icon(
      key: ValueKey('date-$label'),
      onPressed: () async {
        final result = await _pickDateTime(value);
        if (result != null) onSelected(result);
      },
      icon: const Icon(Icons.calendar_month_outlined),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text('$label: ${formatEventDateTime(value)}', maxLines: 2),
      ),
    ),
  );
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();
  @override
  Widget build(BuildContext context) => const Card(
    color: AppColors.softIndigo,
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.x3),
      child: Text(
        'Dữ liệu được lưu trên thiết bị trong chế độ demo; chưa có duyệt sự kiện hoặc đồng bộ máy chủ.',
      ),
    ),
  );
}

class _FormNotFound extends StatelessWidget {
  const _FormNotFound();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chỉnh sửa sự kiện')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: AppSpacing.x3),
            const Text('Không tìm thấy sự kiện có thể chỉnh sửa.'),
            const SizedBox(height: AppSpacing.x3),
            TextButton(
              onPressed: () => context.go('/organizer'),
              child: const Text('Về bảng điều khiển'),
            ),
          ],
        ),
      ),
    ),
  );
}
