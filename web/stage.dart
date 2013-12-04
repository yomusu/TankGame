part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
                 // れんしゅうStage
                 { 'id':'stage0',
                     'speed':3.0,
                     'map':[
                            [ 900, 150, "large" ],
                            [ 500, 150, "large" ],
                            [ 500, 150, "large" ],
                            [ 500, 150, "small" ],
                            [ 500, 150, "small" ],
                            [ 500, 150, "small" ],
                            ]
                   },
   // Stage1
   { 'id':'stage1',
     'speed':3.0,
     'map':[
         [ 900, 200, "large" ],
         [ 400, 270, "small" ],
         [ 400, 130, "large" ],
         [ 250, 150, "small" ],
         [ 350, 260, "large" ],
         [ 250, 100, "small" ],
         [ 250, 270, "large" ],
         [ 300, 150, "small" ],
         [ 250, 100, "large" ],
         [ 200, 150, "small" ],
         [ 180, 100, "small" ],
         // 7連鎖
/*         [ 700, 280, "large" ],
         [ 150, 280, "large" ],
         [ 150, 280, "large" ],
         [ 150, 280, "large" ],
         [ 125, 100, "small" ],
         [ 150, 100, "small" ],
         [ 150, 100, "small" ], // 18
         // 階段
         [ 250, 280, "small" ],
         [ 180, 240, "small" ],
         [ 180, 200, "small" ],
         [ 180, 160, "small" ],
         [ 180, 120, "small" ],
         [ 180,  90, "small" ], // 24
         // ジグザグ
         [ 250,  90, "large" ],
         [ 180, 280, "small" ],
         [ 180,  90, "large" ],
         [ 180, 280, "small" ],
         [ 180,  90, "large" ],
*/         
         [ 250,  50, "small" ],
     ]
   },
];


/**
 * アイテムデータ
 */
List  itemList = [

                  {
                    'id' : "nom001",
                    'obtained' : true,
                    'price' : 0,
                    'cannonSize' : 20,
                    'cannonSpeed' : 6,
                    'text' : "まめ砲弾",
                  },
];

int resultToScore( int hit, int fire, var stage ) {
  
  // 撃墜率
  var Krate = hit / stage['map'].length;
  // 命中率
  var Arate = hit / fire;
  
  print("K=$Krate A=$Arate");
  
  // サーロイン判定
  if( hit==29 && Arate > 0.99 )
    return 80;
  
  if( Krate > 0.99 && Arate > 0.99 ) {
    return 100;
  } else if( Krate > 0.99 && Arate > 0.80 ) {
    return 90;
  } else if( Krate > 0.90 && Arate > 0.80 ) {
    return 70;
  } else if( Krate > 0.85 && Arate > 0.70 ) {
    return 50;
  } else if( Krate > 0.70 && Arate > 0.50 ) {
    return 30;
  }
  
  return 10;
}

String resultToLevelText( int score ) {
  
  var map = {
    100 : "かみさま",
    90 : "たつじん",
    80 : "サーロイン",
    70 : "せんせい",
    50 : "せんぱい",
    30 : "いちねんせい",
    10 : "あかちゃん",
  };
  return map[score];
}

class GamePointManager {
  
  /** 現在保持しているゲームポイント */
  int _point;
  /** Unlockされた要素 */
  HashSet<String> _unlocked = new HashSet();
  
  Map unlockPoints = {
              "stage0" : 0,
              "stage1" : 0,     // ステージ1
              "stage2" : 1000,  // ステージ2
              "stage3" : 5000,  // ステージ3
              "nom001" : 0,     // まめ砲弾
              "big001" : 2000,  // でかい砲弾
              "fast001" : 3000, // 速い砲弾
  };
  
  /** 初期化：読み込み、初期化 */
  void init() {
    if( window.localStorage.containsKey("gamePoint") )
      _point = int.parse( window.localStorage["gamePoint"] );
    else
      _point = 0;
    
    _updateUnlockSet();
  }
  
  int get point => _point;
  
  /** ゲームポイントの追加 */
  bool addPoint( int point ) {
    _point += point;
    window.localStorage["gamePoint"] = "$_point";
    
    // 戻り値は新しくUnlockされた要素があるかどうか
    var oldNumberOfUnlocked = _unlocked.length;
    _updateUnlockSet();
    return _unlocked.length != oldNumberOfUnlocked;
  }
  
  void _updateUnlockSet() {
    unlockPoints.forEach( (key,p) {
      if( _point >= p )
        _unlocked.add( key );
    });
  }
  
  /** 要素がUnlockされているか確認する */
  bool isUnlock( String key ) {
    return _unlocked.contains(key);
  }
  
  void clearPoint() {
    window.localStorage.remove("gamePoint");
  }
}
