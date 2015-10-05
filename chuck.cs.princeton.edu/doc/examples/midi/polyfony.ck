//------------------------------------------------
// name: polyfony.ck
// desc: polyfonic mandolin model
//
// by: Ananya Misra and Ge Wang
// send all complaints to prc@cs.princeton.edu
//--------------------------------------------

// device to open (see: chuck --probe)
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

MidiIn min;
MidiMsg msg;

// try to open MIDI port (see chuck --probe for available devices)
if( !min.open(5) ) me.exit();

// print out device that was opened
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;
// make our own event
class NoteEvent extends Event
{
    int note;
    int velocity;
}

// the event
NoteEvent on;
// array of ugen's handling each note
Event @ us[128];


// the base patch
// handler for a single voice
fun void handler()
{

    Event off;
    int note;
    // an ADSR envelope
    // (also see envelope.ck)
    SinOsc s;
    ADSR e;
    Gain g; 
    // set a, d, s, and r
    e.set( 20::ms, 8::ms, .5, 500::ms );
    // set gain
    1 => s.gain;

    // infinite time-loop
    while( true )
    {
        // choose freq
         // key on - start attack


        on => now;
        on.note => note;
        // dynamically repatch
        s => e => g => dac;
        Std.mtof( note ) + 1 => s.freq;
        on.velocity / 128.0 => g.gain;
        e.keyOn();
        if(us[note]!=null) us[note].signal();
        off @=> us[note];

        off => now;
        e.keyOff();
        null @=> us[note];
        s =< e =< g =< dac;
    }
}

// spork handlers, one for each voice
for( 0 => int i; i < 20; i++ ) spork ~ handler();

// infinite time-loop
while( true )
{
    // wait on midi event
    min => now;

    // get the midimsg
    while( min.recv( msg ) )
    {
        // catch only noteon
        if( msg.data1 == 144) {
          if( msg.data3 > 0 )
          {
              // store midi note number
              msg.data2 => on.note;
              // store velocity
              msg.data3 => on.velocity;
              // signal the event
              on.signal();
              // yield without advancing time to allow shred to run
          }
          else
          {
              if( us[msg.data2] != null ) us[msg.data2].signal();
          }
        }
        else 
        if( msg.data1 == 128)
          {
            // store midi note number
            msg.data2 => on.note;
            // store velocity
            msg.data3 => on.velocity;
            // signal the event
            if( us[msg.data2] != null ) us[msg.data2].signal();
          }
        me.yield();
    }
}
