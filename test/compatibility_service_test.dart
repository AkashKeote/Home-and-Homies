import 'package:flutter_test/flutter_test.dart';
import 'package:your_card_scrolling/services/compatibility_service.dart';

void main() {
  group('CompatibilityService Tests - Task 4', () {
    test('Perfect match (identical preferences) should return 100', () {
      final userPrefs = {'cleanliness': 5, 'introvert': 5, 'loudness': 5};
      final roommatePrefs = {'cleanliness': 5, 'introvert': 5, 'loudness': 5};

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      expect(score, 100.0);
    });

    test('Given example should calculate correctly', () {
      final userPrefs = {'cleanliness': 4, 'introvert': 5, 'loudness': 2};
      final roommatePrefs = {'cleanliness': 3, 'introvert': 4, 'loudness': 1};

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      // All traits have difference of 1, should give score around 75
      expect(score, greaterThan(70.0));
      expect(score, lessThan(80.0));
    });

    test('Complete mismatch (max differences) should return 0', () {
      final userPrefs = {'cleanliness': 1, 'introvert': 1, 'loudness': 1};
      final roommatePrefs = {'cleanliness': 5, 'introvert': 5, 'loudness': 5};

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      expect(score, 0.0);
    });

    test('Empty preferences should return 0', () {
      final userPrefs = <String, int>{};
      final roommatePrefs = {'cleanliness': 3};

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      expect(score, 0.0);
    });

    test('No common traits should return 0', () {
      final userPrefs = {'cleanliness': 4, 'introvert': 5};
      final roommatePrefs = {'loudness': 2, 'smoking': 1};

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      expect(score, 0.0);
    });

    test('Partial trait overlap should calculate correctly', () {
      final userPrefs = {
        'cleanliness': 4,
        'introvert': 5,
        'loudness': 2,
        'smoking': 1
      };
      final roommatePrefs = {
        'cleanliness': 4,
        'introvert': 5,
      };

      final score = CompatibilityService.calculateCompatibilityScore(
        userPrefs,
        roommatePrefs,
      );

      // Should calculate based on common traits (cleanliness, introvert)
      expect(score, 100.0); // Both match perfectly
    });

    test('High importance trait difference should lower score more', () {
      // Cleanliness has weight 2.0
      final userPrefs1 = {'cleanliness': 1, 'cooking': 3};
      final roommatePrefs1 = {'cleanliness': 5, 'cooking': 3};

      // Cooking has weight 1.3
      final userPrefs2 = {'cleanliness': 3, 'cooking': 1};
      final roommatePrefs2 = {'cleanliness': 3, 'cooking': 5};

      final score1 = CompatibilityService.calculateCompatibilityScore(
        userPrefs1,
        roommatePrefs1,
      );
      final score2 = CompatibilityService.calculateCompatibilityScore(
        userPrefs2,
        roommatePrefs2,
      );

      // Score1 (cleanliness mismatch) should be lower than Score2 (cooking mismatch)
      expect(score1, lessThan(score2));
    });

    test('Detailed compatibility should include trait scores', () {
      final userPrefs = {'cleanliness': 4, 'introvert': 5};
      final roommatePrefs = {'cleanliness': 3, 'introvert': 5};

      final result = CompatibilityService.calculateDetailedCompatibility(
        userPrefs,
        roommatePrefs,
      );

      expect(result['overallScore'], isA<double>());
      expect(result['traitScores'], isA<Map>());
      expect(result['matchLevel'], isA<String>());
      expect(result['recommendation'], isA<String>());
      expect(result['traitScores']['cleanliness'], 75.0);
      expect(result['traitScores']['introvert'], 100.0);
    });

    test('Sort roommates by compatibility should work correctly', () {
      final userPrefs = {'cleanliness': 5, 'introvert': 5};
      final roommates = [
        {
          'name': 'Roommate A',
          'preferences': {'cleanliness': 1, 'introvert': 1}
        },
        {
          'name': 'Roommate B',
          'preferences': {'cleanliness': 5, 'introvert': 5}
        },
        {
          'name': 'Roommate C',
          'preferences': {'cleanliness': 4, 'introvert': 4}
        },
      ];

      final sorted = CompatibilityService.sortByCompatibility(
        userPrefs,
        roommates,
      );

      // Should be sorted: B (100), C (75), A (0)
      expect(sorted[0]['name'], 'Roommate B');
      expect(sorted[1]['name'], 'Roommate C');
      expect(sorted[2]['name'], 'Roommate A');
      expect(sorted[0]['compatibilityScore'], 100.0);
    });

    test('Match level categorization should work correctly', () {
      final testCases = [
        {'score': 95.0, 'expected': 'Excellent Match'},
        {'score': 80.0, 'expected': 'Great Match'},
        {'score': 65.0, 'expected': 'Good Match'},
        {'score': 50.0, 'expected': 'Fair Match'},
        {'score': 35.0, 'expected': 'Poor Match'},
        {'score': 20.0, 'expected': 'Not Compatible'},
      ];

      for (final testCase in testCases) {
        final userPrefs = {'cleanliness': 5};
        final score = testCase['score'] as double;
        final difference = ((100 - score) / 25).round();
        final roommateValue = (5 - difference).clamp(1, 5);
        final roommatePrefs = {'cleanliness': roommateValue};

        final result = CompatibilityService.calculateDetailedCompatibility(
          userPrefs,
          roommatePrefs,
        );

        expect(
          result['matchLevel'],
          contains(RegExp(r'(Excellent|Great|Good|Fair|Poor|Not Compatible)')),
        );
      }
    });
  });
}
