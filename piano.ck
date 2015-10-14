MidiIn min;
MidiOut mout;

// open midi receiver, exit on fail
if ( !min.open(0) ) me.exit(); 
if ( !mout.open(0) ) me.exit(); 
//spork ~ midi();


100000 => int m;
MidiMsg msgs[m];
dur evt[m];
0 => int f;
0 => int i;
0 => int j;
time t0;
time over;



t0 + 4::second => over;

fun void reset (){
  SinOsc s=> ADSR e => dac;
  0.3=> s.gain;
  (2::ms,50::ms,0,0::ms) => e.set;
  0 => int i;
  while(true){
  if(now < over){
    if(i%4 == 0) 
      1760 => s.sfreq;
    else 
      880 => s.sfreq;
    1 => e.keyOn;
    }
  i++;
  (0.5*15/16)::second => now;
  
  
  }
  
}
float controls[128];
fun void recordmidi(){
  now => t0;
  while (true) {
      MidiMsg msg;
      min => now;
      if (now < over)
        while( min.recv( msg ) ){
          now - t0 => evt[i];
          msg @=> msgs[i];
          <<<i,evt[i]>>>;
          i++ ;
          }
      else{  
        while( min.recv( msg ) ){
            msg.data1 >> 4 => int command;
          if (command == 11){ // CC
              msg.data3  => float v;
              v/128 => controls[msg.data2];
              <<< "CC", msg.data2, v >>>;
              }
            }
        }
      }
  }

int queue[5];
Event noteOn[128];
  
0 => int iq;

fun dur quant(dur a,dur w,int sub){
  (a/w*sub + 0.5) $ int => int k;
  return k*w/sub;
  }
// evaluate e waiting time for events of a repeated sequence
fun dur wait(int ne,dur w,int n){
  evt[n%ne] + w * (n / ne) => dur a;
  return a; 
  }

int flag[3];
fun void stopat(dur t){
    while(true){
      t => now;
      1 => flag[0];
      1 => flag[1];
      1 => flag[2];
      }
    }

fun void noteoff(int note){
  MidiMsg msg;
  (2*15/16)::second => now;
  0 => msg.data3;
  note => msg.data2;
  8 << 4 => msg.data1;
  mout.send(msg);
  }
fun void playmidi(dur maxw,int cc,int h) {
  
  maxw => now; // wait for record notes to end;
  now => time tb;
  for (0 => int l;l<4;l++){
    1 => controls[cc + 2 * l];
    0.2 => controls[cc+1 + 2 *l];
    }
  while(true){
      <<<"d">>>;
      for (0 => int l;l<4;l++){
        0 => int n;
        <<<"c">>>;
        now => time t0;
        0 => flag[h];
        while(!flag[h]){
            controls[cc + 2*l] * maxw => dur shift;
            1/(2*controls[cc+1+2*l] + 0.1) => float speed;
            quant(wait(i,maxw,n)*speed-shift,maxw,64) => dur w;
            if(w + t0 <= now){
              n++; // try next event;
              continue;
              }
            w + t0 => now;
            if(msgs[n%i].data1 >> 4 == 9);
              spork ~ noteoff(msgs[n%i].data2);
            mout.send(msgs[(n++)%i]);
            
            }
          }
      }
  }
(15.0/16)::second => dur d;
spork ~ stopat(d);
spork ~ reset();
spork ~ recordmidi();
spork ~ playmidi((4*15/16)::second,81,0);
//spork ~ playmidi((8.0*15/16)::second,89,1);
//spork ~ playmidi(8::second,97,2);
  //playmidi();
while (true){
  100::ms => now;
  }
