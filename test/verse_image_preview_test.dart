import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lw_app/Models/Bible/verse_image_draft.dart';
import 'package:lw_app/Screens/Bible/verse_image_editor.dart';

void main() {
  testWidgets('preview renders verse, citation, footer, and style options',
      (tester) async {
    const draft = VerseImageDraft(
      verseText: '[16] Want so lief het God die wereld gehad',
      citation: 'Johannes 3:16 (AFR20)',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: VerseImagePreview(
                draft: draft,
                backgroundImage: null,
                aspectRatio: 4 / 5,
                textSize: 36,
                textAlign: TextAlign.left,
                overlayStrength: 0.6,
                useLightText: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('[16] Want so lief het God die wereld gehad'),
        findsOneWidget);
    expect(find.text('Johannes 3:16 (AFR20)'), findsOneWidget);
    expect(find.text('Lewende Woord Paarl'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);

    final verseText = tester.widget<Text>(
      find.text('[16] Want so lief het God die wereld gehad'),
    );
    expect(verseText.textAlign, TextAlign.left);
    expect(verseText.style?.fontSize, 36);
    expect(verseText.style?.color, const Color(0xFF111111));
  });
}
