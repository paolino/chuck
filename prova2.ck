Shakers f => NRev r => dac;


MidiIn min;
MidiMsg msg;

int state[256];
// open midi receiver, exit on fail
if ( !min.open(0) ) me.exit(); 

fun void midi (){
  while( true )
  {
      // wait on midi event
      min => now;

      // receive midimsg(s)
      while( min.recv( msg ) )
      {
      msg.data3 => state[msg.data2];
          // print content
          <<< msg.data1, msg.data2, msg.data3 >>>;
      }
  }
  }
spork ~ midi();
while (true){
  state[97] => int i;
  i => f.preset;
  float a;
 
  state[99] => a;
  a/128 => f.decay;
  state[100] => i;
  i => f.objects;
  state[101] => a;
  a/128 => f.gain;
  state[102] => a;
  a/128 => r.mix;
  state[98] => a;
  a/128 => f.energy;

  80::ms => now;
  }
