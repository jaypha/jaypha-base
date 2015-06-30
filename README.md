Jaypha Base
===========

This project contains generic code that is used in many of my projects and is provided
separately to avoid repetition. The code in this package is usable on its own.

The functions here generally extend the functionality provided by Phobos.

Documentation
-------------

See doc.html for reference documentation.

Modules
-------

All my modules are kept under the 'jaypha' umbrella package.

List of Functions
-----------------

altIndexOf - A quick and dirty alternative to indexOf. Only works with ASCII.
binToHex - Converts an unsigned interger into a hex string.
bitsToList - Extract the bits from a number and puts them into an aray.
ByChunk - Splits a range into chunks of given size. Doesn't work with narrow strings.
byChunk - Convenience function for returning ByChunk structs.
diff - Returns everything in one array that is not in another.
drain - Consume the rest of the range.
findSplit - Alternative to std.alogrithm.findSplit usable with non-rewindable ranges.
grab - Grabs as much of the given string, until a character is found that is in a supplied pattern.
isDigits - Are all characters digits?
listToBits - Reduces an array to a single value by or-ing them together.
meld - Map-like algorithm that merges the index and values of an associative array.
munch - Consumes the front of the range as long the elements are inside pattern.
rnd - A wrapper for rndGen to prevent copying, provided by monarch_dodra.
rndHex - A randomly generated string of hex characters. Useful for filenames.
rndId - A random string of lower case ASCII letters.
rndString - A random string of ASCII printable characters. Useful for passwords.
rtMap - Similar to std.algorithm.map except that the mapping function is not a template parameter.
splitUp - Splits a string into substrings based on a group of possible delimiters.
toCamelCase - Converts a string to camel case.

License
-------

Distributed under the Boost License.

Contact
-------

jason@jaypha.com.au

Todo
----

Many functions could do with polishing, but are usable in the current state.

Current Problems
----------------

None known
