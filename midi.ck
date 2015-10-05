MidiIn min;
MidiMsg msg;

// open midi receiver, exit on fail
if ( !min.open(0) ) me.exit(); 
Bowed bow => dac;
0 => int count;
while( true )
{
    // wait on midi event
    min => now;

    // receive midimsg(s)
    while( min.recv( msg ) )
    {
    if(msg.data1 != 248) {
        <<< count >>>;
        0 => count;
        }
    else {
      count++;
      }
    }
}
