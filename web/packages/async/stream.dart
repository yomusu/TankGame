// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.async;

// -------------------------------------------------------------------
// Core Stream types
// -------------------------------------------------------------------

/**
 * A source of asynchronous data events.
 *
 * A Stream provides a sequence of events. Each event is either a data event or
 * an error event, representing the result of a single computation. When the
 * Stream is exhausted, it may send a single "done" event.
 *
 * You can [listen] on a stream to receive the events it sends. When you listen,
 * you receive a [StreamSubscription] object that can be used to stop listening,
 * or to temporarily pause events from the stream.
 *
 * When an event is fired, the listeners at that time are informed.
 * If a listener is added while an event is being fired, the change
 * will only take effect after the event is completely fired. If a listener
 * is canceled, it immediately stops receiving events.
 *
 * When the "done" event is fired, subscribers are unsubscribed before
 * receiving the event. After the event has been sent, the stream has no
 * subscribers. Adding new subscribers after this point is allowed, but
 * they will just receive a new "done" event as soon as possible.
 *
 * Streams always respect "pause" requests. If necessary they need to buffer
 * their input, but often, and preferably, they can simply request their input
 * to pause too.
 *
 * There are two kinds of streams: The normal "single-subscription" streams and
 * "broadcast" streams.
 *
 * A single-subscription stream allows only a single listener at a time.
 * It holds back events until it gets a listener, and it may exhaust
 * itself when the listener is unsubscribed, even if the stream wasn't done.
 *
 * Single-subscription streams are generally used for streaming parts of
 * contiguous data like file I/O.
 *
 * A broadcast stream allows any number of listeners, and it fires
 * its events when they are ready, whether there are listeners or not.
 *
 * Broadcast streams are used for independent events/observers.
 *
 * The default implementation of [isBroadcast] returns false.
 * A broadcast stream inheriting from [Stream] must override [isBroadcast]
 * to return [:true:].
 */
abstract class Stream<T> {
  Stream();

  /**
   * Creates a new single-subscription stream from the future.
   *
   * When the future completes, the stream will fire one event, either
   * data or error, and then close with a done-event.
   */
  factory Stream.fromFuture(Future<T> future) {
    StreamController<T> controller = new StreamController<T>(sync: true);
    future.then((value) {
        controller.add(value);
        controller.close();
      },
      onError: (error) {
        controller.addError(error);
        controller.close();
      });
    return controller.stream;
  }

  /**
   * Creates a single-subscription stream that gets its data from [data].
   *
   * If iterating [data] throws an error, the stream ends immediately with
   * that error. No done event will be sent (iteration is not complete), but no
   * further data events will be generated either, since iteration cannot
   * continue.
   */
  factory Stream.fromIterable(Iterable<T> data) {
    return new _GeneratedStreamImpl<T>(
        () => new _IterablePendingEvents<T>(data));
  }

  /**
   * Creates a stream that repeatedly emits events at [period] intervals.
   *
   * The event values are computed by invoking [computation]. The argument to
   * this callback is an integer that starts with 0 and is incremented for
   * every event.
   *
   * If [computation] is omitted the event values will all be `null`.
   */
  factory Stream.periodic(Duration period,
                          [T computation(int computationCount)]) {
    if (computation == null) computation = ((i) => null);

    Timer timer;
    int computationCount = 0;
    StreamController<T> controller;
    // Counts the time that the Stream was running (and not paused).
    Stopwatch watch = new Stopwatch();

    void sendEvent() {
      watch.reset();
      T data = computation(computationCount++);
      controller.add(data);
    }

    void startPeriodicTimer() {
      assert(timer == null);
      timer = new Timer.periodic(period, (Timer timer) {
        sendEvent();
      });
    }

    controller = new StreamController<T>(sync: true,
        onListen: () {
          watch.start();
          startPeriodicTimer();
        },
        onPause: () {
          timer.cancel();
          timer = null;
          watch.stop();
        },
        onResume: () {
          assert(timer == null);
          Duration elapsed = watch.elapsed;
          watch.start();
          timer = new Timer(period - elapsed, () {
            timer = null;
            startPeriodicTimer();
            sendEvent();
          });
        },
        onCancel: () {
          if (timer != null) timer.cancel();
          timer = null;
        });
    return controller.stream;
  }

  /**
   * Reports whether this stream is a broadcast stream.
   */
  bool get isBroadcast => false;

  /**
   * Returns a multi-subscription stream that produces the same events as this.
   *
   * If this stream is already a broadcast stream, it is returned unmodified.
   *
   * If this stream is single-subscription, return a new stream that allows
   * multiple subscribers. It will subscribe to this stream when its first
   * subscriber is added, and will stay subscribed until this stream ends,
   * or a callback cancels the subscription.
   *
   * If [onListen] is provided, it is called with a subscription-like object
   * that represents the underlying subscription to this stream. It is
   * possible to pause, resume or cancel the subscription during the call
   * to [onListen]. It is not possible to change the event handlers, including
   * using [StreamSubscription.asFuture].
   *
   * If [onCancel] is provided, it is called in a similar way to [onListen]
   * when the returned stream stops having listener. If it later gets
   * a new listener, the [onListen] function is called again.
   *
   * Use the callbacks, for example, for pausing the underlying subscription
   * while having no subscribers to prevent losing events, or canceling the
   * subscription when there are no listeners.
   */
  Stream<T> asBroadcastStream({
      void onListen(StreamSubscription<T> subscription),
      void onCancel(StreamSubscription<T> subscription) }) {
    if (isBroadcast) return this;
    return new _AsBroadcastStream<T>(this, onListen, onCancel);
  }

  /**
   * Adds a subscription to this stream.
   *
   * On each data event from this stream, the subscriber's [onData] handler
   * is called. If [onData] is null, nothing happens.
   *
   * On errors from this stream, the [onError] handler is given a
   * object describing the error.
   *
   * If this stream closes, the [onDone] handler is called.
   *
   * If [cancelOnError] is true, the subscription is ended when
   * the first error is reported. The default is false.
   */
  StreamSubscription<T> listen(void onData(T event),
                               { void onError(error),
                                 void onDone(),
                                 bool cancelOnError});

  /**
   * Creates a new stream from this stream that discards some data events.
   *
   * The new stream sends the same error and done events as this stream,
   * but it only sends the data events that satisfy the [test].
   */
  Stream<T> where(bool test(T event)) {
    return new _WhereStream<T>(this, test);
  }

  /**
   * Creates a new stream that converts each element of this stream
   * to a new value using the [convert] function.
   */
  Stream map(convert(T event)) {
    return new _MapStream<T, dynamic>(this, convert);
  }

  /**
   * Creates a wrapper Stream that intercepts some errors from this stream.
   *
   * If this stream sends an error that matches [test], then it is intercepted
   * by the [handle] function.
   *
   * An [AsyncError] [:e:] is matched by a test function if [:test(e):] returns
   * true. If [test] is omitted, every error is considered matching.
   *
   * If the error is intercepted, the [handle] function can decide what to do
   * with it. It can throw if it wants to raise a new (or the same) error,
   * or simply return to make the stream forget the error.
   *
   * If you need to transform an error into a data event, use the more generic
   * [Stream.transform] to handle the event by writing a data event to
   * the output sink
   */
  Stream<T> handleError(void handle( error), { bool test(error) }) {
    return new _HandleErrorStream<T>(this, handle, test);
  }

  /**
   * Creates a new stream from this stream that converts each element
   * into zero or more events.
   *
   * Each incoming event is converted to an [Iterable] of new events,
   * and each of these new events are then sent by the returned stream
   * in order.
   */
  Stream expand(Iterable convert(T value)) {
    return new _ExpandStream<T, dynamic>(this, convert);
  }

  /**
   * Binds this stream as the input of the provided [StreamConsumer].
   */
  Future pipe(StreamConsumer<T> streamConsumer) {
    return streamConsumer.addStream(this).then((_) => streamConsumer.close());
  }

  /**
   * Chains this stream as the input of the provided [StreamTransformer].
   *
   * Returns the result of [:streamTransformer.bind:] itself.
   */
  Stream transform(StreamTransformer<T, dynamic> streamTransformer) {
    return streamTransformer.bind(this);
  }

  /**
   * Reduces a sequence of values by repeatedly applying [combine].
   */
  Future<T> reduce(T combine(T previous, T element)) {
    _FutureImpl<T> result = new _FutureImpl<T>();
    bool seenFirst = false;
    T value;
    StreamSubscription subscription;
    subscription = this.listen(
      (T element) {
        if (seenFirst) {
          _runUserCode(() => combine(value, element),
                       (T newValue) { value = newValue; },
                       _cancelAndError(subscription, result));
        } else {
          value = element;
          seenFirst = true;
        }
      },
      onError: result._setError,
      onDone: () {
        if (!seenFirst) {
          result._setError(new StateError("No elements"));
        } else {
          result._setValue(value);
        }
      },
      cancelOnError: true
    );
    return result;
  }

  /** Reduces a sequence of values by repeatedly applying [combine]. */
  Future fold(var initialValue, combine(var previous, T element)) {
    _FutureImpl result = new _FutureImpl();
    var value = initialValue;
    StreamSubscription subscription;
    subscription = this.listen(
      (T element) {
        _runUserCode(
          () => combine(value, element),
          (newValue) { value = newValue; },
          _cancelAndError(subscription, result)
        );
      },
      onError: (e) {
        result._setError(e);
      },
      onDone: () {
        result._setValue(value);
      },
      cancelOnError: true);
    return result;
  }

  /**
   * Collects string of data events' string representations.
   *
   * If [separator] is provided, it is inserted between any two
   * elements.
   *
   * Any error in the stream causes the future to complete with that
   * error. Otherwise it completes with the collected string when
   * the "done" event arrives.
   */
  Future<String> join([String separator = ""]) {
    _FutureImpl<String> result = new _FutureImpl<String>();
    StringBuffer buffer = new StringBuffer();
    StreamSubscription subscription;
    bool first = true;
    subscription = this.listen(
      (T element) {
        if (!first) {
          buffer.write(separator);
        }
        first = false;
        try {
          buffer.write(element);
        } catch (e, s) {
          subscription.cancel();
          result._setError(_asyncError(e, s));
        }
      },
      onError: (e) {
        result._setError(e);
      },
      onDone: () {
        result._setValue(buffer.toString());
      },
      cancelOnError: true);
    return result;
  }

  /**
   * Checks whether [needle] occurs in the elements provided by this stream.
   *
   * Completes the [Future] when the answer is known.
   * If this stream reports an error, the [Future] will report that error.
   */
  Future<bool> contains(Object needle) {
    _FutureImpl<bool> future = new _FutureImpl<bool>();
    StreamSubscription subscription;
    subscription = this.listen(
        (T element) {
          _runUserCode(
            () => (element == needle),
            (bool isMatch) {
              if (isMatch) {
                subscription.cancel();
                future._setValue(true);
              }
            },
            _cancelAndError(subscription, future)
          );
        },
        onError: future._setError,
        onDone: () {
          future._setValue(false);
        },
        cancelOnError: true);
    return future;
  }

  /**
   * Executes [action] on each data event of the stream.
   *
   * Completes the returned [Future] when all events of the stream
   * have been processed. Completes the future with an error if the
   * stream has an error event, or if [action] throws.
   */
  Future forEach(void action(T element)) {
    _FutureImpl future = new _FutureImpl();
    StreamSubscription subscription;
    subscription = this.listen(
        (T element) {
          _runUserCode(
            () => action(element),
            (_) {},
            _cancelAndError(subscription, future)
          );
        },
        onError: future._setError,
        onDone: () {
          future._setValue(null);
        },
        cancelOnError: true);
    return future;
  }

  /**
   * Checks whether [test] accepts all elements provided by this stream.
   *
   * Completes the [Future] when the answer is known.
   * If this stream reports an error, the [Future] will report that error.
   */
  Future<bool> every(bool test(T element)) {
    _FutureImpl<bool> future = new _FutureImpl<bool>();
    StreamSubscription subscription;
    subscription = this.listen(
        (T element) {
          _runUserCode(
            () => test(element),
            (bool isMatch) {
              if (!isMatch) {
                subscription.cancel();
                future._setValue(false);
              }
            },
            _cancelAndError(subscription, future)
          );
        },
        onError: future._setError,
        onDone: () {
          future._setValue(true);
        },
        cancelOnError: true);
    return future;
  }

  /**
   * Checks whether [test] accepts any element provided by this stream.
   *
   * Completes the [Future] when the answer is known.
   * If this stream reports an error, the [Future] will report that error.
   */
  Future<bool> any(bool test(T element)) {
    _FutureImpl<bool> future = new _FutureImpl<bool>();
    StreamSubscription subscription;
    subscription = this.listen(
        (T element) {
          _runUserCode(
            () => test(element),
            (bool isMatch) {
              if (isMatch) {
                subscription.cancel();
                future._setValue(true);
              }
            },
            _cancelAndError(subscription, future)
          );
        },
        onError: future._setError,
        onDone: () {
          future._setValue(false);
        },
        cancelOnError: true);
    return future;
  }


  /** Counts the elements in the stream. */
  Future<int> get length {
    _FutureImpl<int> future = new _FutureImpl<int>();
    int count = 0;
    this.listen(
      (_) { count++; },
      onError: future._setError,
      onDone: () {
        future._setValue(count);
      },
      cancelOnError: true);
    return future;
  }

  /** Reports whether this stream contains any elements. */
  Future<bool> get isEmpty {
    _FutureImpl<bool> future = new _FutureImpl<bool>();
    StreamSubscription subscription;
    subscription = this.listen(
      (_) {
        subscription.cancel();
        future._setValue(false);
      },
      onError: future._setError,
      onDone: () {
        future._setValue(true);
      },
      cancelOnError: true);
    return future;
  }

  /** Collects the data of this stream in a [List]. */
  Future<List<T>> toList() {
    List<T> result = <T>[];
    _FutureImpl<List<T>> future = new _FutureImpl<List<T>>();
    this.listen(
      (T data) {
        result.add(data);
      },
      onError: future._setError,
      onDone: () {
        future._setValue(result);
      },
      cancelOnError: true);
    return future;
  }

  /** Collects the data of this stream in a [Set]. */
  Future<Set<T>> toSet() {
    Set<T> result = new Set<T>();
    _FutureImpl<Set<T>> future = new _FutureImpl<Set<T>>();
    this.listen(
      (T data) {
        result.add(data);
      },
      onError: future._setError,
      onDone: () {
        future._setValue(result);
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Discards all data on the stream, but signals when it's done or an error
   * occured.
   *
   * When subscribing using [drain], cancelOnError will be true. This means
   * that the future will complete with the first error on the stream and then
   * cancel the subscription.
   *
   * In case of a `done` event the future completes with the given
   * [futureValue].
   */
  Future drain([var futureValue]) => listen(null, cancelOnError: true)
      .asFuture(futureValue);

  /**
   * Provides at most the first [n] values of this stream.
   *
   * Forwards the first [n] data events of this stream, and all error
   * events, to the returned stream, and ends with a done event.
   *
   * If this stream produces fewer than [count] values before it's done,
   * so will the returned stream.
   */
  Stream<T> take(int count) {
    return new _TakeStream(this, count);
  }

  /**
   * Forwards data events while [test] is successful.
   *
   * The returned stream provides the same events as this stream as long
   * as [test] returns [:true:] for the event data. The stream is done
   * when either this stream is done, or when this stream first provides
   * a value that [test] doesn't accept.
   */
  Stream<T> takeWhile(bool test(T element)) {
    return new _TakeWhileStream(this, test);
  }

  /**
   * Skips the first [count] data events from this stream.
   */
  Stream<T> skip(int count) {
    return new _SkipStream(this, count);
  }

  /**
   * Skip data events from this stream while they are matched by [test].
   *
   * Error and done events are provided by the returned stream unmodified.
   *
   * Starting with the first data event where [test] returns false for the
   * event data, the returned stream will have the same events as this stream.
   */
  Stream<T> skipWhile(bool test(T element)) {
    return new _SkipWhileStream(this, test);
  }

  /**
   * Skips data events if they are equal to the previous data event.
   *
   * The returned stream provides the same events as this stream, except
   * that it never provides two consequtive data events that are equal.
   *
   * Equality is determined by the provided [equals] method. If that is
   * omitted, the '==' operator on the last provided data element is used.
   */
  Stream<T> distinct([bool equals(T previous, T next)]) {
    return new _DistinctStream(this, equals);
  }

  /**
   * Returns the first element of the stream.
   *
   * Stops listening to the stream after the first element has been received.
   *
   * If an error event occurs before the first data event, the resulting future
   * is completed with that error.
   *
   * If this stream is empty (a done event occurs before the first data event),
   * the resulting future completes with a [StateError].
   *
   * Except for the type of the error, this method is equivalent to
   * [:this.elementAt(0):].
   */
  Future<T> get first {
    _FutureImpl<T> future = new _FutureImpl<T>();
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        subscription.cancel();
        future._setValue(value);
        return;
      },
      onError: future._setError,
      onDone: () {
        future._setError(new StateError("No elements"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Returns the last element of the stream.
   *
   * If an error event occurs before the first data event, the resulting future
   * is completed with that error.
   *
   * If this stream is empty (a done event occurs before the first data event),
   * the resulting future completes with a [StateError].
   */
  Future<T> get last {
    _FutureImpl<T> future = new _FutureImpl<T>();
    T result = null;
    bool foundResult = false;
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        foundResult = true;
        result = value;
      },
      onError: future._setError,
      onDone: () {
        if (foundResult) {
          future._setValue(result);
          return;
        }
        future._setError(new StateError("No elements"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Returns the single element.
   *
   * If [this] is empty or has more than one element throws a [StateError].
   */
  Future<T> get single {
    _FutureImpl<T> future = new _FutureImpl<T>();
    T result = null;
    bool foundResult = false;
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        if (foundResult) {
          subscription.cancel();
          // This is the second element we get.
          Error error = new StateError("More than one element");
          future._setError(error);
          return;
        }
        foundResult = true;
        result = value;
      },
      onError: future._setError,
      onDone: () {
        if (foundResult) {
          future._setValue(result);
          return;
        }
        future._setError(new StateError("No elements"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Finds the first element of this stream matching [test].
   *
   * Returns a future that is filled with the first element of this stream
   * that [test] returns true for.
   *
   * If no such element is found before this stream is done, and a
   * [defaultValue] function is provided, the result of calling [defaultValue]
   * becomes the value of the future.
   *
   * If an error occurs, or if this stream ends without finding a match and
   * with no [defaultValue] function provided, the future will receive an
   * error.
   */
  Future<dynamic> firstWhere(bool test(T element), {Object defaultValue()}) {
    _FutureImpl<dynamic> future = new _FutureImpl();
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        _runUserCode(
          () => test(value),
          (bool isMatch) {
            if (isMatch) {
              subscription.cancel();
              future._setValue(value);
            }
          },
          _cancelAndError(subscription, future)
        );
      },
      onError: future._setError,
      onDone: () {
        if (defaultValue != null) {
          _runUserCode(defaultValue, future._setValue, future._setError);
          return;
        }
        future._setError(new StateError("firstMatch ended without match"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Finds the last element in this stream matching [test].
   *
   * As [firstWhere], except that the last matching element is found.
   * That means that the result cannot be provided before this stream
   * is done.
   */
  Future<dynamic> lastWhere(bool test(T element), {Object defaultValue()}) {
    _FutureImpl<dynamic> future = new _FutureImpl();
    T result = null;
    bool foundResult = false;
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        _runUserCode(
          () => true == test(value),
          (bool isMatch) {
            if (isMatch) {
              foundResult = true;
              result = value;
            }
          },
          _cancelAndError(subscription, future)
        );
      },
      onError: future._setError,
      onDone: () {
        if (foundResult) {
          future._setValue(result);
          return;
        }
        if (defaultValue != null) {
          _runUserCode(defaultValue, future._setValue, future._setError);
          return;
        }
        future._setError(new StateError("lastMatch ended without match"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Finds the single element in this stream matching [test].
   *
   * Like [lastMatch], except that it is an error if more than one
   * matching element occurs in the stream.
   */
  Future<T> singleWhere(bool test(T element)) {
    _FutureImpl<T> future = new _FutureImpl<T>();
    T result = null;
    bool foundResult = false;
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        _runUserCode(
          () => true == test(value),
          (bool isMatch) {
            if (isMatch) {
              if (foundResult) {
                subscription.cancel();
                future._setError(
                    new StateError('Multiple matches for "single"'));
                return;
              }
              foundResult = true;
              result = value;
            }
          },
          _cancelAndError(subscription, future)
        );
      },
      onError: future._setError,
      onDone: () {
        if (foundResult) {
          future._setValue(result);
          return;
        }
        future._setError(new StateError("single ended without match"));
      },
      cancelOnError: true);
    return future;
  }

  /**
   * Returns the value of the [index]th data event of this stream.
   *
   * Stops listening to the stream after a value has been found.
   *
   * If an error event occurs before the value is found, the future completes
   * with this error.
   *
   * If a done event occurs before the value is found, the future completes
   * with a [RangeError].
   */
  Future<T> elementAt(int index) {
    if (index is! int || index < 0) throw new ArgumentError(index);
    _FutureImpl<T> future = new _FutureImpl<T>();
    StreamSubscription subscription;
    subscription = this.listen(
      (T value) {
        if (index == 0) {
          subscription.cancel();
          future._setValue(value);
          return;
        }
        index -= 1;
      },
      onError: future._setError,
      onDone: () {
        future._setError(new RangeError.value(index));
      },
      cancelOnError: true);
    return future;
  }
}

/**
 * A control object for the subscription on a [Stream].
 *
 * When you subscribe on a [Stream] using [Stream.listen],
 * a [StreamSubscription] object is returned. This object
 * is used to later unsubscribe again, or to temporarily pause
 * the stream's events.
 */
abstract class StreamSubscription<T> {
  /**
   * Cancels this subscription. It will no longer receive events.
   *
   * If an event is currently firing, this unsubscription will only
   * take effect after all subscribers have received the current event.
   */
  void cancel();

  /** Set or override the data event handler of this subscription. */
  void onData(void handleData(T data));

  /** Set or override the error event handler of this subscription. */
  void onError(void handleError(error));

  /** Set or override the done event handler of this subscription. */
  void onDone(void handleDone());

  /**
   * Request that the stream pauses events until further notice.
   *
   * If [resumeSignal] is provided, the stream will undo the pause
   * when the future completes. If the future completes with an error,
   * it will not be handled!
   *
   * A call to [resume] will also undo a pause.
   *
   * If the subscription is paused more than once, an equal number
   * of resumes must be performed to resume the stream.
   */
  void pause([Future resumeSignal]);

  /**
   * Resume after a pause.
   */
  void resume();

  /**
   * Returns true if the [StreamSubscription] is paused.
   */
  bool get isPaused;

  /**
   * Returns a future that handles the [onDone] and [onError] callbacks.
   *
   * This method *overwrites* the existing [onDone] and [onError] callbacks
   * with new ones that complete the returned future.
   *
   * In case of an error the subscription will automatically cancel (even
   * when it was listening with `cancelOnError` set to `false`).
   *
   * In case of a `done` event the future completes with the given
   * [futureValue].
   */
  Future asFuture([var futureValue]);
}


/**
 * An interface that abstracts creation or handling of [Stream] events.
 */
abstract class EventSink<T> {
  /** Create a data event */
  void add(T event);
  /** Create an async error. */
  void addError(errorEvent);
  /** Request a stream to close. */
  void close();
}


/** [Stream] wrapper that only exposes the [Stream] interface. */
class StreamView<T> extends Stream<T> {
  Stream<T> _stream;

  StreamView(this._stream);

  bool get isBroadcast => _stream.isBroadcast;

  Stream<T> asBroadcastStream({void onListen(StreamSubscription subscription),
                               void onCancel(StreamSubscription subscription)})
      => _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  StreamSubscription<T> listen(void onData(T value),
                               { void onError(error),
                                 void onDone(),
                                 bool cancelOnError }) {
    return _stream.listen(onData, onError: onError, onDone: onDone,
                          cancelOnError: cancelOnError);
  }
}


/**
 * The target of a [Stream.pipe] call.
 *
 * The [Stream.pipe] call will pass itself to this object, and then return
 * the resulting [Future]. The pipe should complete the future when it's
 * done.
 */
abstract class StreamConsumer<S> {
  Future addStream(Stream<S> stream);
  Future close();
}


/**
 * A [StreamSink] unifies the asynchronous methods from [StreamConsumer] and
 * the synchronous methods from [EventSink].
 *
 * The [EventSink] methods can't be used while the [addStream] is called.
 * As soon as the [addStream]'s [Future] completes with a value, the
 * [EventSink] methods can be used again.
 *
 * If [addStream] is called after any of the [EventSink] methods, it'll
 * be delayed until the underlying system has consumed the data added by the
 * [EventSink] methods.
 *
 * When [EventSink] methods are used, the [done] [Future] can be used to
 * catch any errors.
 *
 * When [close] is called, it will return the [done] [Future].
 */
abstract class StreamSink<S> implements StreamConsumer<S>, EventSink<S> {
  /**
   * Close the [StreamSink]. It'll return the [done] Future.
   */
  Future close();

  /**
   * The [done] Future completes with the same values as [close], except
   * for the following case:
   *
   * * The synchronous methods of [EventSink] were called, resulting in an
   *   error. If there is no active future (like from an addStream call), the
   *   [done] future will complete with that error
   */
  Future get done;
}


/**
 * The target of a [Stream.transform] call.
 *
 * The [Stream.transform] call will pass itself to this object and then return
 * the resulting stream.
 */
abstract class StreamTransformer<S, T> {
  /**
   * Create a [StreamTransformer] that delegates events to the given functions.
   *
   * This is actually a [StreamEventTransformer] where the event handling is
   * performed by the function arguments.
   * If an argument is omitted, it acts as the corresponding default method from
   * [StreamEventTransformer].
   *
   * Example use:
   *
   *     stringStream.transform(new StreamTransformer<String, String>(
   *         handleData: (String value, EventSink<String> sink) {
   *           sink.add(value);
   *           sink.add(value);  // Duplicate the incoming events.
   *         }));
   *
   */
  factory StreamTransformer({
      void handleData(S data, EventSink<T> sink),
      void handleError(error, EventSink<T> sink),
      void handleDone(EventSink<T> sink)}) {
    return new _StreamTransformerImpl<S, T>(handleData,
                                            handleError,
                                            handleDone);
  }

  Stream<T> bind(Stream<S> stream);
}


/**
 * Base class for transformers that modifies stream events.
 *
 * A [StreamEventTransformer] transforms incoming Stream
 * events of one kind into outgoing events of (possibly) another kind.
 *
 * Subscribing on the stream returned by [bind] is the same as subscribing on
 * the source stream, except that events are passed through the [transformer]
 * before being emitted. The transformer may generate any number and
 * types of events for each incoming event. Pauses on the returned
 * subscription are forwarded to this stream.
 *
 * An example that duplicates all data events:
 *
 *     class DoubleTransformer<T> extends StreamEventTransformer<T, T> {
 *       void handleData(T data, EventSink<T> sink) {
 *         sink.add(value);
 *         sink.add(value);
 *       }
 *     }
 *     someTypeStream.transform(new DoubleTransformer<Type>());
 *
 * The default implementations of the "handle" methods forward
 * the events unmodified. If using the default [handleData] the generic type [T]
 * needs to be assignable to [S].
 */
abstract class StreamEventTransformer<S, T> implements StreamTransformer<S, T> {
  const StreamEventTransformer();

  Stream<T> bind(Stream<S> source) {
    return new EventTransformStream<S, T>(source, this);
  }

  /**
   * Act on incoming data event.
   *
   * The method may generate any number of events on the sink, but should
   * not throw.
   */
  void handleData(S event, EventSink<T> sink) {
    var data = event;
    sink.add(data);
  }

  /**
   * Act on incoming error event.
   *
   * The method may generate any number of events on the sink, but should
   * not throw.
   */
  void handleError(error, EventSink<T> sink) {
    sink.addError(error);
  }

  /**
   * Act on incoming done event.
   *
   * The method may generate any number of events on the sink, but should
   * not throw.
   */
  void handleDone(EventSink<T> sink){
    sink.close();
  }
}


/**
 * Stream that transforms another stream by intercepting and replacing events.
 *
 * This [Stream] is a transformation of a source stream. Listening on this
 * stream is the same as listening on the source stream, except that events
 * are intercepted and modified by a [StreamEventTransformer] before becoming
 * events on this stream.
 */
class EventTransformStream<S, T> extends Stream<T> {
  final Stream<S> _source;
  final StreamEventTransformer _transformer;
  EventTransformStream(Stream<S> source,
                       StreamEventTransformer<S, T> transformer)
      : _source = source, _transformer = transformer;

  StreamSubscription<T> listen(void onData(T data),
                               { void onError(error),
                                 void onDone(),
                                 bool cancelOnError }) {
    if (onData == null) onData = _nullDataHandler;
    if (onError == null) onError = _nullErrorHandler;
    if (onDone == null) onDone = _nullDoneHandler;
    cancelOnError = identical(true, cancelOnError);
    return new _EventTransformStreamSubscription(_source, _transformer,
                                                 onData, onError, onDone,
                                                 cancelOnError);
  }
}

class _EventTransformStreamSubscription<S, T>
    extends _BufferingStreamSubscription<T> {
  /** The transformer used to transform events. */
  final StreamEventTransformer<S, T> _transformer;

  /** Whether this stream has sent a done event. */
  bool _isClosed = false;

  /** Source of incoming events. */
  StreamSubscription<S> _subscription;

  /** Cached EventSink wrapper for this class. */
  EventSink<T> _sink;

  _EventTransformStreamSubscription(Stream<S> source,
                                    this._transformer,
                                    void onData(T data),
                                    void onError(error),
                                    void onDone(),
                                    bool cancelOnError)
      : super(onData, onError, onDone, cancelOnError) {
    _sink = new _EventSinkAdapter<T>(this);
    _subscription = source.listen(_handleData,
                                  onError: _handleError,
                                  onDone: _handleDone);
  }

  /** Whether this subscription is still subscribed to its source. */
  bool get _isSubscribed => _subscription != null;

  void _onPause() {
    if (_isSubscribed) _subscription.pause();
  }

  void _onResume() {
    if (_isSubscribed) _subscription.resume();
  }

  void _onCancel() {
    if (_isSubscribed) {
      StreamSubscription subscription = _subscription;
      _subscription = null;
      subscription.cancel();
    }
    _isClosed = true;
  }

  void _handleData(S data) {
    try {
      _transformer.handleData(data, _sink);
    } catch (e, s) {
      _addError(_asyncError(e, s));
    }
  }

  void _handleError(error) {
    try {
      _transformer.handleError(error, _sink);
    } catch (e, s) {
      _addError(_asyncError(e, s));
    }
  }

  void _handleDone() {
    try {
      _subscription = null;
      _transformer.handleDone(_sink);
    } catch (e, s) {
      _addError(_asyncError(e, s));
    }
  }
}

class _EventSinkAdapter<T> implements EventSink<T> {
  _EventSink _sink;
  _EventSinkAdapter(this._sink);

  void add(T data) { _sink._add(data); }
  void addError(error) { _sink._addError(error); }
  void close() { _sink._close(); }
}


/**
 * An [Iterable] like interface for the values of a [Stream].
 *
 * This wraps a [Stream] and a subscription on the stream. It listens
 * on the stream, and completes the future returned by [moveNext] when the
 * next value becomes available.
 *
 * NOTICE: This is a tentative design. This class may change.
 */
abstract class StreamIterator<T> {

  /** Create a [StreamIterator] on [stream]. */
  factory StreamIterator(Stream<T> stream)
      // TODO(lrn): use redirecting factory constructor when type
      // arguments are supported.
      => new _StreamIteratorImpl<T>(stream);

  /**
   * Wait for the next stream value to be available.
   *
   * It is not allowed to call this function again until the future has
   * completed. If the returned future completes with anything except `true`,
   * the iterator is done, and no new value will ever be available.
   *
   * The future may complete with an error, if the stream produces an error.
   */
  Future<bool> moveNext();

  /**
   * The current value of the stream.
   *
   * Only valid when the future returned by [moveNext] completes with `true`
   * as value, and only until the next call to [moveNext].
   */
  T get current;

  /**
   * Cancels the stream iterator (and the underlying stream subscription) early.
   *
   * The stream iterator is automatically canceled if the [moveNext] future
   * completes with either `false` or an error.
   *
   * If a [moveNext] call has been made, it will complete with `false` as value,
   * as will all further calls to [moveNext].
   *
   * If you need to stop listening for values before the stream iterator is
   * automatically closed, you must call [cancel] to ensure that the stream
   * is properly closed.
   */
  void cancel();
}
