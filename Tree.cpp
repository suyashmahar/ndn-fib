// Copyright (c) 2017, Suyash Mahar
// ALl rights reserved.

#include <algorithm>
#include <iostream>
#include <iomanip>
#include <iterator>
#include <fstream>
#include <functional>
#include <openssl/md5.h>
#include <string>
#include <sstream>
#include <vector>

#define NAME_DELIM '/'
#define DEBUG_MODE 1

const int HASH_LEN = 31;
const int NEXT_TABLE_PTR_LEN = 16;
const int PORT_NUM_LEN = 8;

struct HashTable {
bool hashTableContent[HASH_LEN + NEXT_TABLE_PTR_LEN + PORT_NUM_LEN];
};

std::size_t getHash(std::string name) {
  return std::hash<std::string>{}(name);
}


/*
 * Class representing Node of a tree
 * @Author Suyash Mahar
 */
class Node {
public:
  std::vector<Node*> children;  // Stores all children of a node 
  std::size_t content; // Stores content of current node

  // Constructor for Node
  Node (std::string content) {
    this->content = getHash(content);
  }

  // Checks if a child of supplied name exists in current node
  bool checkIfChildExists(std::string content) {
    for (auto child : children) {
      if (child->content == getHash(content)) {
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

int getMaxChildAtLevel(Node *root, int level, int targetLevel) {
  if (root->children.size()==0) {
    return 0;
  } else if (level == targetLevel) {
    return root->children.size();
  } else {
    int result = 0;
    int maxChildrenCount = 0;
    for (Node *child : root->children) {
      int childrenCount = getMaxChildAtLevel(child, level+1, targetLevel);
      maxChildrenCount = maxChildrenCount > childrenCount ? maxChildrenCount : childrenCount;
      result += childrenCount;
    }
    return maxChildrenCount;
  }
}

int getCountAtLevel(Node *root, int level, int targetLevel) {
  if (root->children.size()==0) {
    return 0;
  } else if (level-1 == targetLevel) {
    return root->children.size(); 
  } else {
    int result = 0;
    int maxChildrenCount = 0;
    for (Node *child : root->children) {
      int childrenCount = getCountAtLevel(child, level+1, targetLevel);
      maxChildrenCount = maxChildrenCount > childrenCount ? maxChildrenCount : childrenCount;
      result += childrenCount;
    }
    return result;
  }
}

// Perform depth first search of tree given
int depthFirstSearch(Node *root, int counter) {
  //std::cout << root->content << " ";
  //std:: cout << root->children.size() << std::endl;
  int currentLevelCounter = 0;
  if (root->children.size()) {
    for (Node *child : root->children) {
     counter += depthFirstSearch(child, 0);
    }
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
      if (child->content == getHash(name.components[level])) {
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

  Node *root = new Node("root");
  int counter = 0;
  
  Name newName("/ag/webhoster/michelle/web199/2011gkst_11308/20110602/t20110602_626779.shtml");
  insertName(root, newName);
  depthFirstSearch(root, 0);

  std::ifstream fileName("/home/suyash/Documents/GitHub/ndn-pit/datasets/fileName");
  std::string fName("");
  std::getline(fileName, fName);
  std::cout << "Using file: " << fName << std::endl;
  std::ifstream infile(fName);
  
  //std::ifstream infile("/home/suyash/Documents/GitHub/ndn-pit/datasets/Average_workload.trim.fib");
  std::string line;
  int lineCount = 0; // Keeps count of lines processed
  while (std::getline(infile, line)) {
    insertName(root, Name(line));
    std::cout << "Lines proccessed: " << lineCount << '\r';
    lineCount++;
  }
  
  std::cout << std::endl; // To counter the effect of last '\r'

  std::cout << "Press any key to continue...";
  char a;
  std::cin >> a;
  counter = depthFirstSearch(root, 0);
  std::cout << counter << std::endl;

  std::cout << "Analysing dataset:" << std::endl;
  std::cout << "1 Starting node population per level analysis..." << std::endl;

  // Analyses nodes at fixed number of levels
  for (int i = 0; i < 15; i++) {
    std::cout << "\tNumber of nodes at level " << i << " are " << getCountAtLevel(root, 0, i) << std::endl;
    std::cout << "\t\t> Maximum children at level " << i << " are " << getMaxChildAtLevel(root, 0, i) << std::endl;
  }
  return 0;
}
