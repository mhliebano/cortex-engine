import 'package:frontend/core/ui/ui.dart';

final dashboardLayoutRules = {
  "container_cards": LayoutRules(
    padding: EdgeInsets.all(10),
    width: 0.25,
    height: double.infinity,
    align: Alignment.center,
  ),
  "container_graphics": LayoutRules(
    padding: EdgeInsets.all(10),
    width: 0.20,
    height: double.infinity,
    align: Alignment.center,
  ),
  "container_graphics_v1": LayoutRules(width: 0.55),
  "panel-foot": LayoutRules(
    padding: EdgeInsets.all(10),
    width: double.infinity,
    height: double.infinity,
    align: Alignment.bottomCenter,
  ),
};

final dashboardStyleRules = {
  "container_cards": StyleRules(
    bgColor: ColorRGBA(255, 255, 255),
    borderRadius: 18,
  ),
  "container_graphics": StyleRules(
    bgColor: ColorRGBA(0, 255, 0, 64),
    borderRadius: 18,
  ),
  "container_graphics_v1": StyleRules(bgColor: ColorRGBA(0, 0, 255, 64)),
  "container_graphics_v2": StyleRules(bgColor: ColorRGBA(255, 255, 0, 64)),
  "container_labels": StyleRules(textColor: ColorRGBA(0, 0, 0), fontSize: 32),
  "container_labels_title": StyleRules(
    textColor: ColorRGBA(0, 0, 0),
    fontSize: 18,
  ),
  "text-field": StyleRules(
    bgColor: ColorRGBA(255, 255, 255),
    textColor: ColorRGBA(0, 0, 0),
    borderColor: ColorRGBA(241, 243, 245),
    borderRadius: 18,
  ),
  "panel-foot": StyleRules(bgColor: ColorRGBA(245, 245, 245), borderRadius: 18),
};
