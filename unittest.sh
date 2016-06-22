#!/bin/bash

# Tests each file separately, which helps to flush out any import issues.

function traverse {
  l=`ls $1`
  for i in $l
  do
    if [ -d $1/$i ]
    then
      if [ ! -L $1/$i ]
      then
        traverse $1/$i
      fi
    else
      echo "testing $1/$i"
      rdmd -unittest -main -Isrc $1/$i
    fi
  done
}

traverse "./src"
