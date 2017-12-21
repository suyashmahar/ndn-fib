/* 
 * File: stageAnalysis.cpp
 * =======================
 *
 * Compilation: g++ 
 * 
 * Description
 * -----------
 * Uses counting sort to get the number of names in dataset that
 * have n number of levels
 * 
 * Usage
 * -----
 * ./a.out <dataset name>
 * 
 * Output
 * ------
 * List of numbers where nth number is % of names in the dataset having 
 * n levels
 */

#include <algorithm>
#include <fstream>
#include <iostream>
#include <list>
#include <vector>

int get_levels_count(std::string);

int main(int argc, char *argv[]) {
  std::list<int> levelCountList;
  int highestLevel = 0;
  int count = 0;

  std::ifstream infile(argv[1]);

  std::string line;
  while (infile >> line) {
    std::cout << line << std::endl;
    int levels = get_levels_count(line);
    levelCountList.push_back(levels);

    if (levels > highestLevel) {
      highestLevel = levels;
    }

    count++;
  }

  float *levelCountList2 = new float[highestLevel];
  for (int i = 0; i < highestLevel; i++) {
    levelCountList2[i] = 0;
  }
  
  for (auto level : levelCountList) {
    levelCountList2[level-1] += (float)1.0;
  }

  for (int i = 0; i < highestLevel; i++) {
    levelCountList2[i] /= count/100.0;
  }

  for (int i = 0; i < highestLevel; i++) {
    std::cout << levelCountList2[i] << " ";
  }

  std::cout << std::endl;

  return 0;
}

int get_levels_count(std::string inputStr) {
  return (int)std::count(inputStr.begin(), inputStr.end(), '/');
}
