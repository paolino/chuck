
// fm synth "by hand"
// to be legit, we should be polling another sinosc
// - pld  06/17/04
SndBuf k => dac;
SndBuf h => dac;
SndBuf s => dac;
me.dir() + "audio/kick_01.wav" => k.read;
me.dir() + "audio/hihat_01.wav" => h.read;
me.dir() + "audio/snare_01.wav" => s.read;


fun void f1(int a, int b,dur t){
  a*k.samples() => k.pos;
  b*h.samples() => h.pos;
  t => now;
};


[5261916562,45263782,55123678,123797819] @=> int iks[];

while(true) {
  3 => int div;
  for(0 => int j;j < 4;j+1 => j){
    now => time z;
    iks[j] => int ik;
    while(ik >0) {
      ik%div => float vk;
      vk/div => k.gain;
      ik/div => ik;
      ik%div => vk;
      vk/div => h.gain;
      ik/div => ik;
      ik%div => vk;
      vk/div => s.gain;
      ik/div => ik;

      0 => k.pos;
      0 => h.pos;
      0 => s.pos;
      120::ms => now;
      }
    z + 960::ms => now;
    }
}
