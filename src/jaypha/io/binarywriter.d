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

  void put(void[] b)
  { fwrite(b.ptr,1, b.length, s.getFP()); }
}

unittest
{
  auto f = File.tmpfile();
  auto w = BinaryWriter(f);

  w.put(cast(ubyte)23);
  w.put(cast(ubyte)46);
  ubyte[] x = [12,101];
  w.put(x);
  f.flush();
  f.rewind();

  assert(f.size == 4);
  auto r = f.rawRead(new ubyte[4]);
  assert(r == [23,46,12,101]);
}
