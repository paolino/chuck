MidiIn min;

// open midi receiver, exit on fail
if ( !min.open(Std.atoi(me.arg(0))) ) me.exit(); 


fun void playNote (Event off,int note,int vel,float control[]){
    Wurley f =>  dac;
    Rhodey g =>  dac;
    float v;
    control[74] => f.controlOne => g.controlOne; 
    control[71] => f.controlTwo => g.controlTwo;
    note => Std.mtof => f.freq;
    note => Std.mtof => v;
    v*(1+control[97]*0.1) => g.freq;
    vel => v;
    v/200 => f.noteOn;
    v/200 => g.noteOn;
    off => now;
    1 => f.noteOff ;
    1 => g.noteOff;
    1::second => now;
    f =< dac;
    g =< dac;
    }

fun void midi (){

  Event noteOn[128];
  float control[128];

  MidiMsg msg;
  while( true )
  {
      // wait on midi event
      min => now;

      // receive midimsg(s)
      while( min.recv( msg ) )
      {
          msg.data1 <<4 => int chan; 
          msg.data1 >> 4 => int command;
          if (command == 8){ // noteOff;
              if (noteOn[msg.data2] != null)
                  noteOn[msg.data2].signal();
              null => noteOn[msg.data2];
              }
          if (command == 9){ // noteOn;
              if (noteOn[msg.data2] != null)
                  noteOn[msg.data2].signal();
              Event off;
              off @=> noteOn[msg.data2];
              spork ~ playNote(off,msg.data2,msg.data3,control);
              }
          if (command == 11){ // CC
              msg.data3  => float v;
              v/128 => control[msg.data2];
              <<< "CC", msg.data2, v >>>;
              }

          
          // print content
          <<< msg.data1 >> 4, msg.data2, msg.data3 >>>;
      }
  }
  }


//spork ~ midi();


100000 => int m;
MidiMsg msgs[m];
dur evt[m];
0 => int f;
0 => int i;
0 => int j;
time t0;
time over;

fun void reset (){
  while(true){
    0 => i;
    0 => j;
    now => t0;
    t0 + 2::second => over;
    2::second => now;
    <<<"reset","">>>;
    }
  }
    
fun void recordmidi(){
  while (true) {
      MidiMsg msg;
      min => now;
      // receive midimsg(s)
      while( min.recv( msg ) ){
        now - t0 => evt[i];
        msg @=> msgs[i];
        i++ ;
        <<<i,evt[i]>>>;
        }
      }
  }

Event noteOn[128];
float control[128];
fun void playmidi(){
  while (true) {
      evt[j] + t0 => time next;
      //<<<j,now,evt[j],t0,next,over>>>;
      if(next > now && next < over){
          next => now ;
          <<<j>>>;
          msgs[j] @=> MidiMsg msg;
          msg.data1 <<4 => int chan; 
          msg.data1 >> 4 => int command;
          if (command == 8){ // noteOff;
              if (noteOn[msg.data2] != null)
                  noteOn[msg.data2].signal();
              null => noteOn[msg.data2];
              }
          if (command == 9){ // noteOn;
              if (noteOn[msg.data2] != null)
                  noteOn[msg.data2].signal();
              Event off;
              off @=> noteOn[msg.data2];
              spork ~ playNote(off,msg.data2,msg.data3,control);
              }
          if (command == 11){ // CC
              msg.data3  => float v;
              v/128 => control[msg.data2];
              <<< "CC", msg.data2, v >>>;
              }
          j++;
          }
      else 1000::ms => now;
        
      }
  }

spork ~ reset();
spork ~ recordmidi();
spork ~ playmidi();
  //playmidi();
while (true){
  100::ms => now;
  }
