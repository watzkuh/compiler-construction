####################################################################
# This Makefile started out as a copy of the one in the flex manual.
# Cf. http://flex.sourceforge.net/manual/Makefiles-and-Flex.html#Makefiles-and-Flex
#
# It replaces the amazingly complex Makefile that comes with the C++calc example
# found in the Bison manual.
#
# This is Verison 0.2 of the Makefile (as of 17 April 2013, 22:00
# The previous (unnumbered) version only worked with MAKEFLAGS=-j3
# (and it's strange that it worked then).
#
####################################################################
#      "Variables", die hier benutzt werden:
#      Vgl. http://www.makelinux.net/make3/make3-CHP-2-SECT-2.html
# $@ = The filename representing the target.
# $< = The filename of the first prerequisite.
# $* = The stem of the filename of the target (i.e. without .o, .cpp...)
# $^ = The names of all the prerequisites, with spaces between them.
####################################################################
# Uncomment only one of the next two lines (choose your c++ compiler)
#CXX=g++
CXX=clang++

LEX=flex
YACC=bison
YFLAGS=-v -d
CPPFLAGS= -g -std=c++11 `llvm-config --ldflags --system-libs --libs core` 
# Wo   -d wichtig ist, weil damit Header-Dateien erzeugt werden
#         (*.hh - und nicht nur Quellcode in *.cc)
# aber -v nicht so wichtig ist, weil damit "nur" die  Datei
#         go-parser.output erzeugt wird, die zwar informativ aber nicht
#         unbedingt notwendig (sie wird nicht weiterverwendet).
LLVM-DEPENDENT=Node.cc AST_Node.cc go.cc go-driver.cc go-scanner.cc

HEADERS=go-parser.hh go-scanner.hh

#go : go.o go-scanner.o go-parser.o go-driver.o
$(LLVM-DEPENDENT):EXTRA_FLAGS=`llvm-config --cxxflags --ldflags --system-libs --libs core`
go :  go-parser.cc  $(LLVM-DEPENDENT)

%.o: %.cc
	$(CXX) $(CPPFLAGS) $(EXTRA_FLAGS) -o $@ -c $<

go-scanner.cc: go-scanner.ll
	$(LEX) $(LFLAGS) -o go-scanner.cc go-scanner.ll

go-parser.cc go-parser.hh: go-parser.yy
	$(YACC) $(YFLAGS) -o go-parser.cc go-parser.yy

clean:
	$(RM) *~ *.o  go  go-scanner.cc go-parser.cc  go-scanner.hh go-parser.hh go-parser.output location.hh stack.hh position.hh

tests: test.sh go
	./test/test.sh
