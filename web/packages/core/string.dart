// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.core;

/**
 * A class for working with a sequence of characters.
 *
 * A string is represented by a sequence of Unicode UTF-16 code units
 * accessible through the [codeUnitAt] or the [codeUnits] members. Their
 * string representation is accessible through the index-operator.
 *
 * The characters of a string are encoded in UTF-16. Decoding UTF-16, which
 * combines surrogate pairs, yields Unicode code points. Following a similar
 * terminology to Go we use the name "rune" for an integer representing a
 * Unicode code point. The runes of a string are accessible through the [runes]
 * getter.
 *
 * Strings are immutable.
 *
 * It is a compile-time error for a class to attempt to extend or implement
 * String.
 *
 * For concatenating strings efficiently, use the [StringBuffer] class. For
 * working with regular expressions, use the [RegExp] class.
 */
abstract class String implements Comparable<String>, Pattern {
  /**
   * Allocates a new String for the specified [charCodes].
   *
   * The [charCodes] can be UTF-16 code units or runes. If a char-code value is
   * 16-bit it is copied verbatim. If it is greater than 16 bits it is
   * decomposed into a surrogate pair.
   */
  external factory String.fromCharCodes(Iterable<int> charCodes);

  /**
   * Allocates a new String for the specified [charCode].
   *
   * The new string contains a single code unit if the [charCode] can be
   * represented by a single UTF-16 code unit. Otherwise the [length] is 2 and
   * the code units form a surrogate pair.
   *
   * It is allowed (though generally discouraged) to create a String with only
   * one half of a surrogate pair.
   */
  factory String.fromCharCode(int charCode) {
    List<int> charCodes = new List<int>.filled(1, charCode);
    return new String.fromCharCodes(charCodes);
  }

  /**
   * Gets the character (as a single-code-unit [String]) at the given [index].
   *
   * The returned string represents exactly one UTF-16 code unit which may be
   * half of a surrogate pair. For example the Unicode character for a
   * musical G-clef ("𝄞") with rune value 0x1D11E consists of a UTF-16 surrogate
   * pair: `0xD834` and `0xDD1E`. Using the index-operator on this string yields
   * a String with half of a surrogate pair:
   *
   *     var clef = "\u{1D11E}";
   *     clef.length;  // => 2
   *     clef.runes.first == 0x1D11E;  // => true
   *     clef.runes.length;  // => 1
   *     clef.codeUnitAt(0);  // => 0xD834
   *     clef.codeUnitAt(1);  // => 0xDD1E
   *     // The following strings are halves of a UTF-16 surrogate pair and
   *     // thus invalid UTF-16 strings:
   *     clef[0];  // => a string of length 1 with code-unit value 0xD834.
   *     clef[1];  // => a string of length 1 with code-unit value 0xDD1E.
   *
   * This method is equivalent to
   * `new String.fromCharCode(this.codeUnitAt(index))`.
   */
  String operator [](int index);

  /**
   * Returns the 16-bit UTF-16 code unit at the given [index].
   */
  int codeUnitAt(int index);

  /**
   * The length of the string.
   *
   * Returns the number of UTF-16 code units in this string. The number
   * of [runes] might be less, if the string contains characters outside
   * the basic multilingual plane (plane 0).
   */
  int get length;

  /**
   * Returns whether the two strings are equal.
   *
   * This method compares each individual code unit of the strings.
   * Equivalently (for strings that are well-formed UTF-16) it compares each
   * individual rune (code point).  It does not check for Unicode equivalence.
   * For example the two following strings both represent the string "Amélie"
   * but, due to their different encoding will not return equal.
   *
   *     "Am\xe9lie"
   *     "Ame\u{301}lie"
   *
   * In the first string the "é" is encoded as a single unicode code unit (also
   * a single rune), whereas the second string encodes it as "e" with the
   * combining accent character "◌́".
   */
  bool operator ==(var other);

  /**
   * Returns whether this string ends with [other].
   */
  bool endsWith(String other);

  /**
   * Returns whether this string starts with a match of [pattern].
   *
   * If [index] is provided, instead check if the substring starting
   * at that index starts with a match of [pattern].
   *
   * It is an error if [index] is negative or greater than [length].
   *
   * A [RegExp] containing "^" will not match if the [index] is greater than
   * zero. The pattern works on the string as a whole, and does not extract
   * a substring starting at [index] first. That is.
   *     "abc".startsWith(new RegExp("^.", 1)) == false
   */
  bool startsWith(Pattern pattern, [int index = 0]);

  /**
   * Returns the first position of a match of [pattern] in this string,
   * starting at [start] (inclusive).
   *
   * Returns -1 if a match could not be found.
   *
   * It is an error if start is negative or greater than [length].
   */
  int indexOf(Pattern pattern, [int start]);

  /**
   * Returns the last position of a match [pattern] in this string, searching
   * backward starting at [start] (inclusive).
   *
   * Returns -1 if [other] could not be found.
   *
   * It is an error if start is negative or greater than [length].
   */
  int lastIndexOf(Pattern pattern, [int start]);

  /**
   * Returns whether this string is empty.
   */
  bool get isEmpty;

  /**
   * Returns whether this string is not empty.
   */
  bool get isNotEmpty;

  /**
   * Creates a new string by concatenating this string with [other].
   *
   * A sequence of strings can be concatenated by using [Iterable.join]:
   *
   *     var strings = ['foo', 'bar', 'geez'];
   *     var concatenated = strings.join();
   */
  String operator +(String other);

  /**
   * Returns a substring of this string in the given range.
   * [startIndex] is inclusive and [endIndex] is exclusive.
   */
  String substring(int startIndex, [int endIndex]);

  /**
   * Removes leading and trailing whitespace from a string.
   *
   * If the string contains leading or trailing whitespace a new string with no
   * leading and no trailing whitespace is returned. Otherwise, the string
   * itself is returned.
   *
   * Whitespace is defined by the Unicode White_Space property (as defined in
   * version 6.2 or later) and the BOM character, 0xFEFF.
   *
   * Here is the list of trimmed characters (following version 6.2):
   *
   *     0009..000D    ; White_Space # Cc   <control-0009>..<control-000D>
   *     0020          ; White_Space # Zs   SPACE
   *     0085          ; White_Space # Cc   <control-0085>
   *     00A0          ; White_Space # Zs   NO-BREAK SPACE
   *     1680          ; White_Space # Zs   OGHAM SPACE MARK
   *     180E          ; White_Space # Zs   MONGOLIAN VOWEL SEPARATOR
   *     2000..200A    ; White_Space # Zs   EN QUAD..HAIR SPACE
   *     2028          ; White_Space # Zl   LINE SEPARATOR
   *     2029          ; White_Space # Zp   PARAGRAPH SEPARATOR
   *     202F          ; White_Space # Zs   NARROW NO-BREAK SPACE
   *     205F          ; White_Space # Zs   MEDIUM MATHEMATICAL SPACE
   *     3000          ; White_Space # Zs   IDEOGRAPHIC SPACE
   *
   *     FEFF          ; BOM                ZERO WIDTH NO_BREAK SPACE
   */
  String trim();

  /**
   * Returns whether this string contains a match of [other].
   *
   * If [startIndex] is provided, only matches at or after that index
   * are considered.
   *
   * It is an error if [startIndex] is negative or greater than [length].
   */
  bool contains(Pattern other, [int startIndex = 0]);

  /**
   * Returns a new string where the first occurence of [from] in this string
   * is replaced with [to].
   */
  String replaceFirst(Pattern from, String to);

  /**
   * Replaces all substrings matching [from] with [replace].
   *
   * Returns a new string where the non-overlapping substrings that match
   * [from] (the ones iterated by `from.allMatches(thisString)`) are replaced
   * by the literal string [replace].
   *
   * Notice that the [replace] string is not interpreted. If the replacement
   * depends on the match (for example on a [RegExp]'s capture groups), use
   * the [replaceAllMapped] method instead.
   */
  String replaceAll(Pattern from, String replace);

  /**
   * Replace all substrings matching [from] by a string computed from the match.
   *
   * Returns a new string where the non-overlapping substrings that match
   * [from] (the ones iterated by `from.allMatches(thisString)`) are replaced
   * by the result of calling [replace] on the corresponding [Match] object.
   *
   * This can be used to replace matches with new content that depends on the
   * match, unlike [replaceAll] where the replacement string is always the same.
   *
   * Example (simplified pig latin):
   *     pigLatin(String words) => words.replaceAllMapped(
   *         new RegExp(r"\b(\w*?)([aeiou]\w*)", caseSensitive: false),
   *         (Match m) => "${m[2]}${m[1]}${m[1].isEmpty ? 'way' : 'ay'}");
   *
   * This would convert each word of a text to "pig-latin", so for example
   *   `pigLatin("I have a secret now!")`
   * returns
   *   `"Iway avehay away ecretsay ownay!"`
   */
  String replaceAllMapped(Pattern from, String replace(Match match));

  /**
   * Splits the string around matches of [pattern]. Returns
   * a list of substrings.
   *
   * Splitting with an empty string pattern (`""`) splits at UTF-16 code unit
   * boundaries and not at rune boundaries. The following two expressions
   * are hence equivalent:
   *
   *     string.split("")
   *     string.codeUnits.map((unit) => new String.fromCharCode(unit))
   *
   * Unless it guaranteed that the string is in the basic multilingual plane
   * (meaning that each code unit represents a rune) it is often better to
   * map the runes instead:
   *
   *     string.runes.map((rune) => new String.fromCharCode(rune))
   */
  List<String> split(Pattern pattern);

  /**
   * Splits the string on the [pattern], then converts each part and each match.
   *
   * The pattern is used to split the string into parts and separating matches.
   *
   * Each match is converted to a string by calling [onMatch]. If [onMatch]
   * is omitted, the matched string is used.
   *
   * Each non-matched part is converted by a call to [onNonMatch]. If
   * [onNonMatch] is omitted, the non-matching part is used.
   *
   * Then all the converted parts are combined into the resulting string.
   */
  String splitMapJoin(Pattern pattern,
                      {String onMatch(Match match),
                       String onNonMatch(String nonMatch)});

  /**
   * Returns an unmodifiable list of the UTF-16 code units of this string.
   */
  List<int> get codeUnits;

  /**
   * Returns an iterable of Unicode code-points of this string.
   *
   * If the string contains surrogate pairs, they will be combined and returned
   * as one integer by this iterator. Unmatched surrogate halves are treated
   * like valid 16-bit code-units.
   */
  Runes get runes;

  /**
   * If this string is not already all lower case, returns a new string
   * where all characters are made lower case. Returns [:this:] otherwise.
   */
  // TODO(floitsch): document better. (See EcmaScript for description).
  String toLowerCase();

  /**
   * If this string is not already all upper case, returns a new string
   * where all characters are made upper case. Returns [:this:] otherwise.
   */
  // TODO(floitsch): document better. (See EcmaScript for description).
  String toUpperCase();
}

/**
 * The runes (integer Unicode code points) of a [String].
 */
class Runes extends IterableBase<int> {
  final String string;
  Runes(this.string);

  RuneIterator get iterator => new RuneIterator(string);

  int get last {
    if (string.length == 0) {
      throw new StateError("No elements.");
    }
    int length = string.length;
    int code = string.codeUnitAt(length - 1);
    if (_isTrailSurrogate(code) && string.length > 1) {
      int previousCode = string.codeUnitAt(length - 2);
      if (_isLeadSurrogate(previousCode)) {
        return _combineSurrogatePair(previousCode, code);
      }
    }
    return code;
  }

}

// Is then code (a 16-bit unsigned integer) a UTF-16 lead surrogate.
bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

// Is then code (a 16-bit unsigned integer) a UTF-16 trail surrogate.
bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

// Combine a lead and a trail surrogate value into a single code point.
int _combineSurrogatePair(int start, int end) {
  return 0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF);
}

/** [Iterator] for reading runes (integer Unicode code points) out of a Dart
  * string.
  */
class RuneIterator implements BidirectionalIterator<int> {
  /** String being iterated. */
  final String string;
  /** Position before the current code point. */
  int _position;
  /** Position after the current code point. */
  int _nextPosition;
  /**
   * Current code point.
   *
   * If the iterator has hit either end, the [_currentCodePoint] is null
   * and [: _position == _nextPosition :].
   */
  int _currentCodePoint;

  /** Create an iterator positioned at the beginning of the string. */
  RuneIterator(String string)
      : this.string = string, _position = 0, _nextPosition = 0;

  /**
   * Create an iterator positioned before the [index]th code unit of the string.
   *
   * When created, there is no [current] value.
   * A [moveNext] will use the rune starting at [index] the current value,
   * and a [movePrevious] will use the rune ending just before [index] as the
   * the current value.
   *
   * It is an error if the [index] position is in the middle of a surrogate
   * pair.
   */
  RuneIterator.at(String string, int index)
      : string = string, _position = index, _nextPosition = index {
    if (index < 0 || index > string.length) {
      throw new RangeError.range(index, 0, string.length);
    }
    _checkSplitSurrogate(index);
  }

  /** Throw an error if the index is in the middle of a surrogate pair. */
  void _checkSplitSurrogate(int index) {
    if (index > 0 && index < string.length &&
        _isLeadSurrogate(string.codeUnitAt(index - 1)) &&
        _isTrailSurrogate(string.codeUnitAt(index))) {
      throw new ArgumentError("Index inside surrogate pair: $index");
    }
  }

  /**
   * Returns the starting position of the current rune in the string.
   *
   * Returns null if the [current] rune is null.
   */
  int get rawIndex => (_position != _nextPosition) ? _position : null;

  /**
   * Resets the iterator to the rune at the specified index of the string.
   *
   * Setting a negative [rawIndex], or one greater than or equal to
   * [:string.length:],
   * is an error. So is setting it in the middle of a surrogate pair.
   *
   * Setting the position to the end of then string will set [current] to null.
   */
  void set rawIndex(int rawIndex) {
    if (rawIndex >= string.length) {
      throw new RangeError.range(rawIndex, 0, string.length - 1);
    }
    reset(rawIndex);
    moveNext();
  }

  /**
   * Resets the iterator to the given index into the string.
   *
   * After this the [current] value is unset.
   * You must call [moveNext] make the rune at the position current,
   * or [movePrevious] for the last rune before the position.
   *
   * Setting a negative [rawIndex], or one greater than [:string.length:],
   * is an error. So is setting it in the middle of a surrogate pair.
   */
  void reset([int rawIndex = 0]) {
    if (rawIndex < 0 || rawIndex > string.length) {
      throw new RangeError.range(rawIndex, 0, string.length);
    }
    _checkSplitSurrogate(rawIndex);
    _position = _nextPosition = rawIndex;
    _currentCodePoint = null;
  }

  /** The rune (integer Unicode code point) starting at the current position in
   *  the string.
   */
  int get current => _currentCodePoint;

  /**
   * The number of code units comprising the current rune.
   *
   * Returns zero if there is no current rune ([current] is null).
   */
  int get currentSize => _nextPosition - _position;

  /**
   * A string containing the current rune.
   *
   * For runes outside the basic multilingual plane, this will be
   * a String of length 2, containing two code units.
   *
   * Returns null if [current] is null.
   */
  String get currentAsString {
    if (_position == _nextPosition) return null;
    if (_position + 1 == _nextPosition) return string[_position];
    return string.substring(_position, _nextPosition);
  }

  bool moveNext() {
    _position = _nextPosition;
    if (_position == string.length) {
      _currentCodePoint = null;
      return false;
    }
    int codeUnit = string.codeUnitAt(_position);
    int nextPosition = _position + 1;
    if (_isLeadSurrogate(codeUnit) && nextPosition < string.length) {
      int nextCodeUnit = string.codeUnitAt(nextPosition);
      if (_isTrailSurrogate(nextCodeUnit)) {
        _nextPosition = nextPosition + 1;
        _currentCodePoint = _combineSurrogatePair(codeUnit, nextCodeUnit);
        return true;
      }
    }
    _nextPosition = nextPosition;
    _currentCodePoint = codeUnit;
    return true;
  }

  bool movePrevious() {
    _nextPosition = _position;
    if (_position == 0) {
      _currentCodePoint = null;
      return false;
    }
    int position = _position - 1;
    int codeUnit = string.codeUnitAt(position);
    if (_isTrailSurrogate(codeUnit) && position > 0) {
      int prevCodeUnit = string.codeUnitAt(position - 1);
      if (_isLeadSurrogate(prevCodeUnit)) {
        _position = position - 1;
        _currentCodePoint = _combineSurrogatePair(prevCodeUnit, codeUnit);
        return true;
      }
    }
    _position = position;
    _currentCodePoint = codeUnit;
    return true;
  }
}
