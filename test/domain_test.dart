import 'package:arescare/data/savings_store.dart';
import 'package:arescare/domain/encouragement.dart';
import 'package:arescare/domain/money.dart';
import 'package:arescare/models/savings_book.dart';
import 'package:arescare/state/savings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatea soles con separador de miles', () {
    expect(formatSoles(950), 'S/. 950.00');
    expect(formatSoles(1500), 'S/. 1,500.00');
    expect(formatSoles(965), 'S/. 965.00');
    expect(formatSoles(0.5), 'S/. 0.50');
    expect(formatSoles(1000000), 'S/. 1,000,000.00');
  });

  test('acepta coma o punto como decimal', () {
    expect(parseSoles('15,50'), 15.5);
    expect(parseSoles('15.5'), 15.5);
    expect(parseSoles('0'), isNull);
    expect(parseSoles(''), isNull);
  });

  test('los mensajes rotan con cada apertura', () {
    expect(Encouragement.forLaunch(0), Encouragement.messages[0]);
    expect(Encouragement.forLaunch(1), Encouragement.messages[1]);
    expect(Encouragement.forLaunch(2), Encouragement.messages[2]);
    expect(Encouragement.forLaunch(3), Encouragement.messages[0]);
  });

  test('empieza vacía y guarda un proceso con su aporte', () async {
    final store = MemorySavingsStore();
    final controller = SavingsController(store);
    await controller.load();
    expect(controller.balance, 0);
    expect(controller.sections, isEmpty);
    expect(controller.goal, 0);

    final created = await controller.addSection(
      name: 'Fisioterapia',
      emoji: '🐶',
      goal: 200,
    );
    expect(controller.goal, 200);
    expect(controller.findSection(created.id)?.emoji, '🐶');

    await controller.add(
      sectionId: created.id,
      title: 'Paseo extra',
      amount: 15,
      emoji: '🎾',
    );
    expect(controller.balance, 15);
    expect(controller.savedIn(created.id), 15);

    final reloaded = SavingsController(store);
    await reloaded.load();
    expect(reloaded.balance, 15);
    expect(reloaded.sections.single.name, 'Fisioterapia');
    expect(reloaded.contributions.single.emoji, '🎾');
  });

  test('se puede quitar el único proceso y volver a cero', () async {
    final controller = SavingsController(MemorySavingsStore());
    await controller.load();
    final created = await controller.addSection(
      name: 'Consultas',
      emoji: '🐾',
      goal: 100,
    );
    expect(await controller.removeSection(created.id), isTrue);
    expect(controller.sections, isEmpty);
    expect(controller.balance, 0);
    expect(SavingsBook.empty.saved, 0);
  });
}
