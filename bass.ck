Mandolin bass => NRev r => ADSR e => dac;

(10::ms,90::ms, 0,1::ms) => e.set;
[41,43,48,42] @=> int scale[];

0.02 => r.mix;

0.0 => bass.stringDamping;
0.02 => bass.stringDetune;
0.05 => bass.bodySize;
0 => int walkPosition;

while(true) {
  1 +=> walkPosition;
  (walkPosition + 4) %4 => walkPosition;
  Std.mtof(scale[walkPosition]) - 12 => bass.freq;
  1 => bass.noteOn;
  1 => e.keyOn;
  100 ::ms => now;
  1 => bass.noteOff;
  1 => e.keyOff;
  20 ::ms => now;
  
  }

