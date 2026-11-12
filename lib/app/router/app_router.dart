import 'package:eventhub_app/features/discovery/presentation/pages/discovery_page.dart';
import 'package:eventhub_app/features/discovery/presentation/pages/event_details_page.dart';
import 'package:eventhub_app/features/organizer/presentation/pages/organizer_page.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/my_tickets_page.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/checkout_page.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/booking_confirmation_page.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/ticket_details_page.dart';
import 'package:eventhub_app/features/organizer/presentation/pages/organizer_event_form_page.dart';
import 'package:eventhub_app/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:eventhub_app/core/widgets/design_system_preview_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/discovery',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discovery',
              builder: (context, state) => const DiscoveryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const MyTicketsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/organizer',
              builder: (context, state) => const OrganizerPage(),
            ),
          ],
        ),
      ],
    ),
    if (kDebugMode)
      GoRoute(
        path: '/__debug/design-system',
        builder: (context, state) => const DesignSystemPreviewPage(),
      ),
    GoRoute(
      path: '/events/:eventId',
      builder: (context, state) =>
          EventDetailsPage(eventId: state.pathParameters['eventId']!),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) =>
          CheckoutPage(args: state.extra! as CheckoutArgs),
    ),
    GoRoute(
      path: '/booking-confirmation/:bookingId',
      builder: (context, state) =>
          BookingConfirmationPage(args: state.extra! as ConfirmationArgs),
    ),
    GoRoute(
      path: '/tickets/:ticketId',
      builder: (context, state) =>
          TicketDetailsPage(ticketId: state.pathParameters['ticketId']!),
    ),
    GoRoute(
      path: '/organizer/events/new',
      builder: (context, state) => const OrganizerEventFormPage(),
    ),
    GoRoute(
      path: '/organizer/events/:eventId/edit',
      builder: (context, state) =>
          OrganizerEventFormPage(eventId: state.pathParameters['eventId']),
    ),
  ],
);

class _MainNavigationShell extends ConsumerWidget {
  const _MainNavigationShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(demoRoleProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventHub'),
        actions: [
          PopupMenuButton<DemoRole>(
            tooltip: role == DemoRole.attendee
                ? 'Chế độ mô phỏng: Người tham dự'
                : 'Chế độ mô phỏng: Ban tổ chức',
            icon: Icon(
              role == DemoRole.attendee
                  ? Icons.person_outline
                  : Icons.business_outlined,
            ),
            onSelected: (selected) {
              ref.read(demoRoleProvider.notifier).select(selected);
              navigationShell.goBranch(selected == DemoRole.attendee ? 0 : 2);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: DemoRole.attendee,
                child: Text('Người tham dự · Demo'),
              ),
              PopupMenuItem(
                value: DemoRole.organizer,
                child: Text('Ban tổ chức · Demo'),
              ),
            ],
          ),
          if (kDebugMode)
            IconButton(
              tooltip: 'Xem bộ giao diện',
              onPressed: () => context.push('/__debug/design-system'),
              icon: const Icon(Icons.palette_outlined),
            ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Khám phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_num_outlined),
              selectedIcon: Icon(Icons.confirmation_num),
              label: 'Vé của tôi',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_available_outlined),
              selectedIcon: Icon(Icons.event_available),
              label: 'Ban tổ chức',
            ),
          ],
        ),
      ),
    );
  }
}
