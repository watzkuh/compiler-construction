/***********************
 * Example of C++ in Bison (yacc) 
 * Compare Bison Manual, Section 10.1.6 A Complete C++ Example
 * https://www.gnu.org/software/bison/manual/html_node/A-Complete-C_002b_002b-Example.html
 * The Makefile has been simplified radically, but otherwise
 * everything here comes from the Bison source code (see also).
 * (This comment added by Prof. R. C. Moore, fbi.h-da.de)
 *
 * This is the (f)lex file, i.e. token definitions
 * See also calc++-parser.yy for the parser (grammar)
 * (yacc/bison input).
 *
 ***********************/

%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "go-driver.hh"
# include "go-parser.hh"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1

// The location of the current token.
static yy::location loc;
%}
%option noyywrap nounput batch debug noinput
digit	[0-9]
letter	[a-zA-Z]

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
  // Code run each time yylex is called.
  loc.step ();
%}

"//".*				{}

[ \t]+   loc.step ();
[\n]+      loc.lines (yyleng); loc.step ();
"package"      return yy::go_parser::make_PACKAGE(loc);
"import"      return yy::go_parser::make_IMPORT(loc);
"func"		return yy::go_parser::make_FUNC(loc);
"."		return yy::go_parser::make_DOT(loc);
","		return yy::go_parser::make_COMMA(loc);
"+"		return yy::go_parser::make_PLUS(loc);
"-"		return yy::go_parser::make_MINUS(loc);
"*"		return yy::go_parser::make_MUL(loc);
"/"		return yy::go_parser::make_DIV(loc);
"="		return yy::go_parser::make_EQUALS(loc);
";"      return yy::go_parser::make_SEMICOLON(loc);
"("      return yy::go_parser::make_PARL(loc);
")"      return yy::go_parser::make_PARR(loc);
"{"		return yy::go_parser::make_CURL(loc);
"}"		return yy::go_parser::make_CURR(loc);
"var"		return yy::go_parser::make_VAR(loc);
"int"		return yy::go_parser::make_TYPEINT(loc);
"float"		return yy::go_parser::make_TYPEFLOAT(loc);
"rune"		return yy::go_parser::make_TYPERUNE(loc);
"bool"		return yy::go_parser::make_TYPEBOOL(loc);
"string"	return yy::go_parser::make_TYPESTRING(loc);

{letter}({letter}|{digit})*	return yy::go_parser::make_ID(yytext, loc);
{digit}+					{return yy::go_parser::make_LITINT(yytext, loc);}
{digit}+"."{digit}+			{return yy::go_parser::make_LITFLOAT(yytext, loc);}
"'"(letter|digit)"'"		{return yy::go_parser::make_LITRUNE(yytext, loc);}
["true""false"]				{return yy::go_parser::make_LITBOOL(yytext, loc);}
\"({letter}|{digit})*\"	return yy::go_parser::make_LITSTRING(yytext, loc);


.          driver.error (loc, "invalid character");
<<EOF>>    return yy::go_parser::make_END(loc);
%%

void go_driver::scan_begin ()
{
  yy_flex_debug = trace_scanning;
  if (file.empty () || file == "-")
    yyin = stdin;
  else if (!(yyin = fopen (file.c_str (), "r")))
    {
      error ("cannot open " + file + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
}

void go_driver::scan_end ()
{
  fclose (yyin);
}

