// --- 全域同步設定 ---
BluesKit.mout @=> MidiOut mout; 
BluesKit.msg @=> MidiMsg msg[];

BluesKit.KEY => int key; 
1::minute / BluesKit.BPM => dur quarter;
BluesKit.VOL => int bassline;

BluesKit.blues @=> int blues[];                 //藍調音階 1, b3, 4, b5, 5, b7
BluesKit.penta @=> int penta[];                 //小調五聲音階 1, b3, 4, 5, b7
BluesKit.progression @=> string progression[];  //和弦進行

[0, 0, 0, 0, 0, 0] @=> int scale[]; 
int call[progression.size()][8];
dur length[progression.size()][8];
int velocity[progression.size()][8];

[0, 0, 0, 0, 0] @=> int r_scale[]; 
int r_call[progression.size()][8];
dur r_length[progression.size()][8];
int r_velocity[progression.size()][8];


//手工作曲----------------------------------------------------------------------
    [[  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
    
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  0,  0,  0,  1,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
    
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  1,  0,  0,  1,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  1,  0,  0,  0,  0, -1,  0],
    
     [  1,  1,  0,  0,  0,  0,  0,  0],
     [  0,  0,  1,  1,  1,  0,  0,  0],
     [  0,  0,  0,  0,  0,  0,  0,  0],
     [  0,  1, -1,  0,  0,  0,  0,  0]] @=> int bending[][];

fun void hu_compose() {  
    //--- Call ---//
    //調Key
    for( 0 => int step; step < scale.size(); step++ ) {
       key + blues[step] => scale[step];        
    }
    
    //rest = -9, sustain = -1
    [[ -9, -1, -1, -1, -1, -1, -1, -1],
     [ -9, -1, -1, -1, -1, -1, -1, -1],
     [ -9, -1, -1, -1, -1, -1, -1, -1],
     [ -9, -1, -1, -1, -1, -1, -1, -1],
    
     [ -9, -1,  0,  1, -1, -1,  0, -1],
     [ -9,  0,  1, -1,  2, -1,  2,  1],
     [  0, -1,  1, -1, -9, -1, -1, -1],
     [ -9, -1, -1, -1,  0,  5,  0,  5],
    
     [  0,  1,  0,  5,  0,  1, -9, -1],
     [ -9,  2, -1, -1,  2,  1,  0, -1],
     [  0,  1, -9, -1, -9, -1, -1, -1],
     [ -9,  2, -1, -1, -1, -1,  2, -1],
    
     [  2,  2, -1, -1, -1, -1, -9, -1],
     [ -9, -1,  2,  2,  2, -1,  2,  1],
     [  0, -1,  1, -1, -9, -1, -1, -1],
     [ -9,  2,  2,  0,  5, -1, -9, -1]] @=> int b_index[][];   
   
    //藍調化(1)：手工音符長度
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            // Sound
            if (b_index[bar][half_beat] != -1) // 有設定音高或休止符
            {    
                0.5 * quarter => length[bar][half_beat]; //1/8拍
            }
            else
            {
                0.0 * quarter => length[bar][half_beat]; //延長1/8拍往前推送
                half_beat => int pos;  //目前位置
                while ( pos > 0 && length[bar][pos] == 0.0::second ) pos--;  
                0.5 * quarter + length[bar][pos] => length[bar][pos]; //累進延長1/8拍
            }
        }    
    }

    //藍調化(2)：手工藍調音階
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
            //設定音階指標
            if (b_index[bar][half_beat] == -9 || b_index[bar][half_beat] == -1) //休止符或虛音 
                -1 => midiNote; //休止符
            else
            {    
                b_index[bar][half_beat] => index;          
                scale[index] + offset => midiNote;
            }    
            midiNote => call[bar][half_beat];
        }    
    } 

    //藍調化(3)：力度層次
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
                if (b_index[bar][half_beat] == -9 || b_index[bar][half_beat] == -1) //休止符或虛音
                    0 => velocity[bar][half_beat];
                else
                    bassline => velocity[bar][half_beat];
            }    
        }    
    } 
   
    /* ---Resopnse--- //
    //調Key
    for( 0 => int step; step < r_scale.size(); step++ ) {
       key + penta[step] => r_scale[step];        
    }

    //回應(1)：隨機小調五聲音階
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

    //回應(2)：隨機音符長度
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
    
    //回應(3)：力度層次
    bassline - 16 => int r_bassline;
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
    */
}

//機械作曲----------------------------------------------------------------------
fun void ma_compose() {  
    /*------------- Call -------------*/
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
               if (index < 4) 0 => index;  //轉為根音，5, b7維持不變
            }         
            else if ( index == 3 ) //隨機抽到經過音
            {
               //  (經過音)：b5。非第一拍，且規定它必須接在 4 或 5 之後。
               if ( half_beat > 0 && (call[bar][half_beat - 1] == scale[2] || call[bar][half_beat - 1] == scale[4]) && length[bar][half_beat - 1] > 0.0::second )
               {    
                    //do nothing index == 3 
               }
               else
               {    
                 //強制更換b5為其他隨機音符
                 while( index == 3 ) Math.random2(0, scale.size()-1) => index;
               }    
            }         
            else
            {    
               //do nothing, keep the index
            }
            
            // 加上偏移量
            scale[index] + offset => midiNote;
            // 偶爾跳高一個八度，增加動態感 (Vibe!)
            //if( Math.randomf() > 0.6 ) 12 +=> midiNote;
            midiNote => call[bar][half_beat];
        }    
    } 


    //藍調化(3)：力度層次
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
   
    /*------------- Resopnse -------------*/
    //調Key
    for( 0 => int step; step < r_scale.size(); step++ ) {
       key + penta[step] => r_scale[step];        
    }

    //回應(1)：隨機小調五聲音階
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
            else
            {    
                // 加上偏移量
                r_scale[index] + offset => midiNote;
                // 偶爾跳高一個八度，增加動態感 (Vibe!)
                //if( Math.randomf() > 0.6 ) 12 +=> midiNote;
            }
            midiNote => r_call[bar][half_beat];
            // Mi bending
            if ( index == 2 )  //2
                1 => bending[bar][half_beat];
            else 
                0 => bending[bar][half_beat];    
        }    
    }    

    //回應(2)：隨機音符長度
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
    
    //回應(3)：力度層次
    bassline - 16 => int r_bassline;
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

//MIDI PLAYER ---------------------------------------------------------------------------------------

// 輔助函式：發送 CC
fun void sendCC( int channel, int ccNum, int value )
{
    //MIDI CC 訊息的 Status Byte 是 176 + (channel 0~15)
    176 + channel => msg[channel].data1;
    ccNum => msg[channel].data2;
    value => msg[channel].data3;
    mout.send(msg[channel]);
}

// 發送 Pitch Bend 的函式
fun void sendBend( int channel, int up_or_down, dur beat ) {
    // Pitch Bend 狀態碼為 0xE0 (對應 Channel 0)
    224 + channel => msg[channel].data1; 
    8192 => int value; //基礎值
    beat / 32 => dur step;

    if ( up_or_down == 1)
    {    
      8191 => value; //基礎值 - 1
      for( 0 => int i; i < 16; i++ )
      {    
          // 14-bit 數值拆解為兩個 7-bit (LSB 和 MSB)
          value & 127 => msg[channel].data2;      // 低位元 (LSB)
          (value >> 7) & 127 => msg[channel].data3; // 高位元 (MSB)
          mout.send(msg[channel]);
          step => now; 
          value + 512 => value;
      }
      beat * 0.5 => now;
    }
    else if ( up_or_down == -1)
    {
      8192 => int value; //基礎值
      for( 0 => int i; i < 16; i++ )
      {    
          // 14-bit 數值拆解為兩個 7-bit (LSB 和 MSB)
          value & 127 => msg[channel].data2;      // 低位元 (LSB)
          (value >> 7) & 127 => msg[channel].data3; // 高位元 (MSB)
          mout.send(msg[channel]);
          step => now; 
          value - 512 => value;
      }
      beat * 0.5 => now; 
    }
    else
    {    
        // 14-bit 數值拆解為兩個 7-bit (LSB 和 MSB)
        //value & 127 => msg[channel].data2;      // 低位元 (LSB)
        //(value >> 7) & 127 => msg[channel].data3; // 高位元 (MSB)
        //mout.send(msg[channel]);
        beat => now;
    }
    
    //強制關閉該通道所有聲音 (All Notes Off)
    //sendCC( 5, 123, 0 );    
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
fun void play_huLead() {     
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        <<<"bar =", bar>>>;
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            call[bar][half_beat] => msg[5].data2;     //    
            velocity[bar][half_beat] => msg[5].data3;
            // data1=149=1001 0000, 1001=Note On,  0100=Chan 6th
            // data1=133=1000 0000, 1000=Note Off, 0100=Chan 6th
            if ( length[bar][half_beat] > 0.0::second )
              <<<"Call =", msg[5].data2, pitch(msg[5].data2) + Math.floor(msg[5].data2/12-1) $ int, ("" + length[bar][half_beat] / quarter).substring(0, 3)>>>;

            149 => msg[5].data1;    //Note On
            mout.send(msg[5]);      
            //bending or not
            sendBend( 5, bending[bar][half_beat], length[bar][half_beat] * 0.9 );

            133 => msg[5].data1;    //Note Off
            mout.send(msg[5]);
            //bending 歸零
            sendBend( 5, 0, length[bar][half_beat] * 0.1 );
        }
        //強制關閉該通道所有聲音 (All Notes Off)
        sendCC( 5, 123, 0 );    
    }
}

fun void play_maLead() {
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        if ( (bar % 4) < 2 && bar >= 4 )
        {    
            <<<"bar =", bar>>>;
            197 => msg[5].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 6th
            22 => msg[5].data2;    //22 	Harmonica 	口琴
            mout.send(msg[5]);
            sendCC( 5, 10, 96 );   //定位
        }
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            call[bar][half_beat] => msg[5].data2;     //    
            velocity[bar][half_beat] => msg[5].data3;
            // data1=149=1001 0000, 1001=Note On,  0100=Chan 6th
            // data1=133=1000 0000, 1000=Note Off, 0100=Chan 6th
            if ( (bar % 4) < 2 && bar >= 4 )
            {    
                if ( length[bar][half_beat] > 0.0::second )
                  <<<"Call =", msg[5].data2, pitch(msg[5].data2) + Math.floor(msg[5].data2/12-1) $ int, ("" + length[bar][half_beat] / quarter).substring(0, 3)>>>;

                149 => msg[5].data1;    //Note On
                mout.send(msg[5]);      
                //bending or not
                sendBend( 5, bending[bar][half_beat], length[bar][half_beat] * 0.9 );

                133 => msg[5].data1;    //Note Off
                mout.send(msg[5]);
                //bending 歸零
                sendBend( 5, 0, length[bar][half_beat] * 0.1 );
            }
            else
                sendBend( 5, 0, length[bar][half_beat] );
        }
    }
}

// --- 2. 回應軌 (The Response Soloist) ---
fun void play_maResp() {
    for( 0 => int bar; bar < progression.size(); bar++ ) {
        if ( (bar % 4) >= 2 )
        {    
            <<<"bar =", bar>>>;
            197 => msg[5].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 6th
            29 => msg[5].data2;    //29 	Overdriven Guitar 	電吉他（破音）
            mout.send(msg[5]);
            sendCC( 5, 10, 32 );   //定位
        }    
        for( 0 => int half_beat; half_beat < 8; half_beat++ ) { //half_beat
            r_call[bar][half_beat] => msg[5].data2;     //    
            r_velocity[bar][half_beat] => msg[5].data3;
            // data1=149=1001 0000, 1001=Note On,  0100=Chan 6th
            // data1=133=1000 0000, 1000=Note Off, 0100=Chan 6th
            if ( (bar % 4) >= 2 )
            {    
                if ( r_length[bar][half_beat] > 0.0::second )
                  <<<"Resp =", msg[5].data2, pitch(msg[5].data2) + Math.floor(msg[5].data2/12-1) $ int, ("" + r_length[bar][half_beat] / quarter).substring(0, 3)>>>;

                149 => msg[5].data1;    //Note On
                mout.send(msg[5]);      
                //bending or not
                sendBend( 5, bending[bar][half_beat], r_length[bar][half_beat] * 0.9 );

                133 => msg[5].data1;    //Note Off
                mout.send(msg[5]);
                //bending 歸零
                sendBend( 5, 0, r_length[bar][half_beat] * 0.1 );
            } 
            else
                sendBend( 5, 0, r_length[bar][half_beat] );
        }
        //強制關閉該通道所有聲音 (All Notes Off)
        sendCC( 5, 123, 0 );    
    }
}

// --- 啟動 ---
//hu_compose();                 // hu_compose(); 
//play_huLead();                // 啟動主旋律

ma_compose();                   // ma_compose(); 
spork ~ play_maLead();          // 啟動主旋律
play_maResp();                  // 啟動回應旋律
