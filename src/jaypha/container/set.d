//Written in the D programming language
/*
 * Simple set implementation
 *
 * Copyright 2009-2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.set;

//----------------------------------------------------------------------------
// Simple collection where each element is unique.
//----------------------------------------------------------------------------
struct Set(E)
//----------------------------------------------------------------------------
{
  void put(E e)
  {
    foreach (i; theSet)
      if (e == i) return;
    
    theSet ~= e;
  }

  @property size_t size() { return theSet.length; }
  alias size length;

  @property auto range()
  {
    return theSet;
  }

  private:
    E[] theSet;
}

//----------------------------------------------------------------------------
// Like Set, but the elements are ordered, and the set is indexable.
//----------------------------------------------------------------------------
struct IndexableSet(E)
//----------------------------------------------------------------------------
{
  size_t put(E e)
  {
    foreach (i,j; theSet)
      if (e == j) return i;

    theSet ~= e;
    return theSet.length-1;
  }

  @property size_t size() { return theSet.length; }
  alias size length;

  E opIndex(size_t i) { return theSet[i]; }

  @property auto range()
  {
    return theSet;
  }

  private:
    E[] theSet;
}

alias IndexableSet OrderedSet;

//----------------------------------------------------------------------------

unittest
{
  Set!long set;

  assert(set.size == 0);

  set.put(5);
  assert(set.size == 1);
  set.put(7);
  assert(set.size == 2);
  set.put(5);
  assert(set.size == 2);

  assert(set.range == [5,7]);

  IndexableSet!long oSet;

  assert(oSet.size == 0);

  oSet.put(5);
  assert(oSet.size == 1);
  oSet.put(7);
  assert(oSet.size == 2);
  oSet.put(5);
  assert(oSet.size == 2);

  assert(oSet.range == [5,7]);
  assert(oSet[0] == 5);
  assert(oSet[1] == 7);
}
