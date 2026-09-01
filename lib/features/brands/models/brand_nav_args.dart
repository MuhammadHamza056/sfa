/// Passed as `extra` when pushing `/brand-detail` — carries the real API
/// brand id (M23/M24) plus the name already known from the calling screen,
/// so the detail screen has something to show as its title while the
/// brand's own fetch is still in flight.
class BrandNavArgs {
  final String id;
  final String name;

  const BrandNavArgs({required this.id, required this.name});
}
