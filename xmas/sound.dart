library sound;

import 'dart:html';
import 'dart:async';


/**
 * サウンドを管理を行うクラス
 * サウンドはAudioContextを扱えるブラウザのみ対応です。
 * 現在はWebKitベースのChromeとSafariのみ。
 */
class SoundManager {
  
  Map<String,AudioElement> _map = new Map();
  
  /** サウンドを有効にするかどうか */
  bool  soundOn = false;
  /** BrowserがAudioサポートしているかどうか */
  bool  get isSupport => mediaType!=null;
  
  String  mediaType = null;
  
  SoundManager() {
    
    RegExp  exp = new RegExp(r"(probably|maybe)");
    
    AudioElement  a = new AudioElement("");
    if( exp.hasMatch(a.canPlayType("audio/ogg")) )
      mediaType = "ogg";
    else if( exp.hasMatch(a.canPlayType("audio/mp3")) )
      mediaType = "mp3";
    
    print("SoundMediaType is $mediaType");
  }
  
  /**
   * サウンドファイルを読み込む
   */
  Future<String> put( String key, String filename ) {
    
    filename = "$filename.$mediaType";
    var comp = new Completer();
    
    AudioElement  audio = new AudioElement(filename);
    audio.onLoadedData.listen( (e){
      print("loaded ${filename}");
      comp.complete(key);
    }, onError: (e) {
      comp.completeError(e);
    });
    _map[key] = audio;
    
    return comp.future;
  }
  
  /**
   * サウンドを再生する
   */
  void play( String key ) {
    if( soundOn && isSupport ) {
      _map[key].play();
    }
  }
}

