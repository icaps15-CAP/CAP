#!/bin/bash

autoreconf -i -f
mkdir build
cd build
../configure
make
