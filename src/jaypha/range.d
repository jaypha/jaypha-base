//Written in the D programming language
/*
 * Some rountines for use with ranges
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.range;

import std.algorithm;
public import std.range;
import std.traits;
import std.exception;

//----------------------------------------------------------------------------
// Consumes the front of the range as long the elements are inside pattern.

void munch(R,E)(ref R range, E pattern)
  if (isInputRange!R && isInputRange!E &&
      isScalarType!(ElementType!E) && isScalarType!(ElementType!R))
{
  alias ElementType!E T;
  while (!range.empty && !find(pattern, cast(T)range.front).empty)
    range.popFront();
}

//----------------------------------------------------------------------------
// Consume the rest of the range.

void drain(R)(ref R r) if (isInputRange!R)
{
  while (!r.empty) r.popFront();
}

//----------------------------------------------------------------------------
// Splits a range into chunks of given size. Doesn't work with narrow
// strings.

struct ByChunk(R) if (!isNarrowString!R)
{
  this(R range, size_t chunkSize) { rng = range; num = chunkSize; }

  @property bool empty() { return rng.empty; }

  @property R front() { return rng.take(num); }

  void popFront() { rng = rng.drop(num); }

  private:
    R rng;
    size_t num;

}

ByChunk!R byChunk(R)(R range, size_t chunkSize)
{
  return ByChunk!R(range,chunkSize);
}


//----------------------------------------------------------------------------

unittest
{
  import std.stdio;

  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;
  auto buff = appender!(ubyte[]);

  auto r1 = inputRangeObject(txt);
  assert(!r1.empty);
  r1.drain();
  assert(r1.empty);

  r1 = inputRangeObject(txt);
  r1.munch("abc");
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "xyz");

  buff.clear();

  dstring ds =  "acaba";

  auto bc = byChunk(ds, 3);
  assert(bc.front == "aca"d);
  bc.popFront();
  assert(bc.front == "ba"d);
  bc.popFront();
  assert(bc.empty);
}
