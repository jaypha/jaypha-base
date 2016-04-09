//Written in the D programming language
/*
 * Copyright 2016 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module test;

/*
 * Universal unittester.
 * Be sure to add -Isrc and -unittest.
 */

import jaypha.types;
import jaypha.algorithm;
import jaypha.conv;
import jaypha.json;
import jaypha.range;
import jaypha.rnd;
import jaypha.string;
import jaypha.io.print;
import jaypha.io.serialize;
import jaypha.container.hash;
import jaypha.container.queue;
import jaypha.container.set;
import jaypha.container.stack;

import std.stdio;

void main()
{
  writeln("All unittests passed");
}
