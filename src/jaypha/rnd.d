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

import std.random;
import std.array;

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

Rnd rnd() { return Rnd(); }

//-----------------------------------------------------------------------------
// A randomly generated string of hex characters. Useful for filenames.

string rndHex(size_t size)
{
  static immutable char[16] hex = "0123456789ABCDEF";

  auto bytes = appender!string();
  bytes.reserve(size);
  foreach (j; 0..size)
    bytes.put(hex[uniform(0,16)]);
  return bytes.data;
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
// A random string of lower case ASCII letters.

string rndId(size_t size)
{
  auto bytes = appender!string();
  bytes.reserve(size);
  foreach (j; 0..size)
    bytes.put(cast(char) uniform(97, 123));
  return bytes.data;
}