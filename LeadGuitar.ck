// --- 全域同步設定 ---


BluesKit.KEY => int key; 
1::minute / BluesKit.BPM => dur quarter;
BluesKit.blues @=> int blues[];            //藍調音階 1, b3, 4, b5, 5, b7
BluesKit.penta @=> int penta[];            //小調五聲音階 1, b3, 4, 5, b7
BluesKit.progression @=> string progression[];  //和弦進行

[0, 0, 0, 0, 0, 0] @=> int scale[]; 
int call[progression.size()][8];
dur length[progression.size()][8];
int velocity[progression.size()][8];

[0, 0, 0, 0, 0] @=> int r_scale[]; 
int r_call[progression.size()][8];
dur r_length[progression.size()][8];
int r_velocity[progression.size()][8];

fun void compose() {  
    /*--- Call ---*/
    //調Key
    for( 0 => int step; step < scale.size(); step++ ) {
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
                0.5 * quarter + length[bar][pos] => length[bar][pos]; //累進加長休止前的有聲音符1/8拍
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
    64 => int bassline;
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

    
    /* ---Resopnse--- */
    //調Key
    for( 0 => int step; step < r_scale.size(); step++ ) {
       key + penta[step] => r_scale[step];        
    }

    //回應(1)：隨機音符長度
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            // Sound:Rest Ratio
            if (Math.random2(0, 2) == 0) // 1:2
            {    
                //sound
                0.5 * quarter => r_length[bar][half_beat]; //1/8拍
            }
            else
            {
                //rest
                0.0 * quarter => r_length[bar][half_beat]; //1/8休止
                half_beat => int pos;  //目前位置
                while ( pos > 0 && r_length[bar][pos] == 0.0::second )
                {
                  pos--;  
                }    
                0.5 * quarter + r_length[bar][pos] => r_length[bar][pos]; //累進加長休止前的有聲音符1/8拍
            }
        }    
    }
    
    //回應(2)：隨機藍調音階
    0 => offset;
    0 => midiNote;
    0 => index;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        
        // 搭配和弦調整音高？
        //if( progression[bar] == "F7" ) 5 => offset;
        //else if( progression[bar] == "G7" ) 7 => offset;
        //else 0 => offset;
        //
        
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            //隨機選擇音階中的音符
            Math.random2(0, r_scale.size()-1) => index;
            
            if ( half_beat == 0 || half_beat == 4 )
            {
               // (主幹音)：1, 5, b7，適合在強拍出現
               if (index < 3) 0 => index;  //轉為根音
               r_scale[index] + offset => midiNote; //5, b7維持不變
            }         
            /* 
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
            */         
            else
            {    
                // 加上偏移量
                r_scale[index] + offset => midiNote;
                // 偶爾跳高一個八度，增加動態感 (Vibe!)
                //if( Math.randomf() > 0.6 ) 12 +=> midiNote;
            }
            midiNote => r_call[bar][half_beat];
        }    
    }    

    //回應(3)：力度層次
    64 => int r_bassline;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            
            if (  (call[bar][half_beat] == scale[1] || call[bar][half_beat] == scale[3] || call[bar][half_beat] == scale[5])
               || ( half_beat == 0 || half_beat == 4 )  )
            {    
                // 增強藍調音 b3, b5, b7，與1, 3重拍
                r_bassline + 5 => r_velocity[bar][half_beat];
            }
            else if (  (call[bar][half_beat] == scale[0] || call[bar][half_beat] == scale[2] || call[bar][half_beat] == scale[4])
                    && ( half_beat != 0 || half_beat != 4 )  )
            {
                // 減弱非強拍的穩定音（和弦根音）1, 4, 5
                r_bassline - 5 => r_velocity[bar][half_beat];
            }
            else
            {
                r_bassline => r_velocity[bar][half_beat];
            }    
        }    
    }   
}

fun string pitch(int m) {
        if ((m % 12) == 0) return "C";
        if ((m % 12) == 1) return "#C";
        if ((m % 12) == 2) return "D";
        if ((m % 12) == 3) return "bE";
        if ((m % 12) == 4) return "E";
        if ((m % 12) == 5) return "F";
        if ((m % 12) == 6) return "bG";
        if ((m % 12) == 7) return "G";
        if ((m % 12) == 8) return "#G";
        if ((m % 12) == 9) return "A";
        if ((m % 12) == 10) return "bB";
        if ((m % 12) == 11) return "B";
        return "";
}    

// --- 1. 旋律軌 (The Lead Soloist) ---
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
    //196 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
    //30 => msg.data2;    //30 	Distortion Guitar 	電吉他（失真）
    //mout.send(msg);

    for( 0 => int bar; bar < progression.size(); bar++ ) {
        if ( (bar % 4) < 2 && bar >= 4 )
        {    
            196 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
            22 => msg.data2;    //22 	Harmonica 	口琴
            mout.send(msg);
        }
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            call[bar][half_beat] => msg.data2;     //    
            velocity[bar][half_beat] => msg.data3;
            // data1=148=1001 0000, 1001=Note On,  0100=Chan 5th
            // data1=132=1000 0000, 1000=Note Off, 0100=Chan 5th
            if ( (bar % 4) < 2 && bar >= 4 )
            {    
                if ( length[bar][half_beat] > 0.0::second )
                  <<<"Call =", msg.data2, pitch(msg.data2) + Math.floor(msg.data2/12-1) $ int, ("" + length[bar][half_beat] / quarter).substring(0, 3)>>>;
                148 => msg.data1;
                mout.send(msg);
                length[bar][half_beat] * 0.9 => now;
                132 => msg.data1;
                mout.send(msg);
                length[bar][half_beat] * 0.1 => now;
            }
            else
                length[bar][half_beat] => now; 
        }
    }
}

// --- 2. 回應軌 (The Response Soloist) ---
fun void playResp() {
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
    //196 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
    //29 => msg.data2;    //29 	Overdriven Guitar 	電吉他（破音）
    //mout.send(msg);

    for( 0 => int bar; bar < progression.size(); bar++ ) {
        if ( (bar % 4) >= 2 )
        {    
            196 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
            29 => msg.data2;    //29 	Overdriven Guitar 	電吉他（破音）
            mout.send(msg);
        }    
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            r_call[bar][half_beat] => msg.data2;     //    
            r_velocity[bar][half_beat] => msg.data3;
            // data1=148=1001 0000, 1001=Note On,  0100=Chan 5th
            // data1=132=1000 0000, 1000=Note Off, 0100=Chan 5th
            if ( (bar % 4) >= 2 )
            {    
                if ( r_length[bar][half_beat] > 0.0::second )
                  <<<"Resp =", msg.data2, pitch(msg.data2) + Math.floor(msg.data2/12-1) $ int, ("" + r_length[bar][half_beat] / quarter).substring(0, 3)>>>;
                148 => msg.data1;
                mout.send(msg);
                r_length[bar][half_beat] * 0.9 => now;
                132 => msg.data1;
                mout.send(msg);
                r_length[bar][half_beat] * 0.1 => now;
            } 
            else
                r_length[bar][half_beat] => now; 
        }
    }
}

// --- 啟動 ---
compose();
spork ~ playLead();       // 啟動主旋律
playResp();               // 啟動回應旋律


