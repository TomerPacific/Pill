
import 'package:pill/model/pill_filter.dart';
import 'package:pill/model/pill_to_take.dart';

abstract class PillFilterState {
  const PillFilterState();

  List<Object> get props => [];
}

class PillFilterLoading extends PillFilterState {

}

class PillFilterLoaded extends PillFilterState {
  final List<PillToTake> filteredPills;
  final PillFilter pillFilter;
  const PillFilterLoaded({ required this.filteredPills, this.pillFilter = PillFilter.all });

  List<Object> get props => [filteredPills, pillFilter];
}