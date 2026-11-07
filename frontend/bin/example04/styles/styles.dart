import 'package:frontend/core/ui/ui.dart';

final dashboardLayoutRules = {
  "container_cards": LayoutRules(
    padding: EdgeInsets.all(14),
    width: 0.25,
    height: 145.0,
    align: Alignment.center,
  ),
  "card_content": LayoutRules(
    width: double.infinity,
    height: double.infinity,
  ),
  "kpi_header": LayoutRules(
    width: double.infinity,
  ),
  "panel_section": LayoutRules(
    width: double.infinity,
    padding: EdgeInsets.all(16),
  ),
  "controls_row": LayoutRules(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 8),
  ),
  "half_width": LayoutRules(
    width: 0.45,
  ),
  "card_progress": LayoutRules(
    width: double.infinity,
  ),
  "full_width": LayoutRules(
    width: double.infinity,
  ),
};

final dashboardStyleRules = {
  "container_cards": StyleRules(
    bgColor: ColorRGBA(24, 29, 39),
    borderColor: ColorRGBA(45, 55, 72),
    borderRadius: 14,
  ),
  "container_labels": StyleRules(
    textColor: ColorRGBA(226, 232, 240),
  ),
  "dashboard_title": StyleRules(
    textColor: ColorRGBA(255, 255, 255),
    fontSize: 20,
  ),
  "dashboard_subtitle": StyleRules(
    textColor: ColorRGBA(148, 163, 184),
    fontSize: 12,
  ),
  "card_title": StyleRules(
    textColor: ColorRGBA(148, 163, 184),
    fontSize: 12,
  ),
  "card_value": StyleRules(
    textColor: ColorRGBA(255, 255, 255),
    fontSize: 22,
  ),
  "badge_up": StyleRules(
    bgColor: ColorRGBA(34, 84, 61),
    textColor: ColorRGBA(104, 211, 145),
    fontSize: 10,
    borderRadius: 6,
  ),
  "badge_live": StyleRules(
    bgColor: ColorRGBA(44, 82, 130),
    textColor: ColorRGBA(144, 205, 244),
    fontSize: 10,
    borderRadius: 6,
  ),
  "badge_neutral": StyleRules(
    bgColor: ColorRGBA(74, 85, 104),
    textColor: ColorRGBA(226, 232, 240),
    fontSize: 10,
    borderRadius: 6,
  ),
  "icon_accent_blue": StyleRules(
    textColor: ColorRGBA(66, 153, 225),
    fontSize: 18,
  ),
  "icon_accent_green": StyleRules(
    textColor: ColorRGBA(72, 187, 120),
    fontSize: 18,
  ),
  "icon_accent_purple": StyleRules(
    textColor: ColorRGBA(183, 148, 244),
    fontSize: 18,
  ),
  "icon_accent_orange": StyleRules(
    textColor: ColorRGBA(246, 173, 85),
    fontSize: 18,
  ),
  "panel_section": StyleRules(
    bgColor: ColorRGBA(20, 24, 33),
    borderColor: ColorRGBA(39, 46, 58),
    borderRadius: 12,
  ),
  "section_heading": StyleRules(
    textColor: ColorRGBA(241, 245, 249),
    fontSize: 15,
  ),
  "section_subheading": StyleRules(
    textColor: ColorRGBA(148, 163, 184),
    fontSize: 12,
  ),
  "progress_blue": StyleRules(
    activeColor: ColorRGBA(66, 153, 225),
    bgColor: ColorRGBA(36, 45, 60),
    borderRadius: 3,
  ),
  "progress_green": StyleRules(
    activeColor: ColorRGBA(72, 187, 120),
    bgColor: ColorRGBA(36, 45, 60),
    borderRadius: 3,
  ),
  "progress_orange": StyleRules(
    activeColor: ColorRGBA(246, 173, 85),
    bgColor: ColorRGBA(36, 45, 60),
    borderRadius: 3,
  ),
  "progress_purple": StyleRules(
    activeColor: ColorRGBA(183, 148, 244),
    bgColor: ColorRGBA(36, 45, 60),
    borderRadius: 3,
  ),
};
