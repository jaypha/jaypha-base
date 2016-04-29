//Written in the D programming language
/*
 * Some algorithm routines and templates
 *
 * Copyright 2013-6 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.algorithm;

import jaypha.traits;

import std.range.primitives;

public import std.algorithm;
import std.typecons, std.range, std.array, std.traits;


//----------------------------------------------------------------------------
// Consumes the front of the range as long the elements are inside pattern.

auto munch(alias pred = "a == b", R1,R2)(ref R1 range, R2 pattern)
  if (isInputRange!R1 && isInputRange!R2 &&
      isScalarType!(ElementType!R2) && isScalarType!(ElementType!R1))
{
  alias ElementType!R1 E1;
  alias ElementType!R2 E2;

  auto a = appender!(E1[]);

  for (; !range.empty && !find!pred(pattern, cast(E2)range.front).empty; range.popFront())
    a.put(range.front);

  return a.data;
}

unittest
{
  import std.array;
  import std.range.interfaces;

  ubyte[] txt = cast(ubyte[]) "acabbacbxyz".dup;

  txt.munch("abc");
  assert(txt == "xyz");
}

//-----------------------------------------------------------------------------
// Grabs as much of seq, unitl a character is found that matches choices
// according to the given predicate. Returns the first part while setting
// seq to the remainder (including the found character).

auto grab(alias pred = "a == b", R1, R2)(ref R1 seq, R2 choices)
  if (!hasSlicing!R1 && isInputRange!R1 && isForwardRange!R2)
{
  alias ElementType!R1 E;

  auto a = appender!(E[]);

  for (; !seq.empty && find!pred(choices, seq.front).empty; seq.popFront())
    a.put(seq.front);
  return a.data;
}


S1 grab(alias pred = "a == b",S1, S2)(ref S1 seq, S2 choices)
  if (hasSlicing!S1 && isForwardRange!S2)
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

  auto y = x.meld!((a,b) => (a~b));
  string[] yy = new string[](3);
  y.copy(yy);
  sort(yy);  // Do sort to make the order predictable
  assert(yy == ["bee3","john66","one1"]);
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

auto findSplit(R1,R2)(ref R1 haystack, R2 needle)
  if (isInputRange!R1 && isDynamicArray!R2 && isComparable!(R1,R2))
{
  import std.string : chomp;
  import std.algorithm.searching : endsWith;

  assert(needle.length > 0);
  auto store = appender!R2();
  while (!haystack.empty)
  {
    store.put(haystack.front);
    haystack.popFront();
    if (store.data.endsWith(needle))
      return tuple(store.data.chomp(needle),needle);
  }
  return tuple(store.data, uninitializedArray!(R2)(0));
}

//-------------------------------------

unittest
{
  import std.stdio;
  string haystack = "donôbôbôbcbxyz";
  string needle = "ôbôbc";

  auto res = findSplit(haystack, needle);
  assert(res[0] == "donôb");
  assert(res[1] == "ôbôbc");
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

  haystack = "";
  auto res4 = findSplit(haystack, "p");
  assert(res4[0] == "");
  assert(res4[1] == "");
  assert(haystack == "");
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

