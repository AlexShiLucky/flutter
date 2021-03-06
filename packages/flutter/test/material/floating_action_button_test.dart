// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/semantics_tester.dart';

void main() {
  testWidgets('Floating Action Button control test', (WidgetTester tester) async {
    bool didPressButton = false;
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new FloatingActionButton(
            onPressed: () {
              didPressButton = true;
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    expect(didPressButton, isFalse);
    await tester.tap(find.byType(Icon));
    expect(didPressButton, isTrue);
  });

  testWidgets('Floating Action Button tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: const Scaffold(
          floatingActionButton: const FloatingActionButton(
            onPressed: null,
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Icon));
    expect(find.byTooltip('Add'), findsOneWidget);
  });

  testWidgets('Floating Action Button tooltip (no child)', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: const Scaffold(
          floatingActionButton: const FloatingActionButton(
            onPressed: null,
            tooltip: 'Add',
          ),
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('FlatActionButton mini size is configurable by ThemeData.materialTapTargetSize', (WidgetTester tester) async {
    final Key key1 = new UniqueKey();
    await tester.pumpWidget(
      new MaterialApp(
        home: new Theme(
          data: new ThemeData(materialTapTargetSize: MaterialTapTargetSize.padded),
          child: new Scaffold(
            floatingActionButton: new FloatingActionButton(
              key: key1,
              mini: true,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(key1)), const Size(48.0, 48.0));

    final Key key2 = new UniqueKey();
    await tester.pumpWidget(
      new MaterialApp(
        home: new Theme(
          data: new ThemeData(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: new Scaffold(
            floatingActionButton: new FloatingActionButton(
              key: key2,
              mini: true,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(key2)), const Size(40.0, 40.0));
  });

  testWidgets('FloatingActionButton.isExtended', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: const Scaffold(
          floatingActionButton: const FloatingActionButton(onPressed: null),
        ),
      ),
    );

    final Finder fabFinder = find.byType(FloatingActionButton);

    FloatingActionButton getFabWidget() {
      return tester.widget<FloatingActionButton>(fabFinder);
    }

    expect(getFabWidget().isExtended, false);
    expect(getFabWidget().shape, const CircleBorder());

    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          floatingActionButton: new FloatingActionButton.extended(
            label: const SizedBox(
              width: 100.0,
              child: const Text('label'),
            ),
            icon: const Icon(Icons.android),
            onPressed: null,
          ),
        ),
      ),
    );

    expect(getFabWidget().isExtended, true);
    expect(getFabWidget().shape, const StadiumBorder());
    expect(find.text('label'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);

    // Verify that the widget's height is 48 and that its internal
    /// horizontal layout is: 16 icon 8 label 20
    expect(tester.getSize(fabFinder).height, 48.0);

    final double fabLeft = tester.getTopLeft(fabFinder).dx;
    final double fabRight = tester.getTopRight(fabFinder).dx;
    final double iconLeft = tester.getTopLeft(find.byType(Icon)).dx;
    final double iconRight = tester.getTopRight(find.byType(Icon)).dx;
    final double labelLeft = tester.getTopLeft(find.text('label')).dx;
    final double labelRight = tester.getTopRight(find.text('label')).dx;
    expect(iconLeft - fabLeft, 16.0);
    expect(labelLeft - iconRight, 8.0);
    expect(fabRight - labelRight, 20.0);

    // The overall width of the button is:
    // 168 = 16 + 24(icon) + 8 + 100(label) + 20
    expect(tester.getSize(find.byType(Icon)).width, 24.0);
    expect(tester.getSize(find.text('label')).width, 100.0);
    expect(tester.getSize(fabFinder).width, 168);
  });

  testWidgets('Floating Action Button heroTag', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          body: new Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(heroTag: 1, onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(heroTag: 2, onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, new PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump(); // this would fail if heroTag was the same on both FloatingActionButtons (see below).
  });

  testWidgets('Floating Action Button heroTag - with duplicate', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          body: new Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, new PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump();
    expect(tester.takeException().toString(), contains('FloatingActionButton'));
  });

  testWidgets('Floating Action Button heroTag - with duplicate', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          body: new Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(heroTag: 'xyzzy', onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(heroTag: 'xyzzy', onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, new PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump();
    expect(tester.takeException().toString(), contains('xyzzy'));
  });

  testWidgets('Floating Action Button semantics (enabled)', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new FloatingActionButton(
            onPressed: () { },
            child: const Icon(Icons.add, semanticLabel: 'Add'),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          label: 'Add',
          flags: <SemanticsFlag>[
            SemanticsFlag.isButton,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
          ],
          actions: <SemanticsAction>[
            SemanticsAction.tap
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('Floating Action Button semantics (disabled)', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: const Center(
          child: const FloatingActionButton(
            onPressed: null,
            child: const Icon(Icons.add, semanticLabel: 'Add'),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          label: 'Add',
          flags: <SemanticsFlag>[
            SemanticsFlag.isButton,
            SemanticsFlag.hasEnabledState,
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('Tooltip is used as semantics label', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);

    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          floatingActionButton: new FloatingActionButton(
            onPressed: () { },
            tooltip: 'Add Photo',
            child: const Icon(Icons.add_a_photo),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          children: <TestSemantics>[
            new TestSemantics(
              flags: <SemanticsFlag>[
                SemanticsFlag.scopesRoute,
              ],
              children: <TestSemantics>[
                new TestSemantics(
                  label: 'Add Photo',
                  actions: <SemanticsAction>[
                    SemanticsAction.tap
                  ],
                  flags: <SemanticsFlag>[
                    SemanticsFlag.isButton,
                    SemanticsFlag.hasEnabledState,
                    SemanticsFlag.isEnabled,
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('extended FAB hero transitions succeed', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/18782

    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          floatingActionButton: new Builder(
            builder: (BuildContext context) { // define context of Navigator.push()
              return new FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('A long FAB label'),
                onPressed: () {
                  Navigator.push(context, new MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return new Scaffold(
                        floatingActionButton: new FloatingActionButton.extended(
                          icon: const Icon(Icons.add),
                          label: const Text('X'),
                          onPressed: () { },
                        ),
                        body: new Center(
                          child: new RaisedButton(
                            child: const Text('POP'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ));
                },
              );
            },
          ),
          body: const Center(
            child: const Text('Hello World'),
          ),
        ),
      ),
    );

    final Finder longFAB = find.text('A long FAB label');
    final Finder shortFAB = find.text('X');
    final Finder helloWorld = find.text('Hello World');

    expect(longFAB, findsOneWidget);
    expect(shortFAB, findsNothing);
    expect(helloWorld, findsOneWidget);

    await tester.tap(longFAB);
    await tester.pumpAndSettle();

    expect(shortFAB, findsOneWidget);
    expect(longFAB, findsNothing);

    // Trigger a hero transition from shortFAB to longFAB.
    await tester.tap(find.text('POP'));
    await tester.pumpAndSettle();

    expect(longFAB, findsOneWidget);
    expect(shortFAB, findsNothing);
    expect(helloWorld, findsOneWidget);
  });
}
