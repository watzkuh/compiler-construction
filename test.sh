#! /bin/sh

# This shell script is part of the C++ Bison Example
# (tests the calc++ program).
# Some changes made by Prof. R. C. Moore (fbi.h-da.de)

# See https://www.gnu.org/software/bison/manual/html_node/A-Complete-C_002b_002b-Example.html

# Copyright (C) 2005-2012 Free Software Foundation, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#test -z "$VERBOSE" && {
#   exec > /dev/null 2>&1
#   set -x
#}

echo && echo -e "\nTEST: Running a four line cac++ program..."
cat >input <<EOF
a := 4
b := 2
c := 19
d := a + b * c
d
EOF

./calc++ input

echo && echo -e "\nTEST: Running the same four line cac++ program with input from a pipe (stdin)..."
cat input | ./calc++ -

echo && echo -e "\nTEST: Running the same four line cac++ program with parse tracing turned on..."
./calc++ -p input



echo && echo -e "\nTEST: Running a cac++ program with undefined variables..."
cat >input <<EOF
a := 1
d := a + b * c
EOF
./calc++ input

echo && echo -e "\nTEST: Running a cac++ program with scanner (lexer) tracing turned on..."
cat >input <<EOF
toto := 1
toto
EOF
./calc++ -s input


rm input
