// --- 全域同步 ---
BluesKit.mout @=> MidiOut mout; 
BluesKit.msg @=> MidiMsg msg[];

BluesKit.KEY => int key; 
1::minute / BluesKit.BPM => dur quarter;
BluesKit.blues @=> int blues[];                 //藍調音階 1, b3, 4, b5, 5, b7
BluesKit.progression @=> string progression[];  //和弦進行

[0, 0, 0, 0, 0, 0] @=> int scale[]; 
//(quarter * 4) => dur barLen; // 一小節的長度

// --- 1. 伴奏軌 (The Comping Piano) ---
fun void playChords() {

    //調整Key
    for( 0 => int step; step < blues.size(); step++ ) {
       key + blues[step] => scale[step];        
    }

    //quarter * 0.025 => now;  // 節奏偏移 (Quantize Offset)
    for( 0 => int i; i < progression.size(); i++ ) {
        progression[i] => string chordType;
        int root;
        i % 2 => int bar;   //奇偶小節
        
        // 根據調性與和弦類型決定根音偏移
        if( chordType == "I7" ) scale[0] => root;       // C7
        else if( chordType == "IV7" ) scale[2] => root; // F7
        else if( chordType == "V7" ) scale[4] => root;  // G7

        // 設定音高：彈奏一個屬七和弦 (Root, 3rd, 5th, 7th)
        root + 0 => msg[0].data2;                            // Root   
        root + 4 => msg[1].data2;                            // 3rd
        root + 7 => msg[2].data2;                            // 5th
        root + 10 => msg[3].data2;                           // 7th

        // 設定音量 (Root, 3rd, 5th, 7th)
        BluesKit.VOL => msg[0].data3;                            // Root   
        BluesKit.VOL => msg[1].data3;                            // 3rd
        BluesKit.VOL => msg[2].data3;                            // 5th
        BluesKit.VOL => msg[3].data3;                            // 7th

        /*
        Std.mtof(root - 24) => chordSynth[0].freq;                           // C1   
        Std.mtof(root + 4) => chordSynth[1].freq;                            // C3
        if( chordType == 1 ) Std.mtof(root + 2) => chordSynth[2].freq;       // C9
        else if( chordType == 4 ) Std.mtof(root + 9) => chordSynth[2].freq;  // F13
        else if( chordType == 5 ) Std.mtof(root + 9) => chordSynth[2].freq;  // G13
        if( chordType == 1 ) Std.mtof(root + 10) => chordSynth[3].freq;      // C7
        else if( chordType == 4 ) Std.mtof(root - 2) => chordSynth[3].freq;  // F7
        else if( chordType == 5 ) Std.mtof(root - 2) => chordSynth[3].freq;  // G7
        */
        
        /*Chicks Strumming
        quarter => now; // 休止一拍
        chordSynth[0].gain() => chordSynth[0].noteOn;
        chordSynth[1].gain() => chordSynth[1].noteOn;
        chordSynth[2].gain() => chordSynth[2].noteOn;
        chordSynth[3].gain() => chordSynth[3].noteOn;
        quarter * 0.9 => now; // 持續一拍
        chordSynth[0].noteOff;
        chordSynth[1].noteOff;
        chordSynth[2].noteOff;
        chordSynth[3].noteOff;
        quarter * 0.1 => now; // 留白呼吸
        quarter => now; // 休止一拍
        chordSynth[0].gain() => chordSynth[0].noteOn;
        chordSynth[1].gain() => chordSynth[1].noteOn;
        chordSynth[2].gain() => chordSynth[2].noteOn;
        chordSynth[3].gain() => chordSynth[3].noteOn;
        quarter * 0.9 => now; // 持續一拍
        chordSynth[0].noteOff;
        chordSynth[1].noteOff;
        chordSynth[2].noteOff;
        chordSynth[3].noteOff;
        quarter * 0.1 => now; // 留白呼吸
        */
        
        //Comping Strumming
            // data1=144=1001 0000, 1001=Note On,  0000=Chan 1st
            // data1=128=1000 0000, 1000=Note Off, 0000=Chan 1st
        if (i < (progression.size() - 2) && bar == 0)
        {   
            quarter * 0.5 => now;   // 休止0.5拍

            145 => msg[1].data1;    mout.send(msg[1]);
            147 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.45 => now;  // 持續0.5拍
            129 => msg[1].data1;    mout.send(msg[1]);
            131 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.05 => now;  // 留白呼吸

            quarter => now;         // 休止1.0拍

            145 => msg[1].data1;    mout.send(msg[1]);
            147 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.9 => now;   // 持續1.0拍
            129 => msg[1].data1;    mout.send(msg[1]);
            131 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.1 => now;   // 留白呼吸

            quarter => now;         // 休止1.0拍
        } else if (i < (progression.size() - 2) && bar == 1)
        {   
            145 => msg[1].data1;    mout.send(msg[1]);
            147 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.9 => now;   // 持續1.0拍
            129 => msg[1].data1;    mout.send(msg[1]);
            131 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.1 => now;   // 留白呼吸
            
            quarter * 0.5 => now;   // 休止0.5拍
            
            145 => msg[1].data1;    mout.send(msg[1]);
            147 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.45 => now;  // 持續0.5拍
            129 => msg[1].data1;    mout.send(msg[1]);
            131 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.05 => now;  // 留白呼吸
            
            quarter * 2.0 => now;   // 休止2.0拍
        } else if (i == (progression.size() - 2)) // End the song
        {   
            // 11 bar
            root + 0 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.45 => now;   // 持續0.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.05 => now;   // 留白呼吸

            root + 4 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 1.35 => now;   // 持續1.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.15 => now;   // 留白呼吸

            root + 5 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.9 => now;    // 持續1.0拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.1 => now;    // 留白呼吸

            root + 6 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.9 => now;    // 持續1.0拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.1 => now;    // 留白呼吸
        } else if (i == (progression.size() - 1)) // End the song
        {   
            // 12 bar
            root + 7 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.45 => now;   // 持續0.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.05 => now;   // 留白呼吸
            root + 9 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.45 => now;   // 持續0.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.05 => now;   // 留白呼吸
            root + 11 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.45 => now;   // 持續0.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.05 => now;   // 留白呼吸
            root + 12 => msg[0].data2;   // Root
            144 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.45 => now;   // 持續0.5拍
            128 => msg[0].data1;    mout.send(msg[0]);
            quarter * 0.05 => now;   // 留白呼吸
            quarter => now;          // 休止1.0拍
            
            root + 4 => msg[1].data2;                            // 3rd
            root + 7 => msg[2].data2;                            // 5th
            root + 10 => msg[3].data2;                           // 7th
            145 => msg[1].data1;    mout.send(msg[1]);
            146 => msg[2].data1;    mout.send(msg[2]);
            147 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.9 => now;    // 持續1.0拍
            129 => msg[1].data1;    mout.send(msg[1]);
            130 => msg[2].data1;    mout.send(msg[2]);
            131 => msg[3].data1;    mout.send(msg[3]);
            quarter * 0.1 => now;    // 留白呼吸
        }
    }
}

// --- 啟動 ---
playChords(); // 啟動伴奏

