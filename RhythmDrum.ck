//MIDISequencer
MIDIDrumKit dk;
// device number: which MIDI output to open
0 => int device;
dk.setDrumkit(0);

1::minute / BluesKit.BPM => dur quarter;
BluesKit.progression @=> string progression[];  //和弦進行

// 12/8 拍 (Slow Blues)
quarter / 3 => dur beat;

quarter * 0.025 => now;  // 節奏偏移 (Quantize Offset)

[ -1,  -1,  -1,   -1,  -1,  -1,   -1,  -1,  -1,   -1,  -1,  -1] @=> int LHPH[]; //w_cymbal 49,51
[ 64,  64,  64,   64,  64,  64,   64,  64,  64,   64,  64,  64] @=> int LHVH[];

[ -1,  -1,  -1,   -1,  -1,  -1,   -1,  -1,  -1,   -1,  -1,  -1] @=> int LHP[];  //w_cymbal 49,51
[ 64,  64,  64,   64,  64,  64,   64,  64,  64,   64,  64,  64] @=> int LHV[];
[ 42,  42,  42,   44,  42,  42,   42,  42,  42,   44,  42,  46] @=> int LFP[];  //w_hihat 42,44,46
[ 64,  64,  64,   64,  64,  64,   64,  64,  64,   64,  64,  64] @=> int LFV[];
[ -1,  -1,  -1,   40,  -1,  -1,   -1,  -1,  -1,   40,  -1,  -1] @=> int RHP[];  //snare_tomtom 37,40,41,43,45
[ 64,  64,  64,   72,  64,  64,   64,  64,  64,   72,  64,  64] @=> int RHV[];
[ 36,  -1,  -1,   -1,  -1,  -1,   36,  -1,  -1,   -1,  -1,  -1] @=> int RFP[];  //bassdrum 36
[ 80,  64,  64,   64,  64,  64,   72,  64,  64,   64,  64,  64] @=> int RFV[];

[ -1,  -1,  -1,   40,  -1,  -1,   -1,  -1,  -1,   40,  -1,  -1] @=> int RHPF[];  //snare_tomtom 37,40,41,43,45
[ 64,  64,  64,   72,  64,  64,   64,  64,  64,   72,  64,  64] @=> int RHVF[];
[ 36,  -1,  -1,   -1,  -1,  -1,   36,  -1,  -1,   -1,  -1,  -1] @=> int RFPF[];  //bassdrum 36
[ 80,  64,  64,   64,  64,  64,   72,  64,  64,   64,  64,  64] @=> int RFVF[];

//while(true)
for (0 => int j; j < (progression.size()/4); j++)
{
    //head
    for (0 => int i; i < 12; i++)
    {
        spork ~ dk.playmidi(LHPH[i], LHVH[i]);  //spork for left hand strikes
        spork ~ dk.playmidi(LFP[i], LFV[i]);    //spork for left foot strikes
        spork ~ dk.playmidi(RHP[i], RHV[i]);    //spork for right hand strikes
        spork ~ dk.playmidi(RFP[i], RFV[i]);    //spork for right hand strikes
        beat => now;	// advance time
    }
    //loop
    for (0 => int i; i < 24; i++)
    {
        spork ~ dk.playmidi(LHP[i%12], LHV[i%12]);  //spork for left hand strikes
        spork ~ dk.playmidi(LFP[i%12], LFV[i%12]);  //spork for left foot strikes
        spork ~ dk.playmidi(RHP[i%12], RHV[i%12]);  //spork for right hand strikes
        spork ~ dk.playmidi(RFP[i%12], RFV[i%12]);  //spork for right hand strikes
        beat => now;	// advance time
    }
    //fill
    for (0 => int i; i < 12; i++)
    {
        spork ~ dk.playmidi(LHP[i], LHV[i]);    //spork for left hand strikes
        spork ~ dk.playmidi(LFP[i], LFV[i]);    //spork for left foot strikes
        spork ~ dk.playmidi(RHPF[i], RHVF[i]);  //spork for right hand strikes
        spork ~ dk.playmidi(RFPF[i], RFVF[i]);  //spork for right hand strikes
        beat => now;	// advance time
    }
    //
}
