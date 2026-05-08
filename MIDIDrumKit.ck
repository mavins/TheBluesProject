// MIDIDrumKit.ck
public class MIDIDrumKit {
    MidiOut mout;
    MidiMsg msg[4];
    int lock;
    int index;
    
    fun void setDrumkit(int device)
    {
        // open midi output, exit on fail
        if ( !mout.open(device) ) me.exit();  //MIDI output

        // data1=153=1001 1001, 1001=Note On,  1001=Chan 10th
        // data1=137=1000 1001, 1000=Note Off, 1001=Chan 10th
        
        for ( 0 => index; index < 4; index++ )
            153 => msg[index].data1;   //data1=153 Note on, channel 10th Percussion instruments(drum, snare, tom, cymbal, hi-hat...) 
        
        0 => lock;
        0 => index;
    }    

    // play midi
    fun void playmidi(int pitch, int velocity)
    {
        while ( lock ) ; //lock_1 do no-op waiting for lock_0
        1 => lock;       //lock_0 >>> lock_1   
            pitch => msg[index].data2;
            velocity + 24 => msg[index].data3;
            mout.send(msg[index]);
        0 => lock;   
        index++;
        index % 4 => index;
    }

    // play mono
    [64, 32, 32, 32] @=> int velocity[];
    fun void drumbeat(int bassdrum, int snare_tomtom, int w_hihat, int w_cymbal, dur rate)
    {
        // bassdrum
        if (bassdrum != -1) 
            spork ~ playmidi(bassdrum, velocity[0]);
        // snare_tomtom
        if (snare_tomtom != -1) 
            spork ~ playmidi(snare_tomtom, velocity[1]);
        // hihat
        if (w_hihat != -1) 
            spork ~ playmidi(w_hihat, velocity[2]);
        // cymbal
        if (w_cymbal != -1) 
            spork ~ playmidi(w_cymbal, velocity[3]);

        // 
        rate => now;
    }
    
}
