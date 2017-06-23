#ifndef NODE_HH
#define NODE_HH
#include "vector"
#include <string>
#include <iostream>

#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Verifier.h"
#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <memory>

using namespace llvm;
class Node{
private:
	std::vector<Node*>* children;
public:
	static std::vector<std::string> *symbolTable;
	Node();
	Node(std::string val);
	Node(std::string val, unsigned int symTabIndex);
	std::string val;
	int symTabIndex;
	void addChild(Node* child);
	void print(int depth);
	virtual Value *genCode() = 0;
};

#endif // ! NODE_HH