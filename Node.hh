#ifndef NODE_HH
#define NODE_HH
#include "vector"
#include <string>
#include <iostream>

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
};

#endif // ! NODE_HH