import 'package:test/test.dart';
import 'package:cortex/engine/ui/ui.dart';

class TestListViewPage extends View {
  int selectedIndex = -1;
  ScrollController listController = ScrollController();

  TestListViewPage() : super(id: 'test_list_view');

  @override
  List<Element> build() {
    return [
      ListView(
        key: 'my_list',
        controller: listController,
        height: 200,
        children: List.generate(
          50,
          (index) => Button(
            label: 'Item #$index ${selectedIndex == index ? "[SELECTED]" : ""}',
            onPressed: () {
              selectedIndex = index;
              rebuild();
            },
          ),
        ),
      ),
    ];
  }
}

class TestColumnPage extends View {
  TestColumnPage() : super(id: 'test_col');

  @override
  List<Element> build() {
    return [
      Column(
        isScrollable: true,
        height: 200,
        children: [
          Button(label: 'A'),
          Button(label: 'B'),
        ],
      )
    ];
  }
}

void main() {
  test('ListView scrollOffset is preserved across View.rebuild()', () {
    final view = TestListViewPage();
    view.init();
    view.resize(800, 600);

    final initialList = view.children.first as ListView;
    expect(initialList.scrollOffset, equals(0.0));

    // Simular desplazamiento de 150px
    initialList.scrollOffset = 150.0;
    expect(initialList.scrollOffset, equals(150.0));

    // Ejecutar rebuild (como ocurre al seleccionar un elemento)
    view.rebuild();

    // Verificar que el nuevo ListView preservó la posición de scroll en 150.0
    final rebuiltList = view.children.first as ListView;
    expect(rebuiltList.scrollOffset, equals(150.0));
    expect(view.listController.offset, equals(150.0));
  });

  test('Column scrollOffset is preserved across View.rebuild() via automatic positional matching', () {
    final view = TestColumnPage();
    view.init();
    view.resize(800, 600);

    final col = view.children.first as Column;
    col.scrollOffset = 85.0;

    view.rebuild();

    final rebuiltCol = view.children.first as Column;
    expect(rebuiltCol.scrollOffset, equals(85.0));
  });
}
