#include "AST_Node.hh"
static IRBuilder<> Builder(Node::TheContext);
Value *AST_Node::genCode(){
	for(auto c = children->begin(); c != children->end(); ++c){
		if(*c != nullptr){
			(*c)->genCode();
		}
    }
}

Value *IdNode::genCode(){
	auto ref = ArrayRef<unsigned char>((unsigned char*)(*Node::symbolTable)[this->symTabIndex].c_str(), (*Node::symbolTable)[this->symTabIndex].length());
	auto* v = ConstantDataArray::get(Node::TheContext, ref);
	//v->dump();
	return v;
}
Value *TypeNode::genCode(){
	
}
Value *LitNode::genCode(){
	if(this->val == "int lit"){
		return ConstantInt::get(Node::TheContext, APInt(32, std::atoi((*Node::symbolTable)[this->symTabIndex].c_str()), true));
	}
	else if(this->val == "float lit"){
		return ConstantFP::get(Node::TheContext, APFloat(std::atof((*Node::symbolTable)[this->symTabIndex].c_str())));
	}
	else if(this->val == "bool lit"){
		
	}
	else if(this->val == "rune lit"){
		
	}
	else if(this->val == "string lit"){
		auto ref = ArrayRef<unsigned char>((unsigned char*)(*Node::symbolTable)[this->symTabIndex].c_str(), (*Node::symbolTable)[this->symTabIndex].length());
		return ConstantDataArray::get(Node::TheContext, ref);
	}
	else{
		std::cout<<"error: "<<this->val<<" does not match LitNode"<<std::endl;
	}
}
Value *ExpNode::genCode(){
	Value *L = this->getChild(0)->genCode();
	Value *R = this->getChild(1)->genCode();
	if (!L || !R)
		return nullptr;
	if(this->val == "addition"){
		auto* a = Builder.CreateAdd(L, R, "addtmp");
		a->dump();
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
		a->dump();
		return a;
	}
	else if(this->val == "sub exp"){
		return L;
	}
	else{
		std::cout<<"error: "<<this->val<<" does not match ExpNode"<<std::endl;
	}
}