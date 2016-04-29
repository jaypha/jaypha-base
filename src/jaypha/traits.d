//Written in the D programming language
/*
 * Some extra constraints.
 *
 * Copyright 2016 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.traits;

import std.traits;
import std.functional;
import std.range.primitives;

enum isByteRange(R) = (isInputRange!R && is(Unqual!(ElementType!R) : ubyte));

enum isComparable(T1,T2, alias pred = "a == b") = is (typeof(
  (inout int = 0)
  {
    bool x = binaryFun!pred(T1.init,T2.init);
  }
));

unittest
{
  struct R1 { bool x; }
  struct R2 { uint y; }
  static assert(isComparable!(int, long));
  static assert(!isComparable!(R1,R2));
}
