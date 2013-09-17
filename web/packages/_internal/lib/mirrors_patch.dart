// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Patch library for dart:mirrors.

import 'dart:_js_mirrors' as js;

patch class MirrorSystem {
  patch static String getName(Symbol symbol) => js.getName(symbol);
}

patch MirrorSystem currentMirrorSystem() => js.currentJsMirrorSystem;

patch Future<MirrorSystem> mirrorSystemOf(SendPort port) {
  throw new UnsupportedError("MirrorSystem not implemented");
}

patch InstanceMirror reflect(Object reflectee) => js.reflect(reflectee);

patch ClassMirror reflectClass(Type key) => js.reflectType(key);
