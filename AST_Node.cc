#include "AST_Node.hh"
using namespace llvm;
LLVMContext Node::TheContext;
static IRBuilder<> Builder(Node::TheContext);
Value *AST_Node::genCode(){
	std::vector<llvm::Value*>ssa;
	for(auto c = children->begin(); c != children->end(); ++c){
		if(*c != nullptr){
			ssa.push_back((*c)->genCode());
		}
    }
	//just use one of the nodes for testing reasons, we didn't really find a way to just append llvm IR
	return ssa[0];
}
Value *StartNode::genCode(){
	Node::TheModule = llvm::make_unique<Module>("go", Node::TheContext);
	//skip package name and imports
	return this->getChild(2)->genCode();
	/*for(auto c = children->begin(); c != children->end(); ++c){
		if(*c != nullptr){
			return (*c)->genCode();
		}
    }
	return nullptr;*/
}
Value *IdNode::genCode(){
	auto ref = ArrayRef<unsigned char>((unsigned char*)(*Node::symbolTable)[this->symTabIndex].c_str(), (*Node::symbolTable)[this->symTabIndex].length());
	auto* v = ConstantDataArray::get(Node::TheContext, ref);
	//v->dump();
	return v;
}
Value *TypeNode::genCode(){
	return nullptr;
}
Value *LitNode::genCode(){
	if(this->val == "int lit"){
		return ConstantInt::get(Node::TheContext, APInt(32, std::atoi((*Node::symbolTable)[this->symTabIndex].c_str()), true));
	}
	else if(this->val == "float lit"){
		auto a = ConstantFP::get(Node::TheContext, APFloat(std::atof((*Node::symbolTable)[this->symTabIndex].c_str())));
		//a->dump();
		return a;
	}
	else if(this->val == "bool lit"){
		return nullptr;
	}
	else if(this->val == "rune lit"){
		return nullptr;
	}
	else if(this->val == "string lit"){
		auto ref = ArrayRef<unsigned char>((unsigned char*)(*Node::symbolTable)[this->symTabIndex].c_str(), (*Node::symbolTable)[this->symTabIndex].length());
		return ConstantDataArray::get(Node::TheContext, ref);
	}
	else{
		std::cout<<"error: "<<this->val<<" does not match LitNode"<<std::endl;
		return nullptr;
	}
}
Value *ExpNode::genCode(){
	Value *L = this->getChild(0)->genCode();
	Value *R = this->getChild(1)->genCode();
	if (!L || !R)
		return nullptr;
	if(this->val == "addition"){
		auto* a = Builder.CreateAdd(L, R, "addtmp");
		//a->dump();
		return a;
	}
	else if(this->val == "subtraction"){
		return Builder.CreateSub(L, R, "subtmp");
	}
	else if(this->val == "multiplication"){
		return Builder.CreateMul(L, R, "multmp");
	}
	else if(this->val == "division"){
		auto* a = Builder.CreateUDiv(L, R, "divtmp");
		//a->dump();
		return a;
	}
	else if(this->val == "sub exp"){
		return L;
	}
	else{
		std::cout<<"error: "<<this->val<<" does not match ExpNode"<<std::endl;
		return nullptr;
	}
}