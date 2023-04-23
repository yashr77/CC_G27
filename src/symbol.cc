#include "symbol.hh"

bool SymbolTable::contains(std::string key) {
    return table.find(key) != table.end();
}

void SymbolTable::insert(std::string key) {
    table.insert(key);
}

bool SymbolTable1::contains(std::string key) {
    return table.find(key) != table.end();
}

int SymbolTable1::value(std::string key){
    return table[key];
}

void SymbolTable1::insert(std::string key, int val) {
    table[key]=val;
}




