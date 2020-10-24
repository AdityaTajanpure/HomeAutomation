import 'package:home_automation/core/enums/enum.dart';
import 'package:home_automation/ui/shared/globals.dart';
import 'package:home_automation/ui/shared/globals.dart';
import 'package:flutter/widgets.dart';

class HomeModel extends ChangeNotifier {
  List<double> _sliderValues = [1.0, 1.0, 1.0, 1.0];
  List get sliderValues => _sliderValues;
  void setSliderValue(index, value) {
    _sliderValues[index] = value;
    notifyListeners();
  }

  double getFormula(index, width) =>
      Global.boxWidth +
      sliderValues[index] *
          (width - Global.boxWidth * 2 - Global.sidePadding * 4);

  double getStartWidth(width) =>
      width - Global.sidePadding * 4 - Global.boxWidth;

  List<double> _widthValues = [null, null, null, null];
  set setWidthValues(List<double> values) {
    _widthValues = values;
    notifyListeners();
  }

  get widthValues => _widthValues;
  void setWidth(index, width) {
    if (switchValues[index]) {
      _widthValues[index] = getFormula(index, width);
    } else {
      _widthValues[index] = width - Global.sidePadding * 4;
    }
    notifyListeners();
  }

  ViewState _state = ViewState.Idle;
  get state => _state;
  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<bool> _switchValues = [true, true, true, true];
  set setswitchValues(List<bool> value) {
    this._switchValues = value;
    notifyListeners();
  }

  List get switchValues => _switchValues;
  void setSwitchValues(index, value) {
    _switchValues[index] = value;
    notifyListeners();
  }
}
