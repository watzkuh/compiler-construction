#ifndef AST_NODE_HH
#define AST_NODE_HH
#include "Node.hh"

class AST_Node : public Node{
	public:
	AST_Node(std::string val) : Node(val){};
	AST_Node(std::string val, unsigned int symTabIndex) : Node(val, symTabIndex){};
	Value *genCode() override;
};
class StartNode : public Node{
	public:
	StartNode(std::string val) : Node(val){};
	Value *genCode() override;
};
class IdNode : public Node{
	public:
	IdNode(std::string val, unsigned int symTabIndex) : Node(val, symTabIndex){};
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
class ExpNode : public Node{
	public:
	ExpNode(std::string val) : Node(val){};
	Value *genCode() override;
};

#endif