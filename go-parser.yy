/***********************
 * Example of C++ in Bison (yacc)
 * Compare Bison Manual, Section 10.1.6 A Complete C++ Example
 * https://www.gnu.org/software/bison/manual/html_node/A-Complete-C_002b_002b-Example.html
 * The Makefile has been simplified radically, but otherwise
 * everything here comes from the Bison source code (see also).
 * (This comment added by Prof. R. C. Moore, fbi.h-da.de)
 *
 * This is the yacc (bison) file, i.e. grammar file.
 * See also calc++-scanner.ll for the lexical scanner 
 * (flex input).
 *
 ***********************/

%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.2"
%defines
%define parser_class_name {go_parser}

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
# include <string>
class Node;
class go_driver;
}

// The parsing context.
%param { go_driver& driver }

%locations
%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace
%define parse.error verbose

%code
{
# include "go-driver.hh"
# include "Node.hh"
}

%define api.token.prefix {TOK_}
%token
  END  0  "end of file"
  SEMICOLON  ";"
  IMPORT   "import"
  PACKAGE    "package"
  PLUS	"+"
  MINUS	"-"
  MUL	"*"
  DIV	"/"
  EQUALS	"="
  DOT	"."
  COMMA ","
  PARL  "("
  PARR  ")"
  CURL	"{"
  CURR	"}"
  VAR	"var"
  TYPEINT "int"
  TYPEFLOAT "float"
  TYPERUNE	"rune"
  TYPEBOOL	"bool"
  TYPESTRING "string"
  FUNC	"func"
;
%left PLUS MINUS;
%left MUL DIV;
%token <std::string> ID "identifier"
%token <std::string> LITSTRING "string literal"
%token <std::string> LITINT "integer literal"
%token <std::string> LITFLOAT "float literal"
%token <std::string> LITRUNE "rune literal"
%token <std::string> LITBOOL "bool literal"
%type<Node*> unit package_clause import_clause import_list_entry 
top_level_declaration var_declaration func_declaration 
type para_signature  return_signature statement_list expression
function_call exp parameter_list lit
;
%printer { yyoutput << $$; } <*>;

%%
%start unit;
unit: 				package_clause import_clause top_level_declaration{
					Node *tmp = new Node("sourcefile");
					tmp->addChild($1);
					tmp->addChild($2);
					tmp->addChild($3);
					driver.root = tmp;
};

package_clause:		PACKAGE ID SEMICOLON{
					Node *tmp = new Node("package_clause");
					tmp->addChild(new Node("id"));
					$$ = tmp;
};

import_clause:		%empty {$$ = nullptr;}
					|IMPORT LITSTRING SEMICOLON import_clause{
						Node *tmp = new Node("import_clause");
						tmp->addChild(new Node("litString"));
						tmp->addChild($4);
						$$ = tmp;
					}
					|IMPORT PARL import_list_entry PARR import_clause{
						Node *tmp = new Node("import_clause");
						tmp->addChild($3);
						tmp->addChild($5);
						$$ = tmp;
					};

import_list_entry:	%empty {$$ = nullptr;}
					|LITSTRING SEMICOLON import_list_entry{
						Node *tmp = new Node("import_list_entry");
						tmp->addChild(new Node("litString"));
						tmp->addChild($3);
						$$ = tmp;
						};

top_level_declaration:	%empty {$$ = nullptr;}
					|var_declaration top_level_declaration {
						Node *tmp = new Node("top_level_declaration");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					}
					|func_declaration top_level_declaration {
						Node *tmp = new Node("top_level_declaration");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					};
var_declaration:	VAR ID type SEMICOLON{
						Node *tmp = new Node("var_declaration");
						tmp->addChild(new Node("id"));
						tmp->addChild($3);
						$$ = tmp;
					};
func_declaration:	FUNC ID PARL para_signature PARR return_signature CURL statement_list CURR{ 
						Node *tmp = new Node("func_declaration");
						tmp->addChild(new Node("id"));
						tmp->addChild($4);
						tmp->addChild($6);
						tmp->addChild($8);
						$$ = tmp;
					};
					//TODO: FILL UP WITH FUNCTIONALITY
return_signature:	%empty {$$ = nullptr;};
para_signature:		%empty {$$ = nullptr;};					
statement_list:		%empty {$$ = nullptr;}
					|var_declaration statement_list{
						Node *tmp = new Node("statement_list");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					}
					|expression statement_list{
						Node *tmp = new Node("statement_list");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					};
					
expression:			function_call SEMICOLON{
						Node *tmp = new Node("expression");
						tmp->addChild(new Node("id"));
						tmp->addChild($1);
						$$ = tmp;
					}
					|ID EQUALS exp SEMICOLON{
						Node *tmp = new Node("expression");
						tmp->addChild(new Node("id"));
						tmp->addChild($3);
						$$ = tmp;
					};
function_call:		ID DOT ID PARL parameter_list PARR{
						Node *tmp = new Node("function_call");
						tmp->addChild(new Node("id"));
						tmp->addChild($5);
						$$ = tmp;
					};
parameter_list:		%empty{$$ = nullptr;}
					|exp COMMA parameter_list
					|exp;

exp:				exp PLUS exp   { 
						Node *tmp = new Node("addition");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| exp MINUS exp   {
						Node *tmp = new Node("subtraction");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| exp MUL exp   { 
						Node *tmp = new Node("multiplication");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp ;
					}
					| exp DIV exp   {
						Node *tmp = new Node("division");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| PARL exp PARR   { 
						Node *tmp = new Node("sub exp");
						tmp->addChild($2);
						$$ = tmp;
					}
					| ID  { $$ = new Node("id"); }
					| lit  {
						$$ = $1;
					}
					|function_call{
						$$ = $1;
					};
lit:				LITINT{
						$$ = new Node("int lit");
					}
					|LITFLOAT{
						$$ = new Node("float lit");
					}
					|LITRUNE{
						$$ = new Node("rune lit");
					}
					|LITBOOL{
						$$ = new Node("bool lit");
					}
					|LITSTRING{
						$$ = new Node("string lit");
					};
type:				TYPEINT{
						$$ = new Node("int");
					}
					|TYPEFLOAT{
						$$ = new Node("float");
					}
					|TYPERUNE{
						$$ = new Node("rune");
					}
					|TYPEBOOL{
						$$ = new Node("bool");
					}
					|TYPESTRING{
						$$ = new Node("string");
					};
%%

void yy::go_parser::error (const location_type& l,
                          const std::string& m)
{
  driver.error (l, m);
}
