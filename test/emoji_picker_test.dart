import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Use for golden tests, helpful in debugging
// await expectLater(
//   find.byType(MaterialApp),
//   matchesGoldenFile('overlay.png'),
// );

void main() {
  group('EmojiPicker Tests', () {
    testWidgets('Should allow user to select an emoji', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      Emoji? emojiSelected;
      Category? categorySelected;

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiPicker(
              textEditingController: controller,
              onEmojiSelected: (category, emoji) {
                emojiSelected = emoji;
                categorySelected = category;
              },
              config: const Config(
                height: 256,
                categoryViewConfig: CategoryViewConfig(
                  recentTabBehavior: RecentTabBehavior.NONE,
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the emojis to load if they are being loaded asynchronously
      await tester.pumpAndSettle();

      // Find an emoji in the picker
      final emoji = find.text('🙂').hitTestable();

      // Verify if we can find the emoji
      expect(emoji, findsOneWidget);

      // Tap on the emoji, this should trigger the selection action
      await tester.tap(emoji);

      // Call pumpAndSettle in case the UI needs to settle after an interaction
      await tester.pumpAndSettle();

      // Check if the emoji is added to the text controller
      expect(controller.text, contains('🙂'));

      // Check if the emoji been passed to the 'onEmojiSelected' callback
      expect(
        emojiSelected,
        equals(const Emoji('🙂', 'face | happy | slightly | smile | smiling')),
      );

      // Check if the category been passed to the 'onEmojiSelected' callback
      expect(categorySelected, equals(Category.SMILEYS));
    });

    testWidgets('Should allow to select an emoji with skintone on longPress', (
      WidgetTester tester,
    ) async {
      final controller0 = TextEditingController();
      final utils = EmojiPickerUtils();
      final emoji = const Emoji('👍', 'Thumbs Up', hasSkinTone: true);
      Emoji? emojiSelected0;
      Category? categorySelected0;

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: EmojiPicker(
                textEditingController: controller0,
                onEmojiSelected: (category, emoji) {
                  emojiSelected0 = emoji;
                  categorySelected0 = category;
                },
                config: const Config(
                  height: 500,
                  categoryViewConfig: CategoryViewConfig(
                    recentTabBehavior: RecentTabBehavior.NONE,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the emojis to load if they are being loaded asynchronously
      await tester.pumpAndSettle();

      // Find an emoji in the picker
      final emojiToFind = find.text(emoji.emoji);

      // Scroll until the emoji to be found appears.
      await tester.dragUntilVisible(
        emojiToFind,
        find.byKey(const Key('emojiScrollView')),
        const Offset(0, -300),
      );

      // Verify if we can find the emoji
      expect(emojiToFind, findsOneWidget);

      // Tap on the emoji, this should trigger the skintone overlay
      await tester.longPress(emojiToFind);

      // Call pumpAndSettle in case the UI needs to settle after an interaction
      await tester.pumpAndSettle();

      /// Check if all skin tones are rendered in overlay
      Finder? skinToneVariantToFind;
      for (var i = 0; i < SkinTone.values.length; i++) {
        skinToneVariantToFind = find.text(
          utils.applySkinTone(emoji, SkinTone.values[i]).emoji,
        );
        // Verify if we can find the skintone variant
        expect(skinToneVariantToFind, findsOneWidget);
      }

      // Tap on the emoji, this should trigger the selection action
      await tester.tap(skinToneVariantToFind!);

      // Check if the emoji is added to the text controller
      expect(controller0.text, contains('👍🏿'));

      // Check if the emoji been passed to the 'onEmojiSelected' callback
      expect(emojiSelected0?.emoji, equals('👍🏿'));
      expect(
        emojiSelected0?.name,
        equals('+1 | good | hand | like | thumb | up | yes'),
      );
      expect(emojiSelected0?.hasSkinTone, equals(true));

      // Check if the category been passed to the 'onEmojiSelected' callback
      expect(categorySelected0, equals(Category.SMILEYS));
    });
  });
}
