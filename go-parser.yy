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
  PARL  "("
  PARR  ")"
;

%token <std::string> ID "identifier"
%token <std::string> LITSTRING "string literal"
%type<Node*> unit
%type<Node*> package_clause
%type<Node*> import_clause
%type<Node*> import_list_entry
%printer { yyoutput << $$; } <*>;

%%
%start unit;
unit: package_clause import_clause{
					Node *tmp = new Node("sourcefile");
					tmp->addChild($1);
					tmp->addChild($2);
					driver.root = tmp;
};

package_clause:	PACKAGE ID SEMICOLON{
					Node *tmp = new Node("package_clause");
					tmp->addChild(new Node("id"));
					$$ = tmp;
};

import_clause:	%empty
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

import_list_entry:	%empty 
					|LITSTRING SEMICOLON import_list_entry{
						Node *tmp = new Node("import_list_entry");
						tmp->addChild(new Node("litString"));
						tmp->addChild($3);
						$$ = tmp;
						};

					
%%

void yy::go_parser::error (const location_type& l,
                          const std::string& m)
{
  driver.error (l, m);
}
