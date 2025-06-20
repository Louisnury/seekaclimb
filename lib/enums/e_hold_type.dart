enum EHoldType { start, end, foot, crux }

extension EHoldTypeExtension on EHoldType {
  static EHoldType eHoldTypeFromKey(int index) {
    return switch (index) {
      0 => EHoldType.start,
      1 => EHoldType.end,
      2 => EHoldType.foot,
      3 => EHoldType.crux,
      _ => throw ArgumentError('Index $index invalide pour EHoldType'),
    };
  }
}
