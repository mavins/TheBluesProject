// --- 全域同步設定 ---


BluesKit.KEY => int key; 
1::minute / BluesKit.BPM => dur quarter;
BluesKit.blues @=> int blues[];                 //藍調音階 1, b3, 4, b5, 5, b7
BluesKit.progression @=> string progression[];  //和弦進行

[0, 0, 0, 0, 0, 0] @=> int scale[]; 
//quarter * 4 => dur barLen; // 一小節的長度
//barLen * 12 => dur songLen; // 12barblues 全曲長
//0.0::second => dur leadLen;
//0.0::second => dur respLen;

int call[progression.size()][8];
dur length[progression.size()][8];
int velocity[progression.size()][8];

// --- 1. 旋律軌 (The Lead Soloist) ---
fun void compose() {  
    //調Key
    for( 0 => int step; step < blues.size(); step++ ) {
       key + blues[step] => scale[step];        
    }

    //藍調化(1)：隨機音符長度
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            // Sound:Rest Ratio
            if (Math.random2(0, 2) == 0) // 1:2
            {    
                //sound
                0.5 * quarter => length[bar][half_beat]; //1/8拍
            }
            else
            {
                //rest
                0.0 * quarter => length[bar][half_beat]; //1/8休止
                half_beat => int pos;  //目前位置
                while ( pos > 0 && length[bar][pos] == 0.0::second )
                {
                  pos--;  
                }    
                0.5 * quarter + length[bar][pos] => length[bar][pos]; //加長休止前的有聲音符1/8拍
            }
        }    
    }
    
    //藍調化(2)：隨機藍調音階
    0 => int offset;
    0 => int midiNote;
    0 => int index;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        
        // 搭配和弦調整音高？
        //if( progression[bar] == "F7" ) 5 => offset;
        //else if( progression[bar] == "G7" ) 7 => offset;
        //else 0 => offset;
        //
        
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            //隨機選擇音階中的音符
            Math.random2(0, scale.size()-1) => index;
            
            if ( half_beat == 0 || half_beat == 4 )
            {
               // (主幹音)：1, 5, b7，適合在強拍出現
               if (index < 4) 0 => index;  //轉為根音
               scale[index] + offset => midiNote; //5, b7維持不變
            }         
            else if ( index == 3 ) //隨機抽到經過音
            {
               //  (經過音)：b5。規定它必須接在 4 或 5 之後。
               if ( half_beat > 0 ) //非第一拍
               {
                 if ( (call[bar][half_beat - 1] == scale[2] || call[bar][half_beat - 1] == scale[4]) && length[bar][half_beat - 1] > 0.0::second )  
                    scale[index] + offset => midiNote; 
               }
               else
               {    
                 //隨機更換b5為其他音符
                 while( index == 3 ) Math.random2(0, scale.size()-1) => index;
                 scale[index] + offset => midiNote;
               }    
            }         
            else
            {    
                // 加上偏移量
                scale[index] + offset => midiNote;
                // 偶爾跳高一個八度，增加動態感 (Vibe!)
                //if( Math.randomf() > 0.6 ) 12 +=> midiNote;
            }
            midiNote => call[bar][half_beat];
        }    
    }    

    //藍調化(3)：力度層次
    68 => int bassline;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            
            if (  (call[bar][half_beat] == scale[1] || call[bar][half_beat] == scale[3] || call[bar][half_beat] == scale[5])
               || ( half_beat == 0 || half_beat == 4 )  )
            {    
                // 增強藍調音 b3, b5, b7，與1, 3重拍
                bassline + 5 => velocity[bar][half_beat];
            }
            else if (  (call[bar][half_beat] == scale[0] || call[bar][half_beat] == scale[2] || call[bar][half_beat] == scale[4])
                    && ( half_beat != 0 || half_beat != 4 )  )
            {
                // 減弱非強拍的穩定音（和弦根音）1, 4, 5
                bassline - 5 => velocity[bar][half_beat];
            }
            else
            {
                bassline => velocity[bar][half_beat];
            }    
        }    
    } 
}

fun void playLead() {
    MidiOut mout;
    MidiMsg msg;

    // open midi input, exit on fail
    if ( !mout.open(0) ) me.exit();  //Microsoft GS Wavetable Synth 
        
    //Selecting Instruments >>> data1: 1100 CCCC, data2: 0XXX XXXX
                                                //24 	Acoustic Guitar(nylon) 	木吉他（尼龍弦）
                                                //25 	Acoustic Guitar(steel) 	木吉他（鋼弦）
                                                //26 	Electric Guitar(jazz) 	電吉他（爵士）
                                                //27 	Electric Guitar(clean) 	電吉他（原音）
                                                //28 	Electric Guitar(muted) 	電吉他（悶音）
                                                //29 	Overdriven Guitar 	電吉他（破音）
                                                //30 	Distortion Guitar 	電吉他（失真）
                                                //31 	Guitar harmonics 	吉他泛音
    196 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
    25 => msg.data2;    //25 	Acoustic Guitar(steel) 	木吉他（鋼弦）
    mout.send(msg);

    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            call[bar][half_beat] => msg.data2;     //    
            velocity[bar][half_beat] => msg.data3;
            if ( length[bar][half_beat] > 0.0::second )
              <<<msg.data2, length[bar][half_beat] / quarter>>>;
            // data1=148=1001 0000, 1001=Note On,  0100=Chan 5th
            // data1=132=1000 0000, 1000=Note Off, 0100=Chan 5th
            148 => msg.data1;
            mout.send(msg);
            length[bar][half_beat] * 0.9 => now;
            132 => msg.data1;
            mout.send(msg);
            length[bar][half_beat] * 0.1 => now;
            
            //leadLen + length[bar][beat] => leadLen;
            //if (leadLen > songLen) {break;}
        }
        //if (leadLen > songLen) {break;}
    }
}

/* --- 2. 回應軌 (The Response Soloist) ---
fun void playResp() {
    //
    MidiOut mout;
    MidiMsg msg;

    // open midi input, exit on fail
    if ( !mout.open(0) ) me.exit();  //Microsoft GS Wavetable Synth 
        
    //Selecting Instruments >>> data1: 1100 CCCC, data2: 0XXX XXXX
                                                //24 	Acoustic Guitar(nylon) 	木吉他（尼龍弦）
                                                //25 	Acoustic Guitar(steel) 	木吉他（鋼弦）
                                                //26 	Electric Guitar(jazz) 	電吉他（爵士）
                                                //27 	Electric Guitar(clean) 	電吉他（原音）
                                                //28 	Electric Guitar(muted) 	電吉他（悶音）
                                                //29 	Overdriven Guitar 	電吉他（破音）
                                                //30 	Distortion Guitar 	電吉他（失真）
                                                //31 	Guitar harmonics 	吉他泛音
    197 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 6th
    30 => msg.data2;    //30 	Distortion Guitar 	電吉他（失真）
    mout.send(msg);

    60 => msg.data3;
    //
    8 * quarter=> now;
    respLen + (8 * quarter) => respLen;
    //
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        // 動態獲取目前的偏移量
        int offset;
        if( progression[bar] == 4 ) 5 => offset;
        else if( progression[bar] == 5 ) 7 => offset;
        else 0 => offset;

        for( 0 => int beat; beat < 4; beat++ ) {
            call[bar][beat] => msg.data2;     //    
            
            // data1=149=1001 0000, 1001=Note On,  0100=Chan 6th
            // data1=133=1000 0000, 1000=Note Off, 0100=Chan 6th
            149 => msg.data1;
            mout.send(msg);
            length[bar][beat] * 0.9 => now;
            133 => msg.data1;
            mout.send(msg);
            length[bar][beat] * 0.1 => now;
            
            respLen + length[bar][beat] => respLen;
            if (respLen > songLen) {break;}
        }
        if (respLen > songLen) {break;}
    }
    //
}
*/

// --- 啟動 ---
compose();
//spork ~ 
playLead();                 // 啟動主旋律
//playResp();               // 啟動回應旋律


