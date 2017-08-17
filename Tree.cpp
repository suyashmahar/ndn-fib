#include <algorithm>
#include <iostream>
#include <iterator>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

#define NAME_DELIM '/'

/*
 * Class representing Node of a tree
 * @Author Suyash Mahar
 */
class Node {
public:
  std::vector<Node*> children;  // Stores all children of a node 
  std::string content; // Stores content of current node

  // Constructor for Node
  Node (std::string content) {
    this->content = content;
  }

  // Checks if a child of supplied name exists in current node
  bool checkIfChildExists(std::string content) {
    for (auto child : children) {
      if (child->content == content) {
	return true;
      }
    }
    // std::cout << "false" << std::end;
    return false;
  }

  // Adds child to existing list of children and returns child node
  Node *addChild(std::string content) {
    if (!checkIfChildExists(content)) {
      Node *newNode = new Node(content);
      this->children.push_back(newNode);
      return newNode;
    }
  }
};

// Perform depth first search of tree given
int depthFirstSearch(Node *root, int counter) {
  //std::cout << root->content << " ";
  //std:: cout << root->children.size() << std::endl;
  int currentLevelCounter = 0;
  if (root->children.size()) {
    for (Node *child : root->children) {
     counter += depthFirstSearch(child, 0);
    }
  } else {
    std::cout << std::endl;
  }
  return counter+1;
}

class Name {
private:

  template<typename Out>
  void split(const std::string &s, char delim, Out result) {
    std::stringstream ss;
    ss.str(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
      *(result++) = item;
    }
  }

  // Splits string to vector using delim
  std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
    split(s, delim, std::back_inserter(elems));
    return elems;
  }
public:
  std::vector<std::string> components;
  int length = 0;
  
  Name(std::string name) {
    this->components = split(name, NAME_DELIM);
    this->components[0] = "root";
    length = this->components.size();
  }
};

// Inserts name into tree
void insertName(Node *root, Name name) {
  Node *currentNode = root;
  for (int level = 0; level < name.length; level++) {
    bool childFound = 0;
    for (auto child : currentNode->children) {
      if (child->content == name.components[level]) {
	currentNode = child;
	childFound  = 1;
	break;
      }
    }
    if (!childFound) {
      currentNode = currentNode->addChild(name.components[level]);
    }
  }
}

int main() {
  std::cout << "Hello! world" << std::endl;

  // Declare nodes for inserting into tree
  Node *root = new Node("root");

  // Construct tree
  Node *com = root->addChild("com");
  Node *google = com->addChild("google");
  Node *news = google->addChild("news");
  Node *twitter = com->addChild("twitter");
  Node *notification = twitter->addChild("notification");
  Node *profile = twitter->addChild("profile");
  int counter = depthFirstSearch(com, 0);
  std::cout << counter << std::endl;

  Name newName("/ag/webhoster/michelle/web199/2011gkst_11308/20110602/t20110602_626779.shtml");
  insertName(root, newName);
  depthFirstSearch(root, 0);

  
  //  std::ifstream infile("/home/suyash/Documents/GitHub/ndn-pit/datasets/1Mdataset.unique.sorted.fib");
  std::ifstream infile("/home/suyash/Documents/GitHub/ndn-pit/datasets/newdatabase.cleaned.sortedlen.fib");
  std::string line;
  while (std::getline(infile, line)) {
    insertName(root, Name(line)); 
  }
  std::cout << "Press any key to continue...";
  char a;
  std::cin >> a;
  counter = depthFirstSearch(root, 0);
  std::cout << counter << std::endl;
  return 0;
}

