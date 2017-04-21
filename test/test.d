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
 * Unit tester for all modules in the project.
 * Be sure to add -Isrc and -unittest.
 *
 * Can be used with Dub
 * dub run --force --build=unittest --config=test
 */

import jaypha.types;
import jaypha.traits;
import jaypha.algorithm;
import jaypha.conv;
import jaypha.json;
import jaypha.range;
import jaypha.rnd;
import jaypha.string;
import jaypha.io.print;
import jaypha.io.serialize;
import jaypha.io.binarywriter;
import jaypha.container.hash;
import jaypha.container.queue;
import jaypha.container.set;
import jaypha.container.stack;

import std.stdio;

void main()
{
  writeln("All unittests passed");
}
