library sound;

import 'dart:html';
import 'dart:async';
import 'dart:web_audio';


/**
 * サウンドを管理を行うクラス
 * サウンドはAudioContextを扱えるブラウザのみ対応です。
 * 現在はWebKitベースのChromeとSafariのみ。
 */
class SoundManager {
  
  AudioContext _audioContext = null;
  GainNode _gainNode = null;
  
  Map<String,AudioBuffer> _map = new Map();
  
  /** サウンドを有効にするかどうか */
  bool  soundOn = false;
  /** BrowserがAudioサポートしているかどうか */
  bool  get isSupport => _audioContext!=null;
  
  SoundManager() {
    try {
      _audioContext = new AudioContext();
      _gainNode = _audioContext.createGain();
      _gainNode.connectNode(_audioContext.destination, 0, 0);
    } catch( e ) {
      print("SoundManager : This browser is unsupported AudioContext.");
    }
  }
  
  /**
   * サウンドファイルを読み込む
   */
  Future<String> put( String key, String filename ) {
    
    var comp = new Completer();
    
    if( _audioContext!=null ) {
      // 対応ブラウザの場合、読み込み
      HttpRequest xhr = new HttpRequest()
      ..open("GET", filename)
      ..responseType = "arraybuffer";
    
      xhr.onLoad.listen((e) {
        // 音声データのデコード
        _audioContext.decodeAudioData(xhr.response)
          .then( (AudioBuffer buffer) {
            _map[key] = buffer;
            print("loaded ${filename}");
            comp.complete(key);
          })
            .catchError( (error) {
              comp.completeError(error);
            });
      });
      xhr.onError.listen((e)=> comp.completeError(e));
      xhr.send();
      
    } else {
      // 非対応ブラウザの場合、無視
      Timer.run( (){ comp.complete(key); } );
    }
    return comp.future;
  }
  
  /**
   * サウンドを再生する
   */
  void play( String key ) {
    if( soundOn && isSupport ) {
      AudioBufferSourceNode source = _audioContext.createBufferSource()
          ..connectNode(_gainNode, 0, 0)
            ..buffer = _map[key]
      ..start(0);
    }
  }
}

