#ifndef SCOPE_HH
#define SCOPE_HH
#include <bits/stdc++.h>
#include <set>
#include <string>
#include "ast.hh"
using namespace std;

struct scopetable
{
    std::map<int, std::map<std::string, int>> scope;
    int s = 0;
    bool present(std::string key);
    void insert(std::string key, int value);
    void update(std::string key, int value);
    int get(std::string key);
    void dec();
    void inc();
};

#endif