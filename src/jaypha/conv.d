//Written in the D programming language
/*
 * Conversion routines.
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.conv;

//----------------------------------------------------------------------------
// Converts an unsigned interger into a hex string.

alias binToHex bin2hex;

@safe pure nothrow string binToHex(T)(T i) if(__traits(isUnsigned,T))
{
  enum size = T.sizeof * 2;

  static immutable char[16] hex = "0123456789ABCDEF";
  char[size] x;
  foreach(j;0..size)
  {
    x[size-(j+1)] = hex[i%16];
    i = i >>> 4;
  }
  return x.idup;
}


//----------------------------------------------------------------------------
// Extract the bits from a number and puts them into an array.
// eg. 01101b => [ 1000b, 100b, 1b ].

@safe pure nothrow T[] bitsToList(T)(T bits) if(__traits(isIntegral,T) && __traits(isUnsigned,T))
{
  T c = 1;
  T[] r;

  while (bits != 0)
  {
    if (bits & 1)
      r ~= c;
    bits = bits >>> 1;
    c = c << 1;
  }
  return r;
}

//----------------------------------------------------------------------------
// Reduces an array to a single value by or-ing them together.

@safe @nogc pure nothrow T listToBits(T)(T[] list) if(__traits(isIntegral,T) && __traits(isUnsigned,T))
{
  // TODO explore using std.algorithm.reduce.
  T bits;

  foreach (l;list)
  {
    bits |= l;
  }
  return bits;
}

//----------------------------------------------------------------------------

unittest
{
  assert(binToHex(10u) == "0000000A");
  assert(binToHex(10uL) == "000000000000000A");
  assert(binToHex(0xB4C58A6Eu) == "B4C58A6E");
  assert(binToHex(0x8765432u)  == "08765432");
  assert(binToHex(0x4B8DA00Cu) == "4B8DA00C");
  assert(bitsToList(0x7Au) == [ 2, 8, 16, 32, 64 ]);
  assert(listToBits([ 64u, 32, 16,  8, 2 ]) == 0x7A);
}
