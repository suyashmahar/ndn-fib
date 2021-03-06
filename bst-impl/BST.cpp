/*
  Usage:
  $ ./a.out [dataset] [stride_size] [w]
  $ # If w is 1 program will write files for hardware implementation
  which would be processed further
*/

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <iomanip>
#include <iterator>
#include <fstream>
#include <functional>
#include <list>
#include <map>
#include <openssl/md5.h>
#include <string>
#include <sstream>
#include <vector>

enum class PointerDirection {LEFT, RIGHT};
  

void setw(int indent){
  while (indent--){
    std::cout << " ";
  }
}

class node{
public:
  node *left;
  node *right;
  unsigned long data;
        
  node();

  node(unsigned long data, node *left, node *right){
    this->data = data;
    this->left = left;
    this->right = right;
  }
};

class bst{
private:
  void constructPostOrderTraversal(node *ref, std::stringstream &ss);
  void constructPreOrderTraversal(node *ref, std::stringstream &ss);
  void constructInOrderTraversal(node *ref, std::stringstream &ss);
  
public:
  node *root;
  bst(){
    root = NULL;
  }
  node* addToNode(node *ref, unsigned long element);
  node* add(unsigned long element);
  void postorderPrint(node* p, int indent=0);
  bool search(node *ref, unsigned long element);
  unsigned long nodeCount(node *ref);

  unsigned long height(node *ref);
  void mirror(node *ref);
  void constructLevelOrderTraversal(std::list<node*> *nodes, std::stringstream *result);

  
  std::string postOrderTraversal() { 
    std::stringstream ss("");
    constructPostOrderTraversal(root, ss);
    return ss.str(); 
  }
  
  std::string preOrderTraversal(){ 
    std::stringstream ss;
    constructPreOrderTraversal(root, ss); 
    return ss.str(); 
  }
  
  std::string inOrderTraversal(){ 
    std::stringstream ss;
    constructInOrderTraversal(root, ss); 
    return ss.str(); 
  }
};

int maxWidth(node *ref, bst newTree);
int getWidth(node* root, int level);

node* bst::addToNode(node *ref, unsigned long element) {
  if (ref->data == element){
    return ref;
  } else if (ref->data <= element) {
    if (ref->right == NULL){
      node *newNode = new node(element, NULL, NULL);
      ref->right = newNode;
      return newNode;
    } else {
      return addToNode(ref->right, element);
    }
  } else {
    if (ref->left == NULL){
      node *newNode = new node(element, NULL, NULL);
      ref->left = newNode;
      return newNode;
    } else {
      return addToNode(ref->left, element);
    }
  }
}

node* bst::add(unsigned long element){
  if (root == NULL){
    root = new node(element, NULL, NULL);
    return root;
  } else {
    return addToNode(root, element);
  }
}


void bst::constructPostOrderTraversal(node *ref, std::stringstream &ss) {
  if (ref->left!=NULL){
    constructPostOrderTraversal(ref->left, ss);
  }
    
  if (ref->right!=NULL){
    constructPostOrderTraversal(ref->right, ss);
  }

  ss << ref->data;
}


std::string hexToASCII(long inputStr) {
  std::stringstream ss("");
  while (inputStr != 0) {
    int curCharInt = inputStr & 0xff;
    inputStr >>= 8;
    ss << (char)curCharInt;
  }
  std::string str = ss.str();
  std::reverse(str.begin(), str.end());
  return str;
}

void bst::constructPreOrderTraversal(node *ref, std::stringstream &ss){
  ss << ref->data;

  if (ref->left!=NULL){
    constructPreOrderTraversal(ref->left, ss);
  }
    
  if (ref->right!=NULL){
    constructPreOrderTraversal(ref->right, ss);
  }
}

void bst::constructInOrderTraversal(node *ref, std::stringstream &ss){
  if (ref->left!=NULL){
    constructInOrderTraversal(ref->left, ss);
  }

  ss << ref->data;
    
  if (ref->right!=NULL){
    constructInOrderTraversal(ref->right, ss);
  }
}

void bst::constructLevelOrderTraversal(std::list<node*> *nodes, std::stringstream *result) {
  if (!nodes->size()) {
    return;
  } 
  std::list<node*> *levelNodes = new std::list<node*>();
  for (std::list<node*>::iterator it = nodes->begin(); it != nodes->end(); it++) {
    std::cout << hexToASCII((*it)->data) << " ";
    *result << hexToASCII((*it)->data) << " ";
    if ((*it)->left !=NULL) {
      levelNodes->push_back((*it)->left);
    }
    
    if ((*it)->right !=NULL) {
      levelNodes->push_back((*it)->right);
    }
    
  }
  std::cout << std::endl;
  *result << std::endl;
  constructLevelOrderTraversal(levelNodes, result);
}

void bst::postorderPrint(node* p, int indent) {
  if(p != NULL) {
    if(p->right) {
      postorderPrint(p->right, indent+4);
    }
    if (indent) {
      std::cout << std::setw(indent) << ' ';
    }
    if (p->right) std::cout<<" /\n" << std::setw(indent) << ' ';
    std::cout<< hexToASCII(p->data) << "\n ";
    if(p->left) {
      std::cout << std::setw(indent) << ' ' <<" \\\n";
      postorderPrint(p->left, indent+4);
    }
  }
}

bool bst::search(node *ref, unsigned long element){
  if (ref->data == element) {
    return true;
  } else {
    if (ref->left != NULL && ref->data > element) {
      return search(ref->left, element);
    } else if (ref->right != NULL && ref->data <= element){
      return search(ref->right, element);                
    } else {
      return false;
    }
  }
}

unsigned long bst::nodeCount(node *ref){
  if (ref == NULL) {
    return 0;
  } else if (ref == root) {
    return nodeCount(ref->left) + nodeCount(ref->right) + 2; 
  } else {
    return nodeCount(ref->left) + nodeCount(ref->right) + 1 ; 
  }
}

unsigned long bst::height(node *ref){
  if (ref == NULL) {
    return 0;
  }
  unsigned long lt = height(ref->left);
  unsigned long rt = height(ref->right);
  return (rt > lt ? ++rt:++lt);
}

void bst::mirror(node *ref){
  if (ref == NULL) {
    return;
  }
  node *temp = ref->left;
  ref->left = ref->right;
  ref->right = temp;

  mirror(ref->left);
  mirror(ref->right);
}

unsigned long stringToULong(std::string inputStr) {
  unsigned long rtrVal = 0l;
  for (unsigned int i = 0; i < inputStr.length(); i++) {
    char charInStr = inputStr[i];
    rtrVal <<= 8;
    //std::cout << charInStr << " | " << (short)charInStr << std::endl;
    rtrVal += (unsigned int)charInStr;
    //std::cout << "> " << rtrVal << std::endl;
  }
  return rtrVal;
}

std::vector<std::string> getComponents(std::string name, int strideLen) {
  int curLen = 0;
  int strideCount = 0;
  for (char curChar : name) {
    if (curLen >= strideLen){
      strideCount++;
      curLen = 1;
      std::cout << std::endl << curChar;
    } else if (curChar == '/') {
      strideCount++;
      std::cout << std::endl << curChar;
    } else {
      curLen++;
      std::cout << curChar;
    }
  }
}

std::map<node*, int>
*constructNodeRenameMap(std::list<node*> *nodes, std::map<node*, int> *inputMap, int *addressCounter) {
  if (!nodes->size()) {
    return inputMap;
  }

  // Based on the method constructLevelOrderTraversal
  std::list<node*> *levelNodes = new std::list<node*>();
  for (std::list<node*>::iterator it = nodes->begin(); it != nodes->end(); it++) {
    (*inputMap)[*it] = *addressCounter;
    std::cout << (*addressCounter)++ << " ";
        
    if ((*it)->left !=NULL) {
      levelNodes->push_back((*it)->left);
    }
    
    if ((*it)->right !=NULL) {
      levelNodes->push_back((*it)->right);
    }
    
  }

  std::cout << std::endl;
  *addressCounter = 0;
  return constructNodeRenameMap(levelNodes, inputMap, addressCounter);
}


void printNodePointers(std::list<node*> *nodes, std::map<node*, int> *mappingTable, PointerDirection pointerType, std::stringstream *result) {
  if (!nodes->size()) {
    return;
  } 
  std::list<node*> *levelNodes = new std::list<node*>();
  for (std::list<node*>::iterator it = nodes->begin(); it != nodes->end(); it++) {
    int outputAdd = (pointerType == PointerDirection::LEFT)
      ? (*mappingTable)[(*it)->left]
      : (*mappingTable)[(*it)->right];

    std::cout << outputAdd  << " ";
    *result << outputAdd << " ";
    if ((*it)->left !=NULL) {
      levelNodes->push_back((*it)->left);
    }
    
    if ((*it)->right !=NULL) {
      levelNodes->push_back((*it)->right);
    }
    
  }
  std::cout << std::endl;
  *result << std::endl;
  printNodePointers(levelNodes, mappingTable, pointerType, result);
}

void printNodeValidBits(std::list<node*> *nodes, PointerDirection pointerType, std::stringstream *result) {
  if (!nodes->size()) {
    return;
  }
  
  std::list<node*> *levelNodes = new std::list<node*>();
  for (std::list<node*>::iterator it = nodes->begin(); it != nodes->end(); it++) {
    int validBit = ((*it)->left != NULL) ? 1:0;
    std::cout << validBit << " ";
    *result << validBit << " ";
    if ((*it)->left !=NULL) {
      levelNodes->push_back((*it)->left);
    }
    
    if ((*it)->right !=NULL) {
      levelNodes->push_back((*it)->right);
    }
    
  }
  std::cout << std::endl;
  *result << std::endl;
  printNodeValidBits(levelNodes, pointerType, result);
}

int maxWidth(node *ref, bst newTree) {
  int maxWidth = 0;
  int width;
  int h = newTree.height(newTree.root)-1;
  
  for (int i = 0; i < h; i++) {
    width = getWidth(newTree.root, i);
    if (width > maxWidth) {
      maxWidth = width;
    }
  }

  return maxWidth;
}

int getWidth(node *root, int level) {
  if (root == NULL) {
    return 0;
  }

  if (level == 1) {
    return 1;
  } else if (level > 1) {
    return getWidth(root->left, level-1) + getWidth(root->right, level-1);
  }
}

int main(int argc, char *argv[]) {
  std::cout << "~===================================================" << std::endl;
  bst newTree;
  // newTree.add(stringToULong("c"));
  // newTree.add(stringToULong("au"));
  // newTree.add(stringToULong("org"));
  // newTree.add(stringToULong("com"));
  // newTree.add(stringToULong("com"));
  //  constructTree(newTree, "");

  // <>================================
  std::cout << "Starting analysis:" << std::endl;

  // File name for dataset to process
  std::string FILE_NAME = "/home/suyash/Documents/GitHub/ndn-pit/datasets/temp";

  // Changes file name to passed argument if present 
  if (argc > 1) {
    FILE_NAME = argv[1];
  }
  
  std::ifstream file(FILE_NAME);

  std::string line;
  int lineCount = 0;

  std::cout << "State of stream:" << file.good() << std::endl;

  
  node* root = newTree.add(0000); 
  int WORD_SIZE = 8;
  if (argc > 2) {
    WORD_SIZE = std::atoi(argv[2]);
  }
      
  while (std::getline(file, line)) {
    // while (1==1){
    // std::cout << "processing line: " << line << "\k";
    if (lineCount > 10) {
      //break;
    }

    // Here starts addition logic for each line
    // line = "/com/google/scholar";
    int strideLen = 0; // Tracks length of stride
    std::stringstream nextStride("");

    std::vector<long> strideCollection;
    for (unsigned int i = 0; i < line.length(); i++) {
      char curChar = line[i];
      if (strideLen >= WORD_SIZE) {
	strideLen = 1;
	strideCollection.push_back(stringToULong(nextStride.str().c_str()));
	// newTree.add(stringToULong(nextStride.str().c_str()));
	nextStride.str("");
	nextStride << curChar;
      } else if (curChar == '/') {
	strideLen = 1;
	strideCollection.push_back(stringToULong(nextStride.str().c_str()));
	// newTree.add(stringToULong(nextStride.str().c_str()));
	nextStride.str("");
	nextStride << curChar;
      } else {
	strideLen++;
	nextStride << curChar;
      }
    }

    // Push last element in collection
    strideCollection.push_back(stringToULong(nextStride.str().c_str()));

    // Here starts addition of all strides generated
    // =============================================
    node* inserted = root;
    for (unsigned long stride : strideCollection) {
      inserted = newTree.addToNode(inserted, stride);
    }
    
    // std::cout << "Lines proccessed: " << lineCount << '\r';
    lineCount++;
  }

  //<>========
  // newTree.add(stringToULong("com/"));
  //newTree.add(stringToULong("com/"));
  //    std::cout << stringToULong("com/") << std::endl;
  //newTree.add(stringToULong("google/"));
  //std::cout << stringToULong("google/") << std::endl;
  //newTree.add(stringToULong("news/"));
  //std::cout << stringToULong("news/") << std::endl;
  //newTree.add(stringToULong("twitter/"));
  //std::cout << stringToULong("twitter/") << std::endl;

  //std::cout << "Postorder traversal : " << newTree.postOrderTraversal() << std::endl;
  //std::cout << "Preorder traversal : " << newTree.preOrderTraversal() << std::endl;
  //std::cout << "InOrder traversal : " << newTree.inOrderTraversal() << std::endl;
  std::cout << "Tree constructed using stride size : " << WORD_SIZE << std::endl;
  std::cout << "Using dataset : \n\t\t" << FILE_NAME << std::endl;
  std::cout << "Lines processed : " << lineCount << std::endl;
  std::cout << "Total number of nodes : " << newTree.nodeCount(newTree.root) << std::endl;
  std::cout << "Height of the tree : " << newTree.height(newTree.root) << std::endl;
  std::cout << "Max width of the tree : " << maxWidth(newTree.root, newTree) << std::endl;
    
  // Prunsigned longs structure of the tree from left to right (like a fallen tree)
  std::cout << std::endl << "Here\'s a tree for you" << std::endl << std::endl;
  
  // Uncomment following line to print tree
  // newTree.postorderPrint(newTree.root, 0);

  std::cout << std::endl;

  // Code for searching BST
  //std::cout << "searching for \'470\'... \nResult: "  
  //        << newTree.search(newTree.root, 470) 
  //        << std::endl; 
    
  //    std::cout << "searching for \'-10\'... \nResult: " 
  //        << newTree.search(newTree.root, -10) 
  //        << std::endl; 

  // Mirrors a tree and then prunsigned longs it
  //    std::cout << std::endl << "Here\'s a mirrored tree for you" << std::endl << std::endl;
  //    newTree.mirror(newTree.root);
  //newTree.postorderPrint(newTree.root, 0);
  int a = 1;
  // std::cin >> a;
  // if (a == 0) {
  //  newTree.postorderPrint(newTree.root, 0);
  // }
  std::cout << std::endl;
  if (argc > 3 && std::atoi(argv[3]) == 1) {
    std::ofstream strideFile("stride_file.dat");
    std::ofstream lpFile("lp_file.dat");
    std::ofstream rpFile("rp_file.dat");
    std::ofstream lpVbFile("lpVb_file.dat");
    std::ofstream rpVbFile("rpVb_file.dat");

    std::stringstream *result = new std::stringstream("");
    
    std::list<node*> *newList = new std::list<node*>();
    newList->push_back(newTree.root);

    std::cout << "\nGenerating level order traversal..." << std::endl;
    newTree.constructLevelOrderTraversal(newList, result);
    strideFile << result->str();
    strideFile.close();
    result->str("");
    
    std::cout << "\nConstructing address mapping table..." << std::endl;
    
    newList = new std::list<node*>();
    newList->push_back(newTree.root);
    std::map<node*, int> *newMap = new std::map<node*, int>();
    int addressCounter_ = 0;
    constructNodeRenameMap(newList, newMap, &addressCounter_);
  
    std::cout << "\nGenerating Left pointers for nodes..." << std::endl;
    newList = new std::list<node*>();
    newList->push_back(newTree.root);
    printNodePointers(newList, newMap, PointerDirection::LEFT, result);
    //std::cout << result->str();
    lpFile << result->str();
    if (lpFile.fail()) {
      std::cout << "Error in writing file" << std::flush;
    }
    lpFile.close();
    result->str("");    
    delete newList;
    
    std::cout << "\nGenerating Right pointers for nodes..." << std::endl;
    newList = new std::list<node*>();
    newList->push_back(newTree.root);
    printNodePointers(newList, newMap, PointerDirection::RIGHT, result);
    //std::cout << result->str();
    rpFile << result->str();
    rpFile.close();
    result->str("");    
    delete newList;
    
    std::cout << "\nGenerating Left pointer valid bits for nodes..." << std::endl;
    newList = new std::list<node*>();
    newList->push_back(newTree.root);
    printNodeValidBits(newList, PointerDirection::LEFT, result);
    //std::cout << result->str();
    lpVbFile << result->str();
    lpVbFile.close();
    result->str("");    
    delete newList;
    
    std::cout << "\nGenerating Right pointer valid bits for nodes..." << std::endl;
    newList = new std::list<node*>();
    newList->push_back(newTree.root);
    printNodeValidBits(newList, PointerDirection::RIGHT, result);
    //std::cout << result->str();
    rpVbFile << result->str();
    rpVbFile.close();
    result->str("");    
    delete newList;
  } else {
    //    
  }
 
}
