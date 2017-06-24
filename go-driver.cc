#include "go-driver.hh"
#include "go-parser.hh"
#include "Node.hh"

std::vector<std::string> *Node::symbolTable;
LLVMContext Node::TheContext;
std::unique_ptr<Module> Node::TheModule;

go_driver::go_driver ()
  : trace_scanning (false), trace_parsing (false)
{
   this->symbolTable = new std::vector<std::string>;
   Node::symbolTable = this->symbolTable;
   Node::TheModule = llvm::make_unique<llvm::Module>("go", Node::TheContext);
}

go_driver::~go_driver ()
{
}

int go_driver::addToSymbolTable(std::string val){
	this->symbolTable->push_back(val);
	return (symbolTable->size())-1;
}
void go_driver::printSymbolTable(){
	for(auto entry = symbolTable->begin(); entry != symbolTable->end(); ++entry){
		std::cout<<(*entry)<<std::endl;
	}
}
int
go_driver::parse (const std::string &f)
{
  file = f;
  scan_begin ();
  yy::go_parser parser (*this);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse();
  scan_end ();
  if(this->root != nullptr){
	this->root->print(0);
	this->root->genCode();
  }
  Node::TheModule->dump();
  return res;
}

void
go_driver::error (const yy::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << std::endl;
}

void
go_driver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}
