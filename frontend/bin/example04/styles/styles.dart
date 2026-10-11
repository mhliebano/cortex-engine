import 'package:frontend/core/ui/ui.dart';

final dashboardLayoutRules = {
  "container_cards": LayoutRules(
    padding: EdgeInsets.all(10),
    width: 0.25,
    height: double.infinity,
  ),
};

final dashboardStyleRules = {
  "container_cards": StyleRules(
    bgColor: ColorRGBA(255, 255, 255),
    borderRadius: 18,
  ),
  "container_labels": StyleRules(textColor: ColorRGBA(0, 0, 0)),
};
