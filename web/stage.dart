part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
   // Stage1
   { 'enable':true, 'name':"stage1",
     'speed':3.0, 'length':1900,
     'map':[
         [ 900, 80, "large" ],
         [ 1300, 80, "large" ],
         [ 1700, 80, "small" ],
     ]
   },
   // Stage2
   { 'enable':true, 'name':"stage2",
     'speed':3.0, 'length':2100,
     'map':[
         [ 900, 50, "large" ],
         [ 1100, 150, "small" ],
         [ 1300, 180, "small" ],
         [ 1450, 70, "large" ],
         [ 1610, 200, "small" ],
         [ 1700, 50, "large" ],
         [ 1900, 70, "large" ],
     ]
   },
   // Stage3
   { 'enable':false, 'name':"stage3" },
];


