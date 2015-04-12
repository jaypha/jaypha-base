//Written in the D programming language
/*
 * String utilities
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.string;

import std.string;
import std.uni;
import std.array;
import std.c.string;

//-----------------------------------------------------------------------------
// A quick and dirty alternative indexOf. Only works with ASCII.

size_t altIndexOf(string s, char c)
{
  auto p = cast(char*)memchr(s.ptr, c, s.length);
  return (p?p - s.ptr:s.length);
}

//----------------------------------------------------------------------------
// Are all characters digits?

@safe pure nothrow bool isDigits(string text)
{
  import std.ascii;

  foreach (c; text)
    if (!isDigit(c))
      return false;
  return true;
}

//----------------------------------------------------------------------------
// Splits a string into substrings based on a group of possible delimiters.

string[] splitUp(string text, const(char)[] delimiters)
{
  string[] result = [];
  size_t start = 0;

  foreach(i; 0..text.length)
    if (indexOf(delimiters, text[i]) != -1)
    {
      result ~= text[start..i];
      start = i+1;
    }
  result ~= text[start..$];

  return result;
}

//----------------------------------------------------------------------------
// Converts a string to camel case.

@trusted pure string toCamelCase(string text, bool first = true)
{
  auto result = appender!string();

  foreach (ch; text)
  {
    if (ch == '_' || ch == ' ')
    {
      first = true;
    }
    else if (first)
    {
      result.put(toUpper(ch));
      first = false;
    }
    else
    {
      result.put(ch);
    }
  }
  return result.data;
}

//----------------------------------------------------------------------------

unittest
{
  assert(toCamelCase("abc_def pip") == "AbcDefPip");
  assert(toCamelCase("xyz_tob", false) == "xyzTob");
  assert(toCamelCase("123_456", false) == "123456");

  auto result = splitUp("to be or not to be", " e");
  assert(result.length == 8);
  assert(result[0] == "to");
  assert(result[1] == "b");
  assert(result[2] == "");
  assert(result[3] == "or");
  assert(result[4] == "not");
  assert(result[5] == "to");
  assert(result[6] == "b");
  assert(result[7] == "");

  auto t1 = "abcdefghijklmnop";
  assert(altIndexOf(t1,'f') == 5);
  assert(altIndexOf(t1,'a') == 0);
  assert(altIndexOf(t1,'$') == t1.length);

  assert(isDigits("02351"));
  assert(!isDigits("0x03"));
  assert(!isDigits("-1"));
  assert(!isDigits("1-"));
}
