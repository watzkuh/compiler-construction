#include "Node.hh"

Node:: Node(){
	children = new std::vector<Node*>;
}
Node:: Node(std::string val){
	this->val = val;
	children = new std::vector<Node*>;
}
void Node::addChild(Node *child){
	if(child != nullptr)
		children->push_back(child);
}
void Node::print(int depth) {
    for(int i = 0; i<depth;i++){
        std::cout<<"\t";
    }
    std::cout<<this->val<<" ";
    std::cout<<std::endl;
    for(auto c = children->begin(); c != children->end(); ++c){
        (*c)->print(depth+1);
    }
}

