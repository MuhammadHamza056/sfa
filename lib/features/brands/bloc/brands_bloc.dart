import 'package:flutter_bloc/flutter_bloc.dart';
import 'brands_event.dart';
import 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  BrandsBloc() : super(const BrandsState()) {
    on<ChangeGenderEvent>(_onChangeGender);
    on<ChangeCategoryEvent>(_onChangeCategory);
  }

  void _onChangeGender(ChangeGenderEvent event, Emitter<BrandsState> emit) {
    emit(state.copyWith(selectedGender: event.genderIndex));
  }

  void _onChangeCategory(ChangeCategoryEvent event, Emitter<BrandsState> emit) {
    emit(state.copyWith(selectedCategory: event.categoryIndex));
  }
}
