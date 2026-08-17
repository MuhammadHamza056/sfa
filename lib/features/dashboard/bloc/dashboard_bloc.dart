import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<SetDrawerOpenEvent>(_onSetDrawerOpen);
    on<ChangeTabEvent>(_onChangeTab);
    on<RestorePreviousTabEvent>(_onRestorePreviousTab);
    on<CacheCurrentTabEvent>(_onCacheCurrentTab);
    on<SelectBrandEvent>(_onSelectBrand);
    on<SelectProductEvent>(_onSelectProduct);
  }

  void _onSetDrawerOpen(SetDrawerOpenEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(drawerOpen: event.isOpen));
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      currentIndex: event.index,
      previousIndex: (event.index != 5 && event.index != 6 && event.index != 7 && event.index != 8) ? event.index : state.previousIndex,
    ));
  }

  void _onRestorePreviousTab(RestorePreviousTabEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(currentIndex: state.previousIndex));
  }

  void _onCacheCurrentTab(CacheCurrentTabEvent event, Emitter<DashboardState> emit) {
    if (state.currentIndex != 5 && state.currentIndex != 6 && state.currentIndex != 7 && state.currentIndex != 8) {
      emit(state.copyWith(previousIndex: state.currentIndex));
    }
  }

  void _onSelectBrand(SelectBrandEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      selectedBrandName: event.brandName,
      currentIndex: 6,
    ));
  }

  void _onSelectProduct(SelectProductEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      selectedProductName: event.name,
      selectedProductImage: event.imageUrl,
      selectedProductPrice: event.price,
      selectedProductRating: event.rating,
      currentIndex: 7,
    ));
  }
}
