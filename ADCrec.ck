// chuck this with other shreds to record to file
// example> chuck foo.ck bar.ck rec (see also rec2.ck)
BluesKit bk;        //BluesKit object instance

// arguments: rec:<filename>

// get name
me.arg(0) => string filename;
if( filename.length() == 0 ) me.dir()+"blues.wav" => filename;

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
