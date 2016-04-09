# Jaypha Base

This project contains generic code that is used in many of my projects and is provided
separately to avoid repetition. The code in this package is usable on its own.

The functions here generally extend the functionality provided by Phobos.

#### Documentation

See docs/docs.html for reference documentation.

## Overview

#### Strings

altIndexOf - A quick and dirty alternative to indexOf. Only works with ASCII.  
grab - Grabs as much of the given string, until a character is found that is in a supplied pattern.  
isDigits - Are all characters digits?  
splitUp - Splits a string into substrings based on a group of possible delimiters.  
toCamelCase - Converts a string to camel case.  

#### JSON

fromJSON - Alternative ways to extract from a `JSONValue`.

#### Algorithms

meld - Map-like algorithm that merges the index and values of an associative array.  
rtMap - Similar to std.algorithm.map except that the mapping function provide at run-time rather than compile time.  
diff - Returns everything in one array that is not in another.  
findSplit - Alternative to std.alogrithm.findSplit usable with non-rewindable ranges.  

#### Ranges

ByChunk - Splits a range into chunks of given size. Doesn't work with narrow strings.  
ByLines - Splits a range into lines.  
munch - Consumes the front of the range as long the elements are inside pattern.  
drain - Consume the rest of the range.  

#### Random

rnd - A wrapper for rndGen to prevent copying, provided by monarch_dodra.  
rndHex - A randomly generated string of hex characters. Useful for filenames.  
rndId - A random string of lower case ASCII letters.  
rndString - A random string of ASCII printable characters. Useful for passwords.  

#### Conversions

binToHex - Converts an unsigned interger into a hex string.  
bitsToList - Extract the bits from a number and puts them into an array.  
listToBits - Reduces an array to a single value by bit-or-ing them together.  

#### Containers

Hash - Hash container.  
Queue - Simple queue  
Set - Simple set  
IndexableSet - Set whose elements can be accessed by index.  
Stack - Simple stack  

#### I/O

print - Functions that perform `write` like functionality, but with ranges rather than files.  
serialize - Converting data to and from compact strings for easy storage and transfer.

## License

Distributed under the Boost License.

## Contact

jason@jaypha.com.au

## Todo

Many functions could do with polishing, but are usable in the current state.

Documentation is an ongoing task.

## Current Problems

None known
