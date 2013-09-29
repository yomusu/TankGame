part of geng;

class FrameTimer {
  
  Stopwatch _watch = new Stopwatch();
  var callback;
  
  var targetTime;
  
  int _duration;

  void start( Duration time, void callback() ) {
    _duration = time.inMicroseconds;
    this.callback = callback;
    
    _watch.start();
    targetTime = _watch.elapsedMicroseconds;
    Timer.run( ()=>next() );
  }
  
  void next() {
    
    if( _watch==null )
      return;
    
    callback();
    
    // 次のフレーム実行時刻
    targetTime += _duration;
    var now = _watch.elapsedMicroseconds;
    var wait = targetTime - now;
//    print("wait=$wait  on ${_watch.elapsedMicroseconds}");
    new Timer( new Duration(microseconds:wait) , ()=>next() );
  }
  
  void dispose() {
    if( _watch!=null ) {
      _watch.stop();
      _watch = null;
    }
  }
}


/**
 * FPSカウンター
 */
class FPSCounter {
  
  Stopwatch _watch = new Stopwatch();
  
  var _total = 0;
  var _fcount = 0;
  var _startTime = 0;
  
  var _lastTimeForSecond = 0;
  
  /** 最新のFPS */
  int lastFPS = 0;
  /** 最新のフレーム処理時間(最後の秒からの平均) */
  int lastAvgFrameDuration = 0;
  
  
  void init() {
    _watch.start();
  }
  
  void dispose() {
    _watch.stop();
    _watch == null;
  }
  
  void open() {
    _startTime = _watch.elapsedMicroseconds;
  }
  
  void shut() {
    _total += _watch.elapsedMicroseconds - _startTime;
    _fcount++;
    
    if( (_watch.elapsedMilliseconds - _lastTimeForSecond) >= 1000 ) {
      _lastTimeForSecond += 1000;
      
      lastFPS = _fcount;
      lastAvgFrameDuration = _total ~/_fcount;
      
//      print( "$lastFPS fps ( $lastAvgFrameDuration us/f) on ${_watch.elapsedMilliseconds}" );
//      print( "$lastFPS fps ( ${_total/1000}ms on ${_watch.elapsedMilliseconds}" );
      
      _total = 0;
      _fcount = 0;
    }
  }
  
}


/**
 * Retinaディスプレイかどうか
 */
bool isRetina() {
  var ratio = window.devicePixelRatio;
  return (ratio==2);
}

/**
 * スマホかどうか
 */
bool isMobileDevice() {
  var ua = window.navigator.userAgent;
  bool  isAndroid = ua.indexOf("Android") >= 0;
  bool  isiPod = ua.indexOf("iPod") >= 0;
  bool  isiPhone = ua.indexOf("iPhone") >= 0;
  bool  isiPad = ua.indexOf("iPad") >= 0;
  return isAndroid || isiPod || isiPhone || isiPad;
}

void delay( int milliseconds,  void callback() ) {
  new Timer( new Duration(milliseconds:milliseconds), callback );
}



