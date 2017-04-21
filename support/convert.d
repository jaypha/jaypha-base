//Written in the D programming language
/*
 * Copyright: Copyright (C) 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

import std.json;
import std.array;
import std.algorithm;
import std.stdio;

// This utitlity is used to convert MIME type info that was downloaded
// from the Internet in a JSON file, to D code.

void main()
{
  auto b = appender!string();
  stdin.byLine().copy(b);

  JSONValue input;
  try { input = parseJSON(b.data); }
  catch (JSONException e)
  { writeln("Bad JSON: "~e.msg); return; }

  writeln("[");

  foreach(jp; input.array)
  {
    foreach (x,y ; jp.object)
    {
      auto ext = x[1..$];
      writeln("  \"",ext,"\" : ",y,",");
    }
  }
  writeln("];");
}
