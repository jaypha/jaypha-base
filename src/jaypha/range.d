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
// strings (It might split a character in the middle).

struct ByChunk(R) if (!isNarrowString!R)
{
  alias Unqual!(ElementType!R) E;

  this(R range, size_t chunkSize)
  {
    front.length = chunkSize;
    rng = range;
    num = chunkSize;
    popFront();
  }

  E[] front;

  bool empty = false;

  void popFront()
  {
    if (empty) return;
    if (rng.empty)
    {
      front.length = 0;
      empty = true;
    }
    else foreach (i; 0..num)
    {
      if (rng.empty) { front.length = i; break; }
      front[i] = rng.front;
      rng.popFront();
    }
  }

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

//----------------------------------------------------------------------------

struct ByLines(R) if (isInputRange!R && isSomeChar!(ElementType!R))
{
  alias ElementType!R Char;

  private:
    R r;
    Char[] line;

  public:
    bool empty = false;
    string eoln;

  this(R _r) { r = _r; popFront(); }

  void popFront()
  {
    assert(!empty);
    if (r.empty)
      empty =true;
    else
    {
      auto napp = appender!(Char[])();

      Char[] ln;
      while (!r.empty && r.front != '\n')
      {
        napp.put(r.front);
        r.popFront();
      }
      if (!r.empty) r.popFront();
      ln = napp.data;
      if (ln.length > 0 && ln[ln.length-1] == '\r')
      {
        eoln = "\r\n";
        line = ln[0..$-1];
      }
      else
      {
        eoln = "\n";
        line = ln;
      }
    }
  }

  @property Char[] front()
  {
    return line;
  }
}

ByLines!R byLines(R)(R range)
{
  return ByLines!R(range);
}

//----------------------------------------------------------------------------

unittest
{
  import std.conv;

  // Detect if D behaviour changes.

  assert("" !is null);
  assert([] is null);


  char[] a = "abc".dup;
  assert(a[0..0] !is null);
  assert(a[0..0].length == 0);
  a.length = 0;
  assert(a !is null);

  // Ripped off from Phobos.
  void test(string txt, string[] witness)
  {
    //writeln("testing '",txt,"'");
    auto r1 = inputRangeObject(txt);

    static assert(isInputRange!(typeof(r1)));
    static assert(is(typeof(r1) : InputRange!(dchar)));

    auto lines = new ByLines!(typeof(r1))(r1);
    uint i;
    //*
    while (!lines.empty)
    {
      assert(i<witness.length, text(i, ">=", witness.length));
      //writeln("str: '",lines.front,"'");
      assert(to!string(lines.front) == witness[i++]);
      lines.popFront();
    }
    /*/
    foreach (line; lines)
    {
      assert(i<witness.length, text(i, ">=", witness.length));
      assert(to!string(line) == witness[i++]);
    }
    /**/
    assert(i == witness.length, text(i, " != ", witness.length));
  }

  test("", null);
  test("\n", [ "" ]);
  test("asd\ndef\nasdf", [ "asd", "def", "asdf" ]);
  test("asd\ndef\nasdf\n", [ "asd", "def", "asdf" ]);
  test("asd\n\nasdf\n", [ "asd", "", "asdf" ]);
  test("asd\r\ndef\r\nasdf\r\n", [ "asd", "def", "asdf" ]);
  test("asd\r\n\r\nasdf\r\n", [ "asd", "", "asdf" ]);
}

//----------------------------------------------------------------------------
