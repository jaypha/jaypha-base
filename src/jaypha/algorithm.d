//Written in the D programming language
/*
 * Some algorithm routines and templates
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.algorithm;

public import std.algorithm;
import std.typecons, std.range, std.array, std.traits;

//-----------------------------------------------------------------------------
// Grabs as much of seq, unitl a character is found that matches choices
// according to the given predicate. Returns the first part while setting
// seq to the remainder (including the found character).

S1 grab(alias pred = "a == b",S1, S2)(ref S1 seq, S2 choices) if (isInputRange!S1 && isForwardRange!S2) 
{
  auto remainder = findAmong!(pred,S1,S2)(seq, choices);
  scope(exit) seq = remainder;
  return seq[0..$-remainder.length];
}

//-------------------------------------

unittest
{
  dstring s = "abcdefg";
  dstring c = "cg";

  auto x = grab(s,c);
  assert(x == "ab");
  assert(s.front == 'c');
  s = s[1..$];
  x = grab(s,c);
  assert(x == "def");
  assert(s.front == 'g');

  string t1 = "to be or not to be";
  auto t = grab(t1, "abc");
  assert(t == "to ");
  assert(t1 == "be or not to be");
}

//----------------------------------------------------------------------------
// Map-like algorithm that merges the index and values of an associative
// array.

template meld(alias fun)
{
  auto meld(A)(A t) if (isAssociativeArray!A)
  {
    return MeldResult!(fun, A)(t);
  }
}

private struct MeldResult(alias F, T:T[U],U)
{
  U[] val;
  T[U] home;
  
  this(T[U] t) { home = t; val = t.keys; }

  @property bool empty() { return (val.length == 0); }
  @property U front() { return F(val[0],home[val[0]]); }
  void popFront() { val = val[1..$]; }
}

//-------------------------------------

unittest
{
  string[string] x = [ "one":"1", "bee":"3", "john":"66" ];

  char[] z;
  auto y = x.meld!((a,b) => (a~b));
  while (!y.empty)
  {
    z ~= y.front;
    y.popFront();
    z ~= ",";
  }
  z = z[0..$-1];

  assert(cast(const(char)[])z == "one1,bee3,john66");
}

//----------------------------------------------------------------------------
// Returns everything in primary that is not in secondary

T[] diff(T)(T[] primary, T[] secondary)
{
  auto result = appender!(T[])();
  result.reserve(primary.length);

  foreach (t;primary)
  {
    if (!secondary.canFind(t))
      result.put(t);
  }

  return result.data;
}

//-------------------------------------

unittest
{
  auto t1 = [ 2, 12, 5, 25, 5, 7 ];
  auto t2 = [ 2, 3, 17, 5 ];

  auto t3 = diff(t1,t2);

  assert(t3 == [ 12, 25, 7 ]);
}

//----------------------------------------------------------------------------
// Alternative to std.alogrithm.findSplit usable with non-rewindable ranges.
// R1 is input range, R2 is slicable

auto findSplit(R1,R2)(ref R1 haystack, R2 needle) //if ((ElementType!R1 == ElementType!R2) && isInputRange!(R1) && hasSlicing!(R2))
{
  alias ElementType!R2 E;
  R2 firstPart, secondPart;

  while (true)
  {
    if (startsWith(needle, secondPart))
    {
      foreach (n; needle[secondPart.length .. $])
      {
        if (haystack.empty || haystack.front != n) break;
        secondPart ~= n;
        haystack.popFront();
      }
      if (needle.length == secondPart.length)
      {
        assert(equal(needle, secondPart));
        return tuple(firstPart, secondPart);
      }
      if (haystack.empty)
        return tuple(firstPart~secondPart, uninitializedArray!(R2)(0));
      else
      {
        secondPart ~= haystack.front;
        haystack.popFront();
      }
    }

    firstPart ~= secondPart[0];
    secondPart = secondPart[1..$];
  }
}

//-------------------------------------

unittest
{
  //import std.stdio;
  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  string haystack = "donabababcbxyz";
  string needle = "ababc";

  auto res = findSplit(haystack, needle);
  assert(res[0] == "donab");
  assert(res[1] == "ababc");
  assert(haystack == "bxyz");

  auto res2 = findSplit(haystack, needle);
  assert(res2[0] == "bxyz");
  assert(res2[1] == "");
  assert(haystack == "");

  haystack = "asdfjkewu";
  auto res3 = findSplit(haystack, "a");
  assert(res3[0] == "");
  assert(res3[1] == "a");
  assert(haystack == "sdfjkewu");
}

//----------------------------------------------------------------------------
// Similar to std.algorithm.map except that the mapping function is not a
// template parameter

struct rtMap(R,T) if(isInputRange!R)
{
  this(R range, T delegate(ElementType!R) mapper)
  {
    _range = range;
    _mapper = mapper;
    if (!_range.empty)
      _front = _mapper(_range.front);
  }

  @property T front() { return _front; }
  @property bool empty() { return _range.empty; }
  void popFront()
  {
    _range.popFront();
    if (!_range.empty)
      _front = _mapper(_range.front);
  }

  private:
    R _range;
    T _front;
    T delegate(ElementType!R) _mapper;
}

unittest
{
  uint m1(uint i) { return i+3; }
  uint m2(uint i) { return i+6; }

  uint[] src = [ 0, 4, 7 ];

  auto rmap = rtMap!(uint[], uint)(src, &m1);

  auto dest = appender!(uint[]);
  rmap.copy(dest);

  assert(dest.data == [ 3, 7, 10 ]);

  rmap = rtMap!(uint[], uint)(src, &m2);

  dest = appender!(uint[]);
  rmap.copy(dest);

  assert(dest.data == [ 6, 10, 13 ]);
}

//----------------------------------------------------------------------------

