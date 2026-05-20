//----MIDI設定------------------------------//
BluesKit bk;        //BluesKit object instance

// 實體化static MIDI物件
new MidiOut @=> BluesKit.mout;
new MidiMsg[16] @=> BluesKit.msg;
BluesKit.mout @=> MidiOut mout; 
BluesKit.msg @=> MidiMsg msg[];

// open midi input, exit on fail
if ( !BluesKit.mout.open(0) ) me.exit();  //Microsoft GS Wavetable Synth 

// 頻道與音色設定：Selecting Instruments >>> data1: 1100 CCCC, data2: 0XXX XXXX
//22 	Harmonica 	口琴
//24 	Acoustic Guitar(nylon) 	木吉他（尼龍弦）
//25 	Acoustic Guitar(steel) 	木吉他（鋼弦）
//26 	Electric Guitar(jazz) 	電吉他（爵士）
//27 	Electric Guitar(clean) 	電吉他（原音）
//28 	Electric Guitar(muted) 	電吉他（悶音）
//29 	Overdriven Guitar 	電吉他（破音）
//30 	Distortion Guitar 	電吉他（失真）
//31 	Guitar harmonics 	吉他泛音
//32	Acoustic Bass	民謠貝斯
//33	Electric Bass(finger)	電貝斯（指奏）
//34	Electric Bass(pick)	電貝斯（撥奏）
//35	Fretless Bass	無格貝斯
//36	Slap Bass 1	捶鉤貝斯 1
//37	Slap Bass 2	捶鉤貝斯 2
//38	Synth Bass 1	合成貝斯1
//39	Synth Bass 2	合成貝斯2

// 節奏吉他音色：26 	Electric Guitar(jazz) 	電吉他（爵士）
192 => msg[0].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 1st
26 => msg[0].data2;    //#Instruments: 26 Electric Guitar(jazz) 
mout.send(msg[0]);
193 => msg[1].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0001: Chan 2nd
26 => msg[1].data2;    //#Instruments: 26 Electric Guitar(jazz) 
mout.send(msg[1]);
194 => msg[2].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0010: Chan 3ed
26 => msg[2].data2;    //#Instruments: 26 Electric Guitar(jazz) 
mout.send(msg[2]);
195 => msg[3].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0011: Chan 4th
26 => msg[3].data2;    //#Instruments: 26 Electric Guitar(jazz) 
mout.send(msg[3]);

// 貝斯吉他音色：34	Electric Bass(pick)	電貝斯（撥奏）
196 => msg[4].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 5th
34 => msg[4].data2;    //34	Electric Bass(pick)	電貝斯（撥奏） 
mout.send(msg[4]);

// 主奏吉他音色：30 	Distortion Guitar 	電吉他（失真）
197 => msg[5].data1;   //data1=192=1100 0000, 1100: Selecting Instruments, 0000: Chan 6th
30 => msg[5].data2;    //30 	Distortion Guitar 	電吉他（失真）
mout.send(msg[5]);


// 輔助函式：發送 CC
fun void sendCC( int channel, int ccNum, int value )
{
    //MIDI CC 訊息的 Status Byte 是 176 + (channel 0~15)
    176 + channel => msg[channel].data1;
    ccNum => msg[channel].data2;
    value => msg[channel].data3;
    mout.send(msg[channel]);
}

// 設定Bending Range
fun void setPitchBendRange( int channel, int semitones )
{
    // 1. 選取 RPN 0,0 (Pitch Bend Sensitivity)
    sendCC(channel, 101, 0);
    sendCC(channel, 100, 0);
    
    // 2. 設定半音數 (Data Entry MSB)
    sendCC(channel, 6, semitones);
    
    // 3. 設定音分數 (Data Entry LSB, 通常為 0)
    sendCC(channel, 38, 0);
    
    // 4. RPN Null (安全考量，將參數選取重設為 127,127)
    sendCC(channel, 101, 127);
    sendCC(channel, 100, 127);
    
    <<< "Pitch Bend Range set to:", semitones, "semitones" >>>;
}

// 執行：將主奏吉他 Channel 6 的滑音範圍設定為 2 (全音)
setPitchBendRange(5, 2);

// 樂器定位：Channel, 定位(CC 10), 數值 0 (左) 到 127 (右)
sendCC( 9, 10, 64 );  //爵士鼓 Channel 10
sendCC( 0, 10, 112 );
sendCC( 1, 10, 112 );
sendCC( 2, 10, 112 );
sendCC( 3, 10, 112 );
sendCC( 4, 10, 16 );  //貝斯吉他
sendCC( 5, 10, 64 );

// 樂器殘響：Channel, 殘響(CC 91無效 || CC 1), 數值 0 (小) 到 127 (大) 
sendCC( 9, 1, 0 );   //爵士鼓 Channel 10
sendCC( 0, 1, 64 );
sendCC( 1, 1, 64 );
sendCC( 2, 1, 64 );
sendCC( 3, 1, 64 );
sendCC( 4, 1, 64 );  //貝斯吉他
sendCC( 5, 1, 0 );
//

//----錄音----------------------------------//
// chuck this with other shreds to record to file
// example> chuck foo.ck bar.ck rec (see also rec2.ck)
// arguments: rec:<filename>
// get name
me.arg(0) => string filename;
if( filename.length() == 0 ) me.dir() + "blues" + ((now / second) $ int) + ".wav" => filename;

// pull samples from the dac
adc => Gain g => WvOut w => blackhole;
// this is the output file name
filename => w.wavFilename;
<<<"writing to file:", "'" + w.filename() + "'">>>;
// any gain you want for the output
1.0 => g.gain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

// infinite time loop...
// ctrl-c will stop it, or modify to desired duration
1::minute / BluesKit.BPM => dur quarter;
BluesKit.progression @=> string progression[];  //和弦進行
progression.size() * 4 * quarter => now;

//強制關閉該通道所有聲音 (All Notes Off)
sendCC( 5, 123, 0 );    
Machine.clearVM();
