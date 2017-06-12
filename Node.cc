#include "Node.hh"
#include <iostream>
Node:: Node(){
	this->val = "";
	children = new std::vector<Node*>;
	this->symTabIndex = -1;
}
Node:: Node(std::string val){
	this->val = val;
	children = new std::vector<Node*>;
	this->symTabIndex = -1;
}
Node::Node(std::string val, unsigned int symTabIndex){
	this->val = val;
	this->symTabIndex = symTabIndex;
	children = new std::vector<Node*>;
}
void Node::addChild(Node *child){
	if(child != nullptr){
		children->push_back(child);
		}
}
void Node::print(int depth) {
    for(int i = 0; i<depth;i++){
        std::cout<<"\t";
    }
    std::cout<<this->val<<" ";
		if(this->symTabIndex >= 0 && (this->symTabIndex < Node::symbolTable->size())){
			std::cout<<(*Node::symbolTable)[this->symTabIndex];
		}
	std::cout<<std::endl;
	
	for(auto c = children->begin(); c != children->end(); ++c){
		if(*c){
			(*c)->print(depth+1);
		}
    }
}

