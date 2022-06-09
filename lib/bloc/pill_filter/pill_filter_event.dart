
import 'package:pill/model/pill_filter.dart';

abstract class PillFilterEvent {
  const PillFilterEvent();

  List<Object> get props => [];
}

class UpdatePills extends PillFilterEvent {
  final PillFilter pillFilter;

  const UpdatePills({ this.pillFilter = PillFilter.all });

  List<Object> get props => [pillFilter];
}

class UpdateFilter extends PillFilterEvent {
  const UpdateFilter();

  List<Object> get props => [];
}