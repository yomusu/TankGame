part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
   // Stage1
   { 'enable':true, 'name':"stage1",
     'speed':3.0, 'length':1200,
     'map':[
         [ 600, 50, "large" ],
         [ 800, 50, "large" ],
         [ 1000, 50, "small" ],
     ]
   },
   // Stage2
   { 'enable':true, 'name':"stage2",
     'speed':3.0, 'length':1300,
     'map':[
         [ 600, 50, "large" ],
         [ 700, 150, "small" ],
         [ 800, 180, "small" ],
         [ 850, 70, "large" ],
         [ 910, 200, "small" ],
         [ 1000, 50, "large" ],
         [ 1100, 70, "large" ],
     ]
   },
   // Stage3
   { 'enable':false, 'name':"stage3" },
];


