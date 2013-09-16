library geng;

import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:web_audio';
import 'dart:convert';

part 'sprite.dart';
part 'canvasutil.dart';

final String  fontFamily = '"ヒラギノ角ゴ Pro W3", "Hiragino Kaku Gothic Pro", Meiryo, "メイリオ", "ＭＳ Ｐゴシック", Verdana, Geneva, Arial, Helvetica';

/**
 * 物体ひとつ
 * 定義は…
 */
abstract class GObj {
  
  /** 廃棄済みフラグ */
  bool  _isDisposed = false;
  
  /** Disposeされたかどうか */
  bool get isDisposed => _isDisposed;
  
  // オーバーライドすべきメソッド ---
  
  /** 最初に呼ばれる */
  void onInit();
  
  /** レンダリング */
  void onProcess( RenderList renderList );
  
  /** 最後に呼ばれる */
  void onDispose();
  
  // 操作するためのメソッド ---
  
  void process( RenderList renderList ) => onProcess( renderList );
  
  /** 廃棄する */
  void dispose() {
    onDispose();
    // 次回のrenderで削除
    _isDisposed = true;
  }
}


DefaultButtonRender  defaultButtonRenderer = new DefaultButtonRender();

typedef void ButtonRenderer( GCanvas2D canvas, GButton btn );

class GButton extends GObj {
  
  static const int  HIDDEN = -1;
  static const int  DISABLE= 0;
  static const int  ACTIVE = 1;
  static const int  ROLLON = 3;
  static const int  PRESSED= 7;
  
  // member properties ----
  
  num x;
  num y;
  num width;
  num height;
  
  /** Z値 */
  num z = 1000;
  
  // getter properties ----
  
  num get left => x - (width/2);
  num get top  => y - (height/2);
  
  int get status {
    
    if( isVisible==false )
      return HIDDEN;
    if( isEnable==false )
      return DISABLE;
    
    if( isPress )
      return PRESSED;
    if( isOn )
      return ROLLON;
    
    return ACTIVE;
  }
  
  
  var onPress = null;
  var onRelease = null;
  
  bool  isOn = false;
  bool  isPress = false;
  bool  isVisible = true;
  bool  isEnable = true;
  
  String  text;
  
  /** ボタンレンダラ:差し替え可能 */
  ButtonRenderer renderer = defaultButtonRenderer.render;
  
  
  /** Default Constructor */
  GButton({this.text:null, this.x:320, this.y:180, this.width:100, this.height:50});
  
  
  bool isIn( num mx, num my ) {
    
    if( isVisible==false )
      return false;
    if( isEnable==false )
      return false;
    
    var xx = mx - left;
    var yy = my - top;
    bool  inH = ( xx>=0 && xx<width );
    bool  inV = ( yy>=0 && yy<height);
    
    return ( inH && inV );
  }
  
  void onInit(){}
  
  void onProcess( RenderList renderList ) {
    var s = status;
    if( s!=HIDDEN )
      renderList.add(z, (c)=>renderer(c,this) );
  }
  
  void onDispose(){}
}

/**
 * ボタンリスト
 * ボタンっていうか入力デバイスをハンドルするオブジェクト
 */
class ButtonList {
  
  /** List of Buttons */ 
  List<GButton>  _btnList = null;

  void add( GButton btn ) {
    if( _btnList==null )
      _btnList = new List();
    _btnList.add( btn );
  }
  
  /** entryされたボタンすべてに対しPress処理をする */
  void onPress(PressEvent e) {
    if( _btnList!=null ) {
      _btnList.where( (b) => b.isPress==false )
        .forEach( (GButton b) {
          if( b.isIn( e.x, e.y ) ) {
            b.isPress = true;
            if( b.onPress!=null )
              b.onPress();
          }
        });
    }
  }
  
  /** entryされたボタンすべてに対しPress処理をする */
  void onRelease(PressEvent e) {
    if( _btnList!=null ) {
      _btnList.where( (b) => b.isPress )
        .forEach( (GButton b) {
          if( b.onRelease!=null ) {
            b.onRelease();
            b.isPress = false;
          }
        });
    }
  }
  
  /** entryされたボタンすべてに対しMove処理をする */
  void onMouseMove( int x, int y ) {
    if( _btnList!=null ) {
      _btnList.where( (b) => b.isPress==false )
        .forEach( (GButton b) {
          b.isOn = b.isIn( x, y );
        });
    }
  }
  
}

/**
 * 画面の基本クラス
 */
abstract class GScreen {
  
  /** レンダリングリスト */
  final RenderList  _renderList = new RenderList();

  // メンバ変数 ---
  
  /** List of Buttons */ 
  ButtonList  btnList = new ButtonList();
  
  /** 毎フレームの処理 */
  var onProcess = null;
  /** 最前面描画 */
  var onFrontRender = null;
  
  /** 入力デバイスのプレスイベント */
  void onPress( PressEvent e ) => btnList.onPress(e);
  void onRelease( PressEvent e ) => btnList.onRelease(e);
  void onMove( int x, int y ) => btnList.onMouseMove(x, y);
  var onMoveOut = null;
  
  
  // オーバーライドすべきメソッド ---

  /** スタート処理:You can override this method. */
  void onStart();
  
  
  // オーバーライドしなくてよいメソッド ---
  
  /** フレームのTimerハンドル */
  void onTimer() {
    
    // 毎フレームの処理
    if( onProcess!=null )
      onProcess();
    
    // Do Processing every object
    geng.objlist.processAll(_renderList);
      
    // Do Rendering
    geng.backcanvas.context2D.setFillColorRgb(255, 255, 255, 1.0);
    geng.backcanvas.context2D.fillRect(0,0, geng.rect.width, geng.rect.height);
    _renderList.renderAll( geng.backcanvas );
    
    // 終わったら削除
    _renderList.clear();
    geng.objlist.gcObj();
    
    // 最前面の描画
    if( onFrontRender!=null ) {
      g2d.canvas = geng.backcanvas;
      onFrontRender( g2d );
      g2d.canvas = null;
    }
    
    // ダブルバッファのフリップ
    geng.flipBuffer();
  }
  
}

/**
 * フィールドのPressイベント
 */
class PressEvent {
  int x,y;
}

/** 最終的にレンダリングするFunction */
typedef void Render( GCanvas2D canvas );

/**
 * レンダリングのオーダリングリスト
 */
class RenderList {
  
  final SplayTreeMap<num,Render>  _list;
  
  RenderList() :
    _list = new SplayTreeMap( (k1,k2) {
      var r = k1.compareTo(k2);
      return ( r==0 ) ? 1 : r;
    });
  
  void clear() {
    _list.clear();
  }
  void add( num z, Render r ) {
    _list[z] = r;
  }
  
  void renderAll( CanvasElement canvas ) {
    g2d.canvas = canvas;
    _list.values.forEach( (r)=> r(g2d) );
    g2d.canvas = null;
  }
}

/****
 * 
 * Imageを読み込み、格納する
 * 
 */
class ImageMap {
  
  final Map<String,ImageElement>  map = new Map();
  
  void put( String key, String src ) {
    var img = new ImageElement()
    ..src = src;
    
    map[key] = img;
    
    // onLoadは効くのか？読み込み完了を待つ必要があるかどうか
    img.onLoad.listen( (v)=>print("loaded image : $key") ); 
  }
  
  ImageElement operator [](Object key) => map[key];
  
  void operator []=(String k, ImageElement v) {
    map[k] = v;
  }
  
}

class GObjList {
  
  /** 追加オブジェクトのバッファ */
  final List<GObj>  _addObjlist = new List();
  
  /** オブジェクトのリスト */
  final List<GObj>  objlist = new List();
  
  
  /**
   * DisposeされたGObjを廃棄する
   */
  void gcObj() {
    objlist.removeWhere( (v) => v.isDisposed );
  }
  
  /**
   * Objの追加
   */
  void add( GObj obj ) {
    _addObjlist.add(obj);
    obj.onInit();
  }
  
  /**
   * Objを全て破棄する
   */
  void disposeAll() {
    gcObj();
    objlist.forEach( (o)=>o.dispose() );
    gcObj();
    objlist.clear();
  }
  
  /**
   * 全てのオブジェクトをProcessしてrenderする
   */
  void processAll( RenderList renderList ) {
    
    // 追加オブジェクトリストを本物のリストに追加
    objlist.addAll( _addObjlist );
    _addObjlist.clear();
    
    // Do Processing every object
    where().forEach( (GObj v)=> v.process(renderList) );
    
  }
  
  Iterable<GObj> where( [bool test(GObj obj)] ) {
    var r = objlist.where( (e) => e.isDisposed==false );
    if( test!=null )
      return r.where( (e)=>test(e) );
    return r;
  }
}


/**************
 * 
 * Game Engine
 * 
 */
class GEng {
  
  // Private Member --------
  
  GScreen _screen = null;
  Rect  _rect;
  
  // Property --------
  
  GObjList  objlist = new GObjList();
  
  // フィールド管理は別クラスにすべきかも
  CanvasElement  canvas = null;
  CanvasElement  backcanvas = null;
  
  final ImageMap  imageMap = new ImageMap();
  final SoundManager soundManager = new SoundManager();
  final HiScoreManager  hiscoreManager = new HiScoreManager();
  
  // setter/getter --------
  
  /** 使用するScreenのセット */
  set screen( GScreen s ) {
    Timer.run( () {
      _screen = s;
      if( s!=null )
        s.onStart();
    });
  }
  
  /** フィールドの大きさ */
  Rect get rect {
    if( _rect==null ) {
      var w = canvas.clientWidth;
      var h = canvas.clientHeight;
      _rect = new Rect(0,0,w,h);
    }
    return _rect;
  }
  
  
  
  
  
  /**
   * フィールドを初期化する
   */
  void initField( { int width, int height }) {
    
    if( isRetina() ) {
      
      // for Retina対応
      canvas = new CanvasElement( width:width*2, height:height*2 );
      canvas.style
        ..width = "${width}px"
        ..height= "${height}px";
      canvas.context2D.scale(2.0, 2.0);
      
      backcanvas = canvas;
      
    } else {
      canvas = new CanvasElement( width:width, height:height );
      backcanvas = new CanvasElement( width:width, height:height );
    }
    
    
    // MouseDownからPressイベントを転送
    canvas.onMouseDown.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onPress!=null ) {
        e.preventDefault();
        var event = new PressEvent()
        ..x = e.client.x - geng.canvas.offsetLeft
        ..y = e.client.y - geng.canvas.offsetTop;
        _screen.onPress(event);
      }
    });
    canvas.onMouseUp.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onPress!=null ) {
        e.preventDefault();
        var event = new PressEvent()
        ..x = e.client.x - geng.canvas.offsetLeft
        ..y = e.client.y - geng.canvas.offsetTop;
        _screen.onRelease(event);
      }
    });
    canvas.onMouseMove.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onMove!=null ) {
        var x = e.client.x - geng.canvas.offsetLeft;
        var y = e.client.y - geng.canvas.offsetTop;
        _screen.onMove( x, y );
      }
    });
    canvas.onMouseOut.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onMoveOut!=null )
        _screen.onMoveOut();
    });
    canvas.onTouchStart.listen( (TouchEvent e) {
      if( _screen!=null && _screen.onPress!=null ) {
        e.preventDefault();
        var event = new PressEvent()
        ..x = e.touches[0].client.x - geng.canvas.offsetLeft
        ..y = e.touches[0].client.y - geng.canvas.offsetTop;
        _screen.onPress(event);
      }
    });
    
    geng.canvas = canvas;
  }
  
  void flipBuffer() {
    if( isRetina()==false )
      canvas.context2D.drawImage( backcanvas, 0, 0 );
  }
  
  FrameTimer frameWatch = new FrameTimer();
  var cpucnt = new FPSCounter();
  
  /**
   * フレームタイマーをスタートする
   */
  void startTimer() {
    
    cpucnt.init();
    frameWatch.start( const Duration(milliseconds:20), () {
      // フレームの処理
      cpucnt.open();
      
      if( _screen!=null ) {
        _screen.onTimer();
      }
      
      cpucnt.shut();
    });
  }
  
  /**
   * フレームタイマーを停止する
   */
  void stopTimer() {
    frameWatch.dispose();
    cpucnt.dispose();
  }
  
  
  math.Random  rand = new math.Random(3000);
  
  num randRange( num n1, num n2 ) {
    var r = rand.nextDouble();
    return (n1*r) + (n2*(1.0-r));
  }
}

GEng geng = new GEng();


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
      lastAvgFrameDuration = (_total/_fcount).toInt();
      
//      print( "$lastFPS fps ( $lastAvgFrameDuration us/f) on ${_watch.elapsedMilliseconds}" );
      print( "$lastFPS fps ( ${_total/1000}ms on ${_watch.elapsedMilliseconds}" );
      
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

class SoundManager {
  
  AudioContext audioContext = new AudioContext();
  GainNode gainNode = null;
  
  Map<String,AudioBuffer> map = new Map();
  
  
  bool  soundOn = false;
  
  SoundManager() {
    gainNode = audioContext.createGain();
    gainNode.connectNode(audioContext.destination, 0, 0);
  }
  
  Future<String> put( String key, String filename ) {
    
    var comp = new Completer();
    
    HttpRequest xhr = new HttpRequest()
      ..open("GET", filename)
      ..responseType = "arraybuffer";
    
    xhr.onLoad.listen((e) {
      // 音声データのデコード
      audioContext.decodeAudioData(xhr.response)
      .then( (AudioBuffer buffer) {
          map[key] = buffer;
          print("loaded ${filename}");
          comp.complete(key);
      })
      .catchError( (error) {
        comp.completeError(error);
      });
    });
    xhr.onError.listen((e)=> comp.completeError(e));
    xhr.send();
    return comp.future;
  }
  
  void play( String key ) {
    if( soundOn ) {
      AudioBufferSourceNode source = audioContext.createBufferSource()
          ..connectNode(gainNode, 0, 0)
            ..buffer = map[key]
      ..start(0);
    }
  }
}


void delay( int milliseconds,  void callback() ) {
  new Timer( new Duration(milliseconds:milliseconds), callback );
}



/**
 * ハイスコア管理
 * 
 */
class HiScoreManager {
  
  Map<String,List<int>> _scoresMap;
  
  /** 各スコアの最大登録数 */
  int maxLength = 5;

  /**
   * データの読み込み、もしくは初期化
   */
  void init() {
    
    if( window.localStorage.containsKey("hiscore") ) {
      // LocalStorageから読み込み
      var savedData = window.localStorage["hiscore"];
      _scoresMap = new JsonDecoder(null).convert( savedData );
    } else {
      // 初期設定
      _scoresMap = {};
    }
  }
  
  /**
   * 指定した種類のハイスコアを取得します。読み取り専用です
   */
  List<String> getScoreTexts( String kind ) {
    var list = (_scoresMap.containsKey(kind)) ? _scoresMap[kind] : defaultScores;
    return list.map((e)=>e.toString()).toList(growable:false);
  }
  
  var defaultScores=[ 500, 400, 300, 200, 100 ]; 
  /**
   * 新しいスコアを登録する
   * 戻りは登録された順位です（0始まり）
   * ランク外ならthrowされます
   */
  int addNewRecord( String kind, int newScore ) {
    
    // なかったらデフォルトハイスコアで初期化する
    if( _scoresMap.containsKey(kind)==false )
      _scoresMap[kind] = defaultScores;
    
    var _list = _scoresMap[kind];
    
    for( int i=0; i<_list.length; i++ ) {
      if( newScore > _list[i] ) {
        // 追加
        _list.insert( i, newScore );
        // はみ出した分を削除する
        if( _list.length > maxLength )
          _list.removeRange(maxLength, _list.length);
        // callback
        writeData();
        
        return i;
      }
    }
    
    throw "out of ranking";
  }
  
  /**
   * ハイスコアを永続化します。
   * 普通はaddNewRecordされる度に自動で呼ばれます
   */
  void writeData() {
    var stringfy = new JsonEncoder().convert( _scoresMap );
    window.localStorage["hiscore"] = stringfy;
  }
  
  /**
   * ハイスコアデータをクリアします
   */
  void allClear() {
    window.localStorage.remove("hiscore");
    init();
  }
}

