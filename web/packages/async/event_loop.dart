// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.async;

typedef void _AsyncCallback();

bool _callbacksAreEnqueued = false;
Queue<_AsyncCallback> _asyncCallbacks = new Queue<_AsyncCallback>();

void _asyncRunCallback() {
  // As long as we are iterating over the registered callbacks we don't
  // unset the [_callbacksAreEnqueued] boolean.
  while (!_asyncCallbacks.isEmpty) {
    Function callback = _asyncCallbacks.removeFirst();
    try {
      callback();
    } catch (e) {
      _AsyncRun._enqueueImmediate(_asyncRunCallback);
      rethrow;
    }
  }
  // Any new callback must register a callback function now.
  _callbacksAreEnqueued = false;
}

void _scheduleAsyncCallback(callback) {
  // Optimizing a group of Timer.run callbacks to be executed in the
  // same Timer callback.
  _asyncCallbacks.add(callback);
  if (!_callbacksAreEnqueued) {
    _AsyncRun._enqueueImmediate(_asyncRunCallback);
    _callbacksAreEnqueued = true;
  }
}

/**
 * Runs the given [callback] asynchronously.
 *
 * Callbacks registered through this function are always executed in order and
 * are guaranteed to run before other asynchronous events (like [Timer] events,
 * or DOM events).
 *
 * Warning: it is possible to starve the DOM by registering asynchronous
 * callbacks through this method. For example the following program will
 * run the callbacks without ever giving the Timer callback a chance to execute:
 *
 *     Timer.run(() { print("executed"); });  // Will never be executed;
 *     foo() {
 *       asyncRun(foo);  // Schedules [foo] in front of other events.
 *     }
 *     main() {
 *       foo();
 *     }
 */
void runAsync(void callback()) {
  _Zone currentZone = _Zone._current;
  currentZone.runAsync(callback, currentZone);
}

class _AsyncRun {
  /** Enqueues the given callback before any other event in the event-loop. */
  external static void _enqueueImmediate(void callback());
}
