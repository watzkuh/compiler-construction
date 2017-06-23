#ifndef AST_NODE_HH
#define AST_NODE_HH
#include "Node.hh"

class AST_Node : public Node{
	public:
	AST_Node(std::string val) : Node(val){};
	AST_Node(std::string val, unsigned int symTabIndex) : Node(val, symTabIndex){};
	Value *genCode() override;
};
class TypeNode : public Node{
	public:
	TypeNode(std::string val) : Node(val){};
	Value *genCode() override;
};
class LitNode : public Node{
	public:
	LitNode(std::string val, unsigned int symTabIndex) : Node(val, symTabIndex){};
	Value *genCode() override;
};

#endif