// Written in the D programming language.
/*
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.json;

//--------------------------------------------------------------------------
// Functons for comverting from a JSON value.

import std.array;
import std.conv;
public import std.json;
import std.traits;

T fromJSON(T)(JSONValue jVal) if (isScalarType!T || isSomeString!T)
{
  final switch (jVal.type)
  {
    case JSON_TYPE.TRUE:
      return to!T(true);
    case JSON_TYPE.FALSE:
      return to!T(false);
    case JSON_TYPE.INTEGER:
      return to!T(jVal.integer);
    case JSON_TYPE.UINTEGER:
      return to!T(jVal.uinteger);
    case JSON_TYPE.FLOAT:
      return to!T(jVal.floating);
    case JSON_TYPE.STRING:
      return to!T(jVal.str);
    case JSON_TYPE.OBJECT:
    case JSON_TYPE.ARRAY:
      assert(false);
    case JSON_TYPE.NULL:
      return T.init;
  }
}

//--------------------------------------------------------------------------

T[] fromJSON(T:T[])(JSONValue jVal) if (!isSomeString!(T[]))
{
  assert(jVal.type == JSON_TYPE.ARRAY);
  auto app = appender!(T[])();
  foreach (val; jVal.array)
    app.put(fromJSON!T(val));
  return app.data;
}

//--------------------------------------------------------------------------

T[string] fromJSON(T:T[string])(JSONValue jVal)
{
  assert(jVal.type == JSON_TYPE.OBJECT);
  T[string] ret;
  foreach (idx,val; jVal.object)
    ret[idx] = fromJSON!T(val);
  return ret;
}
