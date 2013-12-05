// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.collection;

/** Default function for equality comparison in customized HashMaps */
bool _defaultEquals(a, b) => a == b;
/** Default function for hash-code computation in customized HashMaps */
int _defaultHashCode(a) => a.hashCode;

/** Type of custom equality function */
typedef bool _Equality<K>(K a, K b);
/** Type of custom hash code function. */
typedef int _Hasher<K>(K object);

/**
 * A hash-table based implementation of [Map].
 *
 * The keys of a `HashMap` must have consistent [Object.operator==]
 * and [Object.hashCode] implementations. This means that the `==` operator
 * must define a stable equivalence relation on the keys (reflexive,
 * anti-symmetric, transitive, and consistent over time), and that `hashCode`
 * must be the same for objects that are considered equal by `==`.
 *
 * The map allows `null` as a key.
 */
abstract class HashMap<K, V> implements Map<K, V> {
  /**
   * Creates a hash-table based [Map].
   *
   * The created map is not ordered in any way. When iterating the keys or
   * values, the iteration order is unspecified except that it will stay the
   * same as long as the map isn't changed.
   *
   * If [equals] is provided, it is used to compare the keys in the table with
   * new keys. If [equals] is omitted, the key's own [Object.operator==] is used
   * instead.
   *
   * Similar, if [hashCode] is provided, it is used to produce a hash value
   * for keys in order to place them in the hash table. If it is omitted, the
   * key's own [Object.hashCode] is used.
   *
   * The used `equals` and `hashCode` method should always be consistent,
   * so that if `equals(a, b)` then `hashCode(a) == hashCode(b)`. The hash
   * of an object, or what it compares equal to, should not change while the
   * object is in the table. If it does change, the result is unpredictable.
   *
   * It is generally the case that if you supply one of [equals] and [hashCode],
   * you also want to supply the other. The only common exception is to pass
   * [identical] as the equality and use the default hash code.
   */
  external factory HashMap({bool equals(K key1, K key2), int hashCode(K key)});

  /**
   * Creates a [HashMap] that contains all key value pairs of [other].
   */
  factory HashMap.from(Map<K, V> other) {
    return new HashMap<K, V>()..addAll(other);
  }

  /**
   * Creates a [HashMap] where the keys and values are computed from the
   * [iterable].
   *
   * For each element of the [iterable] this constructor computes a key/value
   * pair, by applying [key] and [value] respectively.
   *
   * The keys of the key/value pairs do not need to be unique. The last
   * occurrence of a key will simply overwrite any previous value.
   *
   * If no values are specified for [key] and [value] the default is the
   * identity function.
   */
  factory HashMap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) {
    HashMap<K, V> map = new HashMap<K, V>();
    Maps._fillMapWithMappedIterable(map, iterable, key, value);
    return map;
  }

  /**
   * Creates a [HashMap] associating the given [keys] to [values].
   *
   * This constructor iterates over [keys] and [values] and maps each element of
   * [keys] to the corresponding element of [values].
   *
   * If [keys] contains the same object multiple times, the last occurrence
   * overwrites the previous value.
   *
   * It is an error if the two [Iterable]s don't have the same length.
   */
  factory HashMap.fromIterables(Iterable<K> keys, Iterable<V> values) {
    HashMap<K, V> map = new HashMap<K, V>();
    Maps._fillMapWithIterables(map, keys, values);
    return map;
  }
}