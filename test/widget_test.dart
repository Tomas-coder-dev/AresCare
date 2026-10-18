import 'package:arescare/app.dart';
import 'package:arescare/data/savings_store.dart';
import 'package:arescare/state/savings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empieza en blanco, sin aportes de ejemplo', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SavingsController(MemorySavingsStore());
    await controller.load();

    await tester.pumpWidget(AresApp(controller: controller));
    await tester.pump();

    expect(find.text('Ahorros para Ares 🐾'), findsOneWidget);
    expect(find.text('S/. 0.00'), findsOneWidget);
    expect(find.text('La meta aparece con el primer proceso'), findsOneWidget);
    expect(find.text('Todavía no hay procesos'), findsOneWidget);
    expect(find.text('Consultas'), findsNothing);
    expect(find.text('Ahorro del café'), findsNothing);
    expect(find.text('+ Agregar Aporte ✨'), findsNothing);
  });

  testWidgets('crea un proceso con nombre y emoji propios y suma un aporte', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SavingsController(MemorySavingsStore());
    await controller.load();
    await tester.pumpWidget(AresApp(controller: controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('add-section')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('section-emoji-add')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('section-emoji')), '🐶');
    await tester.enterText(find.byKey(const Key('section-name')), 'Fisioterapia');
    await tester.enterText(find.byKey(const Key('section-goal')), '200');
    await tester.tap(find.byKey(const Key('save-section')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fisioterapia'), findsOneWidget);
    expect(controller.goal, 200);
    expect(controller.sections.single.emoji, '🐶');

    await tester.tap(find.byKey(const Key('add-contribution')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byKey(const Key('contribution-amount')), '15');
    await tester.enterText(
      find.byKey(const Key('contribution-title')),
      'Paseo extra',
    );
    await tester.tap(find.byKey(const Key('contribution-emoji-add')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('contribution-emoji')), '🎾');
    await tester.tap(find.byKey(const Key('save-contribution')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Paseo extra'), findsOneWidget);
    expect(controller.balance, 15);
    expect(controller.contributions.single.emoji, '🎾');
    await tester.scrollUntilVisible(find.text('Todo lo guardado'), -400);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('S/. 15.00'), findsWidgets);
  });
}
