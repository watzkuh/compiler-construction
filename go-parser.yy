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
class AST_Node;
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
# include "AST_Node.hh"
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
					Node *tmp = new AST_Node("sourcefile");
					tmp->addChild($1);
					tmp->addChild($2);
					tmp->addChild($3);
					driver.root = tmp;
};

package_clause:		PACKAGE ID SEMICOLON{
					Node *tmp = new AST_Node("package_clause");
					tmp->addChild(new IdNode("id", driver.addToSymbolTable($2)));
					$$ = tmp;
};

import_clause:		%empty {$$ = nullptr;}
					|IMPORT LITSTRING SEMICOLON import_clause{
						Node *tmp = new AST_Node("import_clause");
						tmp->addChild(new LitNode("string lit", driver.addToSymbolTable($2)));
						tmp->addChild($4);
						$$ = tmp;
					}
					|IMPORT PARL import_list_entry PARR import_clause{
						Node *tmp = new AST_Node("import_clause");
						tmp->addChild($3);
						tmp->addChild($5);
						$$ = tmp;
					};

import_list_entry:	%empty {$$ = nullptr;}
					|LITSTRING SEMICOLON import_list_entry{
						Node *tmp = new AST_Node("import_list_entry");
						tmp->addChild(new LitNode("string lit", driver.addToSymbolTable($1)));
						tmp->addChild($3);
						$$ = tmp;
						};

top_level_declaration:	%empty {$$ = nullptr;}
					|var_declaration top_level_declaration {
						Node *tmp = new AST_Node("top_level_declaration");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					}
					|func_declaration top_level_declaration {
						Node *tmp = new AST_Node("top_level_declaration");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					};
var_declaration:	VAR ID type SEMICOLON{
						Node *tmp = new AST_Node("var_declaration");
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($2)));
						tmp->addChild($3);
						$$ = tmp;
					};
func_declaration:	FUNC ID PARL para_signature PARR return_signature CURL statement_list CURR{ 
						Node *tmp = new AST_Node("func_declaration");
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($2)));
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
						Node *tmp = new AST_Node("statement_list");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					}
					|expression statement_list{
						Node *tmp = new AST_Node("statement_list");
						tmp->addChild($1);
						tmp->addChild($2);
						$$ = tmp;
					};
					
expression:			function_call SEMICOLON{
						Node *tmp = new AST_Node("expression");
						tmp->addChild($1);
						$$ = tmp;
					}
					|ID EQUALS exp SEMICOLON{
						Node *tmp = new AST_Node("expression");
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($1)));
						tmp->addChild($3);
						$$ = tmp;
					};
function_call:		ID DOT ID PARL parameter_list PARR{
						Node *tmp = new AST_Node("function_call");
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($1)));
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($3)));
						tmp->addChild($5);
						$$ = tmp;
					}
					| ID PARL parameter_list PARR{
						Node *tmp = new AST_Node("function_call");
						tmp->addChild(new IdNode("id", driver.addToSymbolTable($1)));
						tmp->addChild($3);
						$$ = tmp;
					};
parameter_list:		%empty{$$ = nullptr;}
					|exp COMMA parameter_list
					|exp;

exp:				exp PLUS exp   { 
						Node *tmp = new ExpNode("addition");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| exp MINUS exp   {
						Node *tmp = new ExpNode("subtraction");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| exp MUL exp   { 
						Node *tmp = new ExpNode("multiplication");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp ;
					}
					| exp DIV exp   {
						Node *tmp = new ExpNode("division");
						tmp->addChild($1);
						tmp->addChild($3);
						$$ = tmp;
					}
					| PARL exp PARR   { 
						$$ = $2;
					}
					| ID  { $$ = new IdNode("id", driver.addToSymbolTable($1)); }
					| lit  {
						Node *tmp = new ExpNode("sub exp");
						tmp->addChild($1);
						$$ = $1;
					}
					|function_call{
						$$ = $1;
					};
lit:				LITINT{
						$$ = new LitNode("int lit", driver.addToSymbolTable($1));
					}
					|LITFLOAT{
						$$ = new LitNode("float lit", driver.addToSymbolTable($1));
					}
					|LITRUNE{
						$$ = new LitNode("rune lit", driver.addToSymbolTable($1));
					}
					|LITBOOL{
						$$ = new LitNode("bool lit", driver.addToSymbolTable($1));
					}
					|LITSTRING{
						$$ = new LitNode("string lit", driver.addToSymbolTable($1));
					};
type:				TYPEINT{
						$$ = new TypeNode("int");
					}
					|TYPEFLOAT{
						$$ = new TypeNode("float");
					}
					|TYPERUNE{
						$$ = new TypeNode("rune");
					}
					|TYPEBOOL{
						$$ = new TypeNode("bool");
					}
					|TYPESTRING{
						$$ = new TypeNode("string");
					};
%%

void yy::go_parser::error (const location_type& l,
                          const std::string& m)
{
  driver.error (l, m);
  exit(42);
}
