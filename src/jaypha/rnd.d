//Written in the D programming language
/*
 * Wrapper for std.random.rndGen and some useful routines.
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.rnd;

import std.array;
import std.ascii;
import std.random;

//-----------------------------------------------------------------------------
// A wrapper for rndGen to prevent copying, provided by monarch_dodra.

struct Rnd
{
  enum empty = false;
  void popFront()
  {
    rndGen.popFront();
  }
  @property auto front()
  {
    return rndGen.front;
  }
}

@property Rnd rnd() { return Rnd(); }

//-----------------------------------------------------------------------------
// A randomly generated string of hex characters. Useful for filenames.

string rndHex(size_t size)
{
  return rndString(size, hexDigits);
}

//-----------------------------------------------------------------------------
// A random string of ASCII printable characters. Useful for passwords.

string rndString(size_t size)
{
  auto bytes = appender!string();
  bytes.reserve(size);
  foreach (j; 0..size)
    bytes.put(cast(char) uniform(33, 126));
  return bytes.data;
}

//-----------------------------------------------------------------------------
// A random string of characters selected from the given set.

string rndString(size_t size, const char[] allowableChars)
{
  auto bytes = appender!string();
  bytes.reserve(size);
  foreach (j; 0..size)
    bytes.put(allowableChars[uniform(0,allowableChars.length)]);
  return bytes.data;
}

//-----------------------------------------------------------------------------
// A random string of lower case ASCII letters.

string rndId(size_t size)
{
  return rndString(size,lowercase);
}

unittest
{
  import jaypha.string;

  string set = "ushjvko28&";
  string rs = rndString(100,set);
  foreach (x;rs)
    assert(altIndexOf(set,x) != set.length);

  rs = rndHex(100);
  foreach (x;rs)
    assert(altIndexOf(hexDigits,x) != hexDigits.length);

  rs = rndId(100);
  foreach (x;rs)
    assert(altIndexOf(lowercase,x) != lowercase.length);
}
