//Written in the D programming language
/*
 * Some rountines for use with ranges
 *
 * Copyright (C) 2013-6 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.range;

import std.algorithm;
import std.range.primitives;
import std.traits;
import std.exception;

enum defaultBufferSize = 8192;

public import jaypha.algorithm : munch;

//----------------------------------------------------------------------------
// Consume the rest of the range.

void drain(R)(ref R r) if (isInputRange!R)
{
  while (!r.empty) r.popFront();
}

//----------------------------------------------------------------------------
// Splits a range into chunks of given size. Doesn't work with narrow
// strings (It might split a character in the middle).

struct ByChunk(R) if (isInputRange!R && !isNarrowString!R)
{
  alias Unqual!(ElementType!R) E;

  this(R range, size_t chunkSize = defaultBufferSize)
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
      empty = true;
    }
    else
    {
      front = new E[num];
      foreach (i; 0..num)
      {
        if (rng.empty) { front.length = i; break; }
        front[i] = rng.front;
        rng.popFront();
      }
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
  import std.array;
  import std.range.interfaces;

  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;
  auto buff = appender!(ubyte[]);

  auto r1 = inputRangeObject(txt);
  assert(!r1.empty);
  r1.drain();
  assert(r1.empty);

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

struct ByLines(R)
  if (isInputRange!R && (isSomeChar!(ElementType!R) || is(ElementType!R : ubyte)))
{
  import std.array;

  alias ElementType!R E;

  private:
    R r;
    E[] line;

  public:
    bool empty = false;
    string eoln = "x";

  this(R _r) { r = _r; popFront(); }

  void popFront()
  {
    assert(!empty);
    if (eoln == "")
      empty =true;
    else
    {
      auto napp = appender!(E[])();

      E[] ln;
      while (!r.empty && r.front != '\n' && r.front != '\r')
      {
        napp.put(r.front);
        r.popFront();
      }
      if (!r.empty)
      {
        auto c = r.front; r.popFront();
        if (c == '\r')
        {
          if (r.front == '\n')
          {
            r.popFront();
            eoln = "\r\n";
          }
          else
            eoln = "\r";
        }
        else
          eoln = "\n";
      }
      else
        eoln = "";

      line = napp.data;
    }
  }

  @property E[] front()
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
    import std.range.interfaces;

    auto r1 = inputRangeObject(txt);

    static assert(isInputRange!(typeof(r1)));
    static assert(is(typeof(r1) : InputRange!(dchar)));

    auto lines = new ByLines!(typeof(r1))(r1);
    uint i;

    while (!lines.empty)
    {
      assert(i<witness.length, text(i, ">=", witness.length));
      assert(to!string(lines.front) == witness[i++]);
      lines.popFront();
    }
    assert(i == witness.length, text(i, " != ", witness.length));
  }

  test("", [ "" ]);
  test("\n", [ "", "" ]);
  test("asd\ndef\nasdf", [ "asd", "def", "asdf" ]);
  test("asd\ndef\nasdf\n", [ "asd", "def", "asdf", "" ]);
  test("asd\n\nasdf\n", [ "asd", "", "asdf", "" ]);
  test("asd\r\ndef\r\nasdf\r\n", [ "asd", "def", "asdf", "" ]);
  test("asd\r\n\r\nasdf\r\n", [ "asd", "", "asdf", "" ]);
}

//----------------------------------------------------------------------------
// Buffered output. Sort of like a ByChunk for output ranges.

struct Buffered(W,E, size_t bufferSize = defaultBufferSize) if (isOutputRange!(W,E[]) && bufferSize < 16777216)
{
  this(W w)
  {
    writer = w;
    length = 0;
  }

  void put(E e)
  {
    if (length == bufferSize)
    {
      writer.put(buffer[0..$]);
      length = 0;
    }
    buffer[length] = e;
    ++length;
  }

  void put(E[] e)
  {
    if (length + e.length > bufferSize)
    {
      if (length)
      {
        writer.put(buffer[0..length]);
        length = 0;
      }
      if (e.length > bufferSize)
      {
        writer.put(e);
        return;
      }
    }
    buffer[length..(length+e.length)] = e;
    length += e.length;
  }

  void flush()
  {
    writer.put(buffer[0..length]);
    length = 0;
  }

  private:
    W writer;
    E[bufferSize] buffer;
    size_t length;
}

auto ref buffered(E, size_t bufferSize = defaultBufferSize, W)(W writer)
{
  return Buffered!(W,E,bufferSize)(writer);
}

unittest
{
  import std.array;

  auto a = appender!(int[])();

  auto b = buffered!(int,10)(a);

  b.put(12);
  assert(a.data == []);
  b.flush();
  assert(a.data == [12]);
  b.put([5,13,6,9,1,0]);
  assert(a.data == [12]);
  b.put(3); b.put([55,13]); b.put(20);
  assert(a.data == [12]);
  b.put(11);
  assert(a.data == [12,5,13,6,9,1,0,3,55,13,20]);
  b.put([34,1,24,42,11,0,67]);
  assert(a.data == [12,5,13,6,9,1,0,3,55,13,20]);
  b.put([100,9,43,40]);
  assert(a.data == [12,5,13,6,9,1,0,3,55,13,20,11,34,1,24,42,11,0,67]);
  b.put([9,8,7,6,5,4,3,2,1,0,-1]);
  assert(a.data == [12,5,13,6,9,1,0,3,55,13,20,11,34,1,24,42,11,0,67,100,9,43,40,9,8,7,6,5,4,3,2,1,0,-1]);
  b.put([19,28,37,46,55,64,73,82,91,102,13]);
  assert(a.data == [12,5,13,6,9,1,0,3,55,13,20,11,34,1,24,42,11,0,67,100,9,43,40,9,8,7,6,5,4,3,2,1,0,-1,19,28,37,46,55,64,73,82,91,102,13]);
}

//----------------------------------------------------------------------------
// Provides "ungetc" for input ranges.

struct UnPopable(R) if (isInputRange!R)
{
  import jaypha.container.stack;

  alias ElementType!R E;

  R range;

  @property bool empty()
  {
    return range.empty && store.empty;
  }

  @property E front()
  {
    if (!store.empty)
      return store.front();
    else
      return range.front();
  }

  void popFront()
  {
    if (!store.empty)
      store.popFront();
    else range.popFront();
  }

  void unPopFront(E e)
  {
    store.put(e);
  }

  private:
    Stack!E store;
}

auto ref unPopable(R)(R range)
{
  return UnPopable!R(range);
}

unittest
{
  string s = "abôd";

  auto r = unPopable(s);

  assert(!r.empty);
  assert(r.front == 'a');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'b');
  r.unPopFront('x');
  assert(!r.empty);
  assert(r.front == 'x');
  r.unPopFront('y');
  assert(!r.empty);
  assert(r.front == 'y');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'x');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'b');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'ô');
  r.unPopFront('z');
  assert(!r.empty);
  assert(r.front == 'z');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'ô');
  r.popFront();
  assert(!r.empty);
  assert(r.front == 'd');
  r.popFront();
  assert(r.empty);
  r.unPopFront('本');
  assert(!r.empty);
  assert(r.front == '本');
  r.popFront();
  assert(r.empty);
}
