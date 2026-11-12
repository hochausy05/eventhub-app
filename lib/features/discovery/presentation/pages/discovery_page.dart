import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_category_chip.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/core/widgets/app_event_card.dart';
import 'package:eventhub_app/core/widgets/app_section_header.dart';
import 'package:eventhub_app/core/widgets/app_text_field.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/featured_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final _searchController = TextEditingController();
  String _query = '';
  EventCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(publishedEventsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        key: const PageStorageKey('discovery-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x5,
          AppSpacing.x3,
          AppSpacing.x5,
          AppSpacing.x8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(
              title: 'Khám phá sự kiện',
              subtitle: 'Tìm cảm hứng cho trải nghiệm tiếp theo của bạn.',
            ),
            const SizedBox(height: AppSpacing.x4),
            AppTextField(
              key: const ValueKey('discovery-search-field'),
              controller: _searchController,
              leadingIcon: Icons.search,
              label: 'Tìm kiếm sự kiện',
              hint: 'Tên, danh mục, thành phố...',
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              trailingIcon: _query.trim().isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
            const SizedBox(height: AppSpacing.x5),
            eventsAsync.when(
              loading: () => const _LoadingEvents(),
              error: (error, stackTrace) => _EventLoadError(
                onRetry: () => ref.invalidate(publishedEventsProvider),
              ),
              data: (events) => _buildEventContent(context, events),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context, List<Event> events) {
    final categories = events.map((event) => event.category).toSet().toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    final filteredEvents = filterEvents(
      events: events,
      query: _query,
      category: _selectedCategory,
    );
    final featuredEvents = getFeaturedEvents(filteredEvents);
    final upcomingEvents = getUpcomingEvents(filteredEvents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryFilters(categories),
        const SizedBox(height: AppSpacing.x6),
        if (filteredEvents.isEmpty)
          _buildNoSearchResults()
        else ...[
          if (featuredEvents.isNotEmpty) ...[
            const AppSectionHeader(
              title: 'Sự kiện nổi bật',
              subtitle: 'Những trải nghiệm đáng chú ý dành cho bạn.',
            ),
            const SizedBox(height: AppSpacing.x3),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredEvents.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.x3),
                itemBuilder: (context, index) {
                  final event = featuredEvents[index];
                  return FeaturedEventCard(
                    event: event,
                    onTap: () => context.push('/events/${event.id}'),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
          ],
          const AppSectionHeader(
            title: 'Sự kiện sắp diễn ra',
            subtitle: 'Các sự kiện được sắp xếp theo thời gian bắt đầu.',
          ),
          const SizedBox(height: AppSpacing.x3),
          if (upcomingEvents.isEmpty)
            const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Chưa có sự kiện sắp diễn ra',
              description:
                  'Các sự kiện phù hợp hiện không còn trong thời gian sắp tới.',
            )
          else
            ...upcomingEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                child: AppEventCard(
                  title: event.title,
                  dateTimeLabel: formatEventDateTime(event.startsAt),
                  locationLabel: '${event.venueName}, ${event.city}',
                  priceLabel: _startingPrice(event),
                  categoryLabel: event.category.label,
                  image: event.bannerAssetPath == null
                      ? null
                      : AssetImage(event.bannerAssetPath!),
                  onTap: () => context.push('/events/${event.id}'),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCategoryFilters(List<EventCategory> categories) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.x2),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AppCategoryChip(
              label: 'Tất cả',
              selected: _selectedCategory == null,
              onSelected: (_) => setState(() => _selectedCategory = null),
            );
          }

          final category = categories[index - 1];
          return AppCategoryChip(
            label: category.label,
            selected: _selectedCategory == category,
            onSelected: (selected) =>
                setState(() => _selectedCategory = selected ? category : null),
          );
        },
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return AppEmptyState(
      icon: Icons.search_off,
      title: 'Không tìm thấy sự kiện',
      description: 'Thử từ khóa khác hoặc xóa bộ lọc để xem thêm sự kiện.',
      actionLabel: 'Xóa tìm kiếm và bộ lọc',
      onAction: _clearSearchAndFilters,
    );
  }

  String _startingPrice(Event event) {
    final prices = event.ticketTypes.map((ticket) => ticket.priceVnd);
    if (prices.isEmpty) return 'Chưa có thông tin vé';
    return formatVnd(prices.reduce((a, b) => a < b ? a : b));
  }
}

class _LoadingEvents extends StatelessWidget {
  const _LoadingEvents();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.x8),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EventLoadError extends StatelessWidget {
  const _EventLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Chưa tải được sự kiện',
      description: 'Đã có lỗi khi đọc dữ liệu sự kiện mẫu.',
      actionLabel: 'Thử lại',
      onAction: onRetry,
    );
  }
}
