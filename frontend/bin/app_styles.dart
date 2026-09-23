import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/ui/style.dart';

/// Registra todas las Clases CSS de la Aplicación en el registro global de estilos.
void initAppStyles() {
  // Encabezados y Etiquetas
  Style.register(
    'header-title',
    const Style(textColor: ColorRGBA.accentBlue, fontSize: 24),
  );

  Style.register(
    'header-subtitle',
    const Style(textColor: ColorRGBA(255, 255, 0), fontSize: 14),
  );

  Style.register(
    'section-title',
    const Style(textColor: ColorRGBA.white, fontSize: 18),
  );

  Style.register(
    'subsection-title',
    const Style(textColor: ColorRGBA(255, 255, 0), fontSize: 15),
  );

  Style.register(
    'label-muted',
    const Style(textColor: ColorRGBA(130, 145, 165), fontSize: 13),
  );

  // Botones
  Style.register(
    'btn-primary',
    const Style(
      bgColor: ColorRGBA.accentBlue,
      hoverColor: ColorRGBA.hoverBlue,
      textColor: ColorRGBA.white,
      fontSize: 15,
      height: 40,
    ),
  );

  Style.register(
    'btn-success',
    const Style(
      bgColor: ColorRGBA(39, 174, 96),
      hoverColor: ColorRGBA(46, 204, 113),
      textColor: ColorRGBA.white,
      fontSize: 15,
      height: 45,
    ),
  );

  Style.register(
    'btn-purple',
    const Style(
      bgColor: ColorRGBA(142, 68, 173),
      hoverColor: ColorRGBA(155, 89, 182),
      textColor: ColorRGBA.white,
      fontSize: 15,
      height: 45,
    ),
  );

  Style.register(
    'btn-danger',
    const Style(
      bgColor: ColorRGBA(192, 57, 43),
      hoverColor: ColorRGBA(231, 76, 60),
      textColor: ColorRGBA.white,
      fontSize: 14,
    ),
  );

  // Paneles y Tarjetas
  Style.register(
    'panel-section',
    const Style(
      bgColor: ColorRGBA(0, 0, 0, 128),
      borderColor: ColorRGBA(255, 255, 255),
      padding: 16,
    ),
  );

  Style.register(
    'panel-container',
    const Style(
      bgColor: ColorRGBA(255, 255, 255),
      borderColor: ColorRGBA(40, 48, 62),
      padding: 12,
    ),
  );

  Style.register(
    'header-bar',
    const Style(bgColor: ColorRGBA(25, 28, 35), padding: 10, height: 40),
  );

  Style.register(
    'sidebar-panel',
    const Style(
      bgColor: ColorRGBA(30, 34, 42),
      borderColor: ColorRGBA(50, 58, 70),
      padding: 15,
      spacing: 12,
      width: 250,
    ),
  );

  Style.register(
    'main-content-panel',
    const Style(bgColor: ColorRGBA(35, 38, 45), padding: 20, spacing: 15),
  );

  Style.register(
    'card-primary',
    const Style(
      bgColor: ColorRGBA(30, 36, 48),
      borderColor: ColorRGBA(55, 68, 88),
      accentColor: ColorRGBA.accentBlue,
      padding: 14,
    ),
  );

  Style.register(
    'card-success',
    const Style(
      bgColor: ColorRGBA(24, 40, 32),
      borderColor: ColorRGBA(40, 90, 60),
      accentColor: ColorRGBA(39, 174, 96),
      padding: 14,
    ),
  );

  Style.register(
    'card-warning',
    const Style(
      bgColor: ColorRGBA(40, 36, 24),
      borderColor: ColorRGBA(90, 80, 40),
      accentColor: ColorRGBA(241, 196, 15),
      padding: 14,
    ),
  );

  Style.register(
    'card-danger',
    const Style(
      bgColor: ColorRGBA(40, 24, 24),
      borderColor: ColorRGBA(90, 40, 40),
      accentColor: ColorRGBA(231, 76, 60),
      padding: 14,
    ),
  );

  // Divisores y Separadores
  Style.register(
    'divider-blue',
    const Style(dividerColor: ColorRGBA.accentBlue),
  );

  Style.register(
    'divider-subtle',
    const Style(dividerColor: ColorRGBA(50, 60, 75)),
  );

  // Indicadores de Progreso y Carga
  Style.register(
    'progress-blue',
    const Style(
      bgColor: ColorRGBA(35, 42, 54),
      accentColor: ColorRGBA.accentBlue,
      textColor: ColorRGBA.white,
    ),
  );

  Style.register(
    'progress-green',
    const Style(
      bgColor: ColorRGBA(35, 42, 54),
      accentColor: ColorRGBA(46, 204, 113),
      textColor: ColorRGBA.white,
    ),
  );

  Style.register(
    'progress-orange',
    const Style(
      bgColor: ColorRGBA(35, 42, 54),
      accentColor: ColorRGBA(230, 126, 34),
      textColor: ColorRGBA.white,
    ),
  );

  Style.register('loading-blue', const Style(textColor: ColorRGBA.accentBlue));

  Style.register(
    'loading-green',
    const Style(textColor: ColorRGBA(46, 204, 113)),
  );
}
