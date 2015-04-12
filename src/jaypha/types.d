//Written in the D programming language
/*
 * A bunch of aliases to make typing easier.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.types;

import std.range;
import std.traits;

//-----------------------------------------------------------------------------

alias string[string] strstr; // Much easier to work with without the [].

//-----------------------------------------------------------------------------
// Byte arrays and ranges utilise 'ubyte'. Used for octect streams and binary
// data. Also a convenient way to avoid UTF conversion issues.

alias immutable(ubyte)[] ByteArray;

enum isByteRange(R) = (isInputRange!(R) && is(ElementType!(R) : ubyte));

//-----------------------------------------------------------------------------
// UTF encoding based on D type.

enum utfEnc(C:char) = "UTF-8";
enum utfEnc(C:wchar) = "UTF-16";
enum utfEnc(C:dchar) = "UTF-32";
enum utfEnc(S:string) = "UTF-8";
enum utfEnc(S:wstring) = "UTF-16";
enum utfEnc(S:dstring) = "UTF-32";
