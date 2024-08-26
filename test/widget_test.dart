// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doggymatch_flutter/main.dart';

import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    final UserProfile testProfile = UserProfile(
      userName: '...', // Replace with actual user data
      birthday: DateTime(1990, 1, 1), // Replace with actual birthday
      aboutText: '...', // Replace with actual about text
      profileColor: AppColors.accent1, // Replace with the actual profile color
      images: [], // Replace with actual image paths or URLs
      location: '...', // Replace with actual location
      isDogOwner: true, // Set to true or false based on user data
      dogName: '...', // Optional
      dogBreed: '...', // Optional
      dogAge: '...', // Optional
      filterLookingForDogOwner: true,
      filterLookingForDogSitter: true,
      filterDistance: 10.0,
    );

    await tester.pumpWidget(MyApp(profile: testProfile));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
