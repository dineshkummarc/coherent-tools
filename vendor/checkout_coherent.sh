#!/usr/bin/env sh
cd `dirname $0`
svn co http://coherent.googlecode.com/svn/trunk coherent
cd coherent
distil

