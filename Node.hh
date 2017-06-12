#ifndef NODE_HH
# define NODE_HH
#include "vector"
#include <string>
#include <iostream>
class Node{
private:
	
	std::vector<Node*>* children;
public:
	Node();
	Node(std::string val);
	std::string val;
	void addChild(Node* child);
	void print(int depth);
};

#endif // ! NODE_HH