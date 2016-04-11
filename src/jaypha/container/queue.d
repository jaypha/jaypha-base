//Written in the D programming language
/*
 * Simple queue.
 *
 * Copyright 2009-2016 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.queue;

import std.array;

//----------------------------------------------------------------------------
struct Queue(E)
//----------------------------------------------------------------------------
{
  alias Queue!E Q;

  private:

    E[] theQueue;

  public:

    void put(E e)
    {
      theQueue ~= e;
    }

    Q opOpAssign(string op)(E e) if (op == "~")
    {
      theQueue ~= e;
      return this;
    }

    Q opOpAssign(string op)(E[] e) if (op == "~")
    {
      theQueue ~= e;
      return this;
    }

    Q opOpAssign(string op)(Q q) if (op == "~")
    {
      theQueue ~= q.theQueue;
      return this;
    }

    @property bool empty() { return theQueue.empty; }
    @property ref T front() { return theQueue.front(); }
    void popFront() { theQueue.popFront(); }
}

//----------------------------------------------------------------------------

unittest
{
  Queue!long queue;

  assert(queue.empty);

  queue.put(4);

  assert(!queue.empty);
  assert(queue.front == 4);

  queue.put(12);

  assert(queue.front == 4);

  queue.put(8);

  assert(queue.front == 4);

  queue.popFront();

  assert(queue.front == 12);

  queue.put(1);

  assert(queue.front == 12);

  queue.popFront();

  assert(queue.front == 8);

  queue.popFront();

  assert(queue.front == 1);

  queue.popFront();

  assert(queue.empty);

  queue.put(3);
  assert(queue.theQueue == [3]);
  queue ~= 4;
  assert(queue.theQueue == [3,4]);
  queue ~= [8,7];
  assert(queue.theQueue == [3,4,8,7]);

  Queue!long queue2;
  queue2 ~= [10,12];
  queue ~= queue2;  
  assert(queue.theQueue == [3,4,8,7,10,12]);
}

//----------------------------------------------------------------------------
