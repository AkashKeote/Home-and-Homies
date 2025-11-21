/// Compatibility Service - Task 4
/// 
/// This service calculates a compatibility score between a user and a potential roommate
/// based on their preferences. The score ranges from 0-100, where 100 is a perfect match.
/// 
/// Logic Explanation:
/// 1. Calculate absolute difference for each preference trait
/// 2. Smaller differences indicate better compatibility
/// 3. Convert differences to individual scores (0-100 scale)
/// 4. Apply weighted average based on trait importance
/// 5. Return final compatibility score

class CompatibilityService {
  /// Calculate compatibility score between user and roommate preferences
  /// 
  /// Parameters:
  ///   userPreferences: Map of user's preference ratings (key: trait, value: rating 1-5)
  ///   roommatePreferences: Map of roommate's preference ratings (key: trait, value: rating 1-5)
  /// 
  /// Returns:
  ///   double: Compatibility score between 0-100 (100 = perfect match)
  /// 
  /// Example:
  /// ```dart
  /// final userPrefs = {'cleanliness': 4, 'introvert': 5, 'loudness': 2};
  /// final roommatePrefs = {'cleanliness': 3, 'introvert': 4, 'loudness': 1};
  /// final score = calculateCompatibilityScore(userPrefs, roommatePrefs);
  /// // Returns: 83.33 (good match)
  /// ```
  static double calculateCompatibilityScore(
    Map<String, int> userPreferences,
    Map<String, int> roommatePreferences,
  ) {
    // Validate inputs
    if (userPreferences.isEmpty || roommatePreferences.isEmpty) {
      return 0.0;
    }

    // Get common traits between user and roommate
    final commonTraits = userPreferences.keys
        .where((key) => roommatePreferences.containsKey(key))
        .toList();

    if (commonTraits.isEmpty) {
      return 0.0; // No common traits to compare
    }

    // Calculate individual trait scores
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final trait in commonTraits) {
      final userValue = userPreferences[trait]!;
      final roommateValue = roommatePreferences[trait]!;

      // Calculate difference (0-4 scale since ratings are 1-5)
      final difference = (userValue - roommateValue).abs();

      // Convert difference to compatibility score
      // difference 0 = 100%, difference 4 = 0%
      final traitScore = ((4 - difference) / 4) * 100;

      // Get weight for this trait (some traits are more important)
      final weight = _getTraitWeight(trait);

      totalScore += traitScore * weight;
      totalWeight += weight;
    }

    // Calculate weighted average
    final finalScore = totalWeight > 0 ? totalScore / totalWeight : 0.0;

    // Round to 2 decimal places
    return double.parse(finalScore.toStringAsFixed(2));
  }

  /// Get importance weight for each trait
  /// 
  /// Some traits are more critical for compatibility than others.
  /// Returns a weight between 1.0 (normal importance) and 2.0 (high importance)
  static double _getTraitWeight(String trait) {
    // Define trait importance weights
    const traitWeights = {
      'cleanliness': 2.0, // Very important - affects daily living
      'loudness': 1.8, // Important - affects peace and comfort
      'introvert': 1.5, // Moderately important - affects social dynamics
      'smoking': 2.0, // Very important - health and lifestyle
      'pets': 1.7, // Important - allergies and preferences
      'cooking': 1.3, // Less critical - can be managed
      'earlyBird': 1.4, // Moderately important - affects schedules
      'partying': 1.6, // Important - affects lifestyle compatibility
    };

    return traitWeights[trait.toLowerCase()] ?? 1.0;
  }

  /// Calculate compatibility with detailed breakdown
  /// 
  /// Returns a map with overall score and individual trait scores
  static Map<String, dynamic> calculateDetailedCompatibility(
    Map<String, int> userPreferences,
    Map<String, int> roommatePreferences,
  ) {
    final commonTraits = userPreferences.keys
        .where((key) => roommatePreferences.containsKey(key))
        .toList();

    if (commonTraits.isEmpty) {
      return {
        'overallScore': 0.0,
        'traitScores': {},
        'matchLevel': 'No common traits',
      };
    }

    // Calculate individual trait scores
    final Map<String, double> traitScores = {};
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final trait in commonTraits) {
      final userValue = userPreferences[trait]!;
      final roommateValue = roommatePreferences[trait]!;
      final difference = (userValue - roommateValue).abs();
      final traitScore = ((4 - difference) / 4) * 100;
      final weight = _getTraitWeight(trait);

      traitScores[trait] = double.parse(traitScore.toStringAsFixed(2));
      totalScore += traitScore * weight;
      totalWeight += weight;
    }

    final overallScore = totalWeight > 0 ? totalScore / totalWeight : 0.0;
    final roundedScore = double.parse(overallScore.toStringAsFixed(2));

    return {
      'overallScore': roundedScore,
      'traitScores': traitScores,
      'matchLevel': _getMatchLevel(roundedScore),
      'recommendation': _getRecommendation(roundedScore),
    };
  }

  /// Determine match level based on score
  static String _getMatchLevel(double score) {
    if (score >= 90) return 'Excellent Match';
    if (score >= 75) return 'Great Match';
    if (score >= 60) return 'Good Match';
    if (score >= 45) return 'Fair Match';
    if (score >= 30) return 'Poor Match';
    return 'Not Compatible';
  }

  /// Get recommendation message based on score
  static String _getRecommendation(double score) {
    if (score >= 90) {
      return 'Highly compatible! You share very similar preferences.';
    } else if (score >= 75) {
      return 'Great compatibility! Minor differences won\'t be an issue.';
    } else if (score >= 60) {
      return 'Good match. Some compromises may be needed.';
    } else if (score >= 45) {
      return 'Fair compatibility. Discuss key differences before deciding.';
    } else if (score >= 30) {
      return 'Low compatibility. Significant lifestyle differences exist.';
    } else {
      return 'Not recommended. Major conflicts likely.';
    }
  }

  /// Sort roommate listings by compatibility score
  /// 
  /// Takes a list of roommate preference maps and sorts them by compatibility
  /// with the user's preferences (highest score first)
  static List<Map<String, dynamic>> sortByCompatibility(
    Map<String, int> userPreferences,
    List<Map<String, dynamic>> roommates,
  ) {
    // Add compatibility score to each roommate
    final roommatesWithScores = roommates.map((roommate) {
      final roommatePrefs = Map<String, int>.from(
        roommate['preferences'] as Map? ?? {},
      );
      final score = calculateCompatibilityScore(userPreferences, roommatePrefs);
      
      return {
        ...roommate,
        'compatibilityScore': score,
      };
    }).toList();

    // Sort by compatibility score (descending)
    roommatesWithScores.sort((a, b) {
      final scoreA = a['compatibilityScore'] as double;
      final scoreB = b['compatibilityScore'] as double;
      return scoreB.compareTo(scoreA);
    });

    return roommatesWithScores;
  }
}

/// Pseudo-code representation of the algorithm:
/// 
/// FUNCTION calculateCompatibilityScore(userPrefs, roommatePrefs):
///   
///   // Step 1: Validate inputs
///   IF userPrefs is empty OR roommatePrefs is empty:
///     RETURN 0
///   
///   // Step 2: Find common traits
///   commonTraits = intersection(userPrefs.keys, roommatePrefs.keys)
///   IF commonTraits is empty:
///     RETURN 0
///   
///   // Step 3: Calculate weighted scores
///   totalScore = 0
///   totalWeight = 0
///   
///   FOR EACH trait IN commonTraits:
///     userValue = userPrefs[trait]
///     roommateValue = roommatePrefs[trait]
///     
///     // Step 4: Calculate difference (0-4 scale)
///     difference = absolute(userValue - roommateValue)
///     
///     // Step 5: Convert to compatibility percentage
///     // difference 0 = 100%, difference 4 = 0%
///     traitScore = ((4 - difference) / 4) * 100
///     
///     // Step 6: Apply trait weight
///     weight = getTraitWeight(trait)
///     totalScore = totalScore + (traitScore * weight)
///     totalWeight = totalWeight + weight
///   
///   // Step 7: Calculate final weighted average
///   finalScore = totalScore / totalWeight
///   
///   RETURN round(finalScore, 2)
/// 
/// END FUNCTION
/// 
/// Example Calculation:
/// User: {cleanliness: 4, introvert: 5, loudness: 2}
/// Roommate: {cleanliness: 3, introvert: 4, loudness: 1}
/// 
/// Trait: cleanliness
///   - Difference: |4-3| = 1
///   - Score: (4-1)/4 * 100 = 75%
///   - Weight: 2.0
///   - Weighted Score: 75 * 2.0 = 150
/// 
/// Trait: introvert
///   - Difference: |5-4| = 1
///   - Score: (4-1)/4 * 100 = 75%
///   - Weight: 1.5
///   - Weighted Score: 75 * 1.5 = 112.5
/// 
/// Trait: loudness
///   - Difference: |2-1| = 1
///   - Score: (4-1)/4 * 100 = 75%
///   - Weight: 1.8
///   - Weighted Score: 75 * 1.8 = 135
/// 
/// Final Score: (150 + 112.5 + 135) / (2.0 + 1.5 + 1.8)
///            = 397.5 / 5.3
///            = 75.00
/// 
/// Result: 75.00 (Great Match)
