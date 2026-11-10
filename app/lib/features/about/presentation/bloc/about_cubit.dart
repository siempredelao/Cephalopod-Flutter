import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';

/// The About page's view model. For now it only holds what the page shows;
/// the app's version and the link to the rule sheet come next, and will
/// change its state.
class AboutCubit extends Cubit<AboutViewState> {
  AboutCubit({required Uri ruleSheet})
    : super(AboutViewState(ruleSheetAddress: ruleSheet.toString()));
}
