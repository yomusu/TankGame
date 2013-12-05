part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
                 // れんしゅうStage
                 { 'id':'stage0',
                     'speed':3.0,
                     'map':[
                            [ 900, 180, "large" ],
                            [ 500, 180, "large" ],
                            [ 500, 180, "large" ],
                            [ 500, 180, "small" ],
                            [ 500, 180, "small" ],
                            [ 500, 180, "small" ],
                            ]
                   },
   // Stage1
   { 'id':'stage1',
     'speed':3.0,
     'map':[
         [ 900, 200, "large" ],
         [ 400, 270, "small" ],
         [ 400, 150, "large" ],
         [ 250, 180, "small" ],
         [ 350, 260, "large" ],
         [ 250, 200, "small" ],
         [ 250, 270, "large" ],
         [ 300, 180, "small" ],
         [ 250, 130, "large" ],
         [ 200, 170, "small" ],
         [ 180, 130, "large" ], // 11
         // 階段
         [ 350, 280, "small" ],
         [ 180, 240, "small" ],
         [ 180, 200, "small" ],
         [ 180, 160, "small" ],
         [ 180, 120, "small" ], // 16
         // ジグザグ
         [ 300,  90, "large" ],
         [ 180, 280, "small" ],
         [ 180,  90, "large" ],
         [ 180, 280, "small" ],
         [ 180,  90, "large" ], // 21
         // 7連鎖
         [ 700, 280, "large" ],
         [ 150, 280, "large" ],
         [ 150, 280, "large" ],
         [ 150, 280, "large" ],
         [ 150, 100, "small" ],
         [ 150, 100, "small" ],
         [ 150, 100, "small" ], // 28
         // 最後の難関
         [ 450,  50, "small" ],
         [ 150,  50, "small" ],
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


class XMasSaveData {
  
  static const _RankKey = "rankkey";
  static const _HiScoreKey = "hiscorekey";
  
  List<XMasScore> hiscores;
  Map<String,XMasScore>  rankHistory;
  
  void build() {
    // ハイスコア
    hiscores = [];
    if( window.localStorage.containsKey(_HiScoreKey) ) {
      try {
        String  json = window.localStorage[_HiScoreKey];
        (JSON.decode(json) as List).forEach( (v) {
          hiscores.add( new XMasScore.fromMap(v) );
        });
      } catch(e) {
        print("HiScoreData had been broken. $e");
      }
    } else {
      print("HiScoreData is nothing.");
    }
    // ランクデータ
    rankHistory = {};
    if( window.localStorage.containsKey(_RankKey) ) {
      try {
        String  json = window.localStorage[_RankKey];
        JSON.decode(json).forEach( (k,v) {
          rankHistory[k] = new XMasScore.fromMap(v);
        });
      } catch(e) {
        print("RankData had been broken. $e");
      }
    } else {
      print("RankData is nothing.");
    }
  }
  
  void allClear() {
    window.localStorage.remove(_HiScoreKey);
    window.localStorage.remove(_RankKey);
    build();
  }
  
  List getHiScores() => hiscores;
  
  XMasScore getRank( String rank ) => rankHistory[rank];
  
  void putAndWrite( XMasScore score ) {
    
    // ハイスコアに登録
    hiscores.add(score);
    hiscores.sort( (l,r) {
      var chit = l.hit.compareTo(r.hit) * -1; // 大きい順
      var cfire= l._fire.compareTo(r._fire);  // 小さい順
      var cdate= l._datetime.compareTo(r._datetime) * -1; // 大きい順
      if( chit!=0 ) return chit;
      if( cfire!=0 ) return cfire;
      return cdate;
    });
    // 保存するのは最大10個
    hiscores = hiscores.take(10).toList(growable:true);
    // 書き込み
    window.localStorage[_HiScoreKey] = JSON.encode(hiscores);
    
    // 取得ランクに記録
    rankHistory[score.rank] = score;
    window.localStorage[_RankKey] = JSON.encode(rankHistory);
  }
  
}

class XMasScore {
  
  static const RANK01 = "rank01";
  static const RANK02 = "rank02";
  static const RANK03 = "rank03";
  static const RANK04 = "rank04";
  static const RANK05 = "rank05";
  static const RANK06 = "rank06";
  static const RANK07 = "rank07";
  
  static Map  _rankToText =
    {
     RANK01 : "かみさま",
     RANK02 : "サーロイン",
     RANK03 : "たつじん",
     RANK04 : "せんせい",
     RANK05 : "せんぱい",
     RANK06 : "いちねんせい",
     RANK07 : "あかちゃん",
    };
  
  static String rankToText( var rank ) => _rankToText[rank];
  
  final int hit;
  int _fire;
  int _stageLength;
  String _stageID;
  DateTime  _datetime;
  
  DateTime get datetime => _datetime;
  
  bool get isPerfect => hit==30;
  
  String get rankText => rankToText(rank);
  
  String get rank {
    if( hit==30 ) return RANK01;
    if( hit==29 ) return RANK02;
    if( hit >= 27 ) return RANK03;
    if( hit >= 25 ) return RANK04;
    if( hit >= 20 ) return RANK05;
    if( hit >= 15 ) return RANK06;
    return RANK07;
  }
  
  XMasScore.create( int hit, int fire, var stage ) :
    hit = hit
  {
    _fire = fire;
    _stageLength = stage["map"].length;
    _stageID = stage['id'];
    _datetime = new DateTime.now();
  }
  
  XMasScore.fromMap( Map map ) :
    hit = map["hit"]
  {
    _fire= map["fire"];
    _stageLength = map["stagelength"];
    _stageID = map['stageid'];
    _datetime = new DateTime.fromMillisecondsSinceEpoch( map["datetime"], isUtc:true ).toLocal();
  }
  
  Map toJson() {
    return {
      "hit" : hit,
      "fire" : _fire,
      "stagelength" : _stageLength,
      "stageid" : _stageID,
      "datetime" : _datetime.toUtc().millisecondsSinceEpoch,
    };
  }
}
