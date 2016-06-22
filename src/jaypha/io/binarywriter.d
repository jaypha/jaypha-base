//Written in the D programming language
/*
 * Copyright 2016 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.io.binarywriter;

public import std.stdio;

/*
 * Am output range writer for binary output to files.
 */

struct BinaryWriter
{
  import core.stdc.stdio;
  import std.range.primitives;
  import std.traits;

  File s;

  void put(T)(T b) if (isBasicType!T)
  { fwrite(&b,T.sizeof,1,s.getFP()); }

  void put(T)(ref T b) if (isArray!T && isBasicType!(ElementEncodingType!T))
  { fwrite(b.ptr, (ElementEncodingType!T).sizeof, b.length, s.getFP()); }
}

unittest
{
  auto f = File.tmpfile();
  auto w = BinaryWriter(f);

  w.put(cast(ubyte)23);
  w.put(cast(ubyte)46);
  uint[] x = [12,101];
  w.put(x);
  f.flush();
  f.rewind();

  assert(f.size == 10);
  auto r = f.rawRead(new ubyte[10]);
  assert(r == [23,46,12,0,0,0,101,0,0,0]);
}
