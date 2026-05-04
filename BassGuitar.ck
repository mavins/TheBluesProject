// --- 全域同步設定 ---


BluesKit.KEY => int key; 
1::minute / BluesKit.BPM => dur quarter;
BluesKit.major @=> int major[];                 //大調音階 1, 2, 3, 4, 5, 6, 7
BluesKit.progression @=> string progression[];  //和弦進行

[0, 0, 0, 0, 0, 0, 0] @=> int scale[]; 
//[1, 4, 1, 1,  4, 4, 1, 1,  5, 4, 1, 5] @=> int progression[];             //from the top
//[5, 4, 1, 5, 1, 4, 1, 1,  4, 4, 1, 1,  5, 4, 1, 5] @=> int progression[]; //from the V
//[1, 4, 1, 1,  4, 4, 1, 6,  2, 5, 1, 5] @=> int progression[];             //wiwi
quarter * 4 => dur barLen; // 一小節的長度
barLen * 12 => dur songLen; // 12barblues 全曲長

int call[progression.size()][8];
dur length[progression.size()][8];
int velocity[progression.size()][8];

// --- 1. 旋律軌 (The Lead Soloist) ---
fun void compose() {  
    //調整Key
    for( 0 => int step; step < major.size(); step++ ) {
       key + major[step] => scale[step];        
    }

    //藍調化：四拍Walking Bass
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            // Rest or Sound?
            if (half_beat % 2 == 0)
            {    
                //sound
                quarter => length[bar][half_beat];
            }
            else
            {
                //rest
                0.0 * quarter => length[bar][half_beat];
            }
        }    
    }
    
    //初始化：大調音階
    0 => int offset;
    0 => int midiNote;
    0 => int index;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        
        if( progression[bar] == "IV7" ) 5 => offset;
        else if( progression[bar] == "V7" ) 7 => offset;
        else 0 => offset;

        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            //設定音階中的音符
            if ( half_beat == 0 )
            {
               // 根音
               0 => index;
               scale[index] + offset => midiNote; 
            }         
            else if ( half_beat == 2 )
            {
               // 三度音
               2 => index;
               scale[index] + offset => midiNote; 
            }         
            else if ( half_beat == 4 )
            {
               // 五度音
               4 => index;
               scale[index] + offset => midiNote; 
            }         
            else if ( half_beat == 6 )
            {
               if ( bar < progression.size() - 1 )
               {
                   // 後續和弦的半音趨近
                   if ( progression[bar] != progression[bar+1] )
                   {     
                       if( progression[bar+1] == "IV7" ) 5 => offset;
                       else if( progression[bar+1] == "V7" ) 7 => offset;
                       else 0 => offset;
                        
                       0 => index;
                       scale[index] + offset + 1 => midiNote; 
                   }
                   else
                   {
                       // 三度音
                       2 => index;
                       scale[index] + offset => midiNote; 
                   }                       
               }
               else
               {
                   // 全音趨近
                   0 => index;
                   scale[index] + offset + 2 => midiNote; 
               }
            }         
            else
            {    
               // 根音
               0 => index;
               scale[index] + offset => midiNote; 
            }
            midiNote - 24 => call[bar][half_beat]; //降低兩個八度
        }    
    }    

    //藍調化：力度層次
    65 => int bassline;
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            
            if ( half_beat == 0 || half_beat == 4 )
            {    
                // 1, 3重拍
                bassline + 10 => velocity[bar][half_beat];
            }
            else
            {
                bassline => velocity[bar][half_beat];
            }    
        }    
    }    
}

fun void playBass() {
    MidiOut mout;
    MidiMsg msg;

    // open midi input, exit on fail
    if ( !mout.open(0) ) me.exit();  //Microsoft GS Wavetable Synth 
        
    //Selecting Instruments >>> data1: 1100 CCCC, data2: 0XXX XXXX
                                                        //32	Acoustic Bass	民謠貝斯
                                                        //33	Electric Bass(finger)	電貝斯（指奏）
                                                        //34	Electric Bass(pick)	電貝斯（撥奏）
                                                        //35	Fretless Bass	無格貝斯
                                                        //36	Slap Bass 1	捶鉤貝斯 1
                                                        //37	Slap Bass 2	捶鉤貝斯 2
                                                        //38	Synth Bass 1	合成貝斯1
                                                        //39	Synth Bass 2	合成貝斯2
    197 => msg.data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 6th
    34 => msg.data2;    //34	Electric Bass(pick)	電貝斯（撥奏） 
    mout.send(msg);

    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            call[bar][half_beat] => msg.data2;     //    
            velocity[bar][half_beat] => msg.data3;
            //if ( length[bar][half_beat] > 0.0::second )
            //  <<<msg.data2, length[bar][half_beat] / quarter>>>;
            // data1=148=1001 0000, 1001=Note On,  0101=Chan 6th
            // data1=132=1000 0000, 1000=Note Off, 0101=Chan 6th
            149 => msg.data1;
            mout.send(msg);
            length[bar][half_beat] * 0.9 => now;
            133 => msg.data1;
            mout.send(msg);
            length[bar][half_beat] * 0.1 => now;
            
            //leadLen + length[bar][beat] => leadLen;
            //if (leadLen > songLen) {break;}
        }
        //if (leadLen > songLen) {break;}
    }
}

// --- 啟動 ---
compose();
playBass();      // 啟動主旋律