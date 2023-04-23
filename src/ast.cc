 #include "ast.hh"
#include <bits/stdc++.h>
#include <string>
#include <vector>

NodeBinOp::NodeBinOp(NodeBinOp::Op ope, Node *leftptr, Node *rightptr) {
    type = BIN_OP;
    op = ope;
    left = leftptr;
    right = rightptr;
}

std::string NodeBinOp::to_string() {
    std::string out = "( ";
    switch(op) {
        case PLUS: out += '+'; break;
        case MINUS: out += '-'; break;
        case MULT: out += '*'; break;
        case DIV: out += '/'; break;
    }

    out += ' ' + left->to_string() + ' ' + right->to_string() + " )";

    return out;
}

NodeInt::NodeInt(int val) {
    type = INT_LIT;
    value = val;
}

std::string NodeInt::to_string() {
    return std::to_string(value);
}

NodeShort::NodeShort(int val) {
    type = INT_LIT;
    value = val;
}

std::string NodeShort::to_string() {
    return std::to_string(value);
}

NodeLong::NodeLong(int val) {
    type = INT_LIT;
    value = val;
}

std::string NodeLong::to_string() {
    return std::to_string(value);
}

NodeStmts::NodeStmts() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts::to_string() {
    std::string out = "(begin";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}

NodeDecl::NodeDecl(std::string id, Node *expr, Node* abc) {
    type = ASSN;
    identifier = id;
    expression = expr;
    st1=abc;
}
 
std::string NodeDecl::to_string() {
    return "(let " + identifier + " " + st1->to_string() + ")";
}

NodeDebug::NodeDebug(Node *expr) {
    type = DBG;
    expression = expr;
}

std::string NodeDebug::to_string() {
    return "(dbg " + expression->to_string() + ")";
}

NodeIdent::NodeIdent(std::string ident) {
    identifier = ident;
}
std::string NodeIdent::to_string() {
    return identifier;
}
NodeIfElse::NodeIfElse(Node* cond, Node *tBody, Node *fBody)
{
    condition = cond;
    ifBody = tBody;
    elseBody = fBody;
}

std::string NodeIfElse::to_string()
{
   std::string s=condition->to_string();
    std::cout<<"NEWWWWWW "<<s<<std::endl;
    int k=0;
    for(int i=0;i<s.length();i++)
    {
      if(s[i]>='a' && s[i]<='z')
       k=1;
      else if(s[i]>='A' && s[i]<='Z')
       k=1;
    }
    std::string out = "";//"else (" + condition->to_string() + ") {\n";if {\n"
    if ((k==0 && s!= "0"))
    {out += ifBody->to_string() + "\n";
    return out;}
    if((k==0 && s=="0"))
    {out += elseBody->to_string() + "\n";
    return out;}
    if(k==1)
    out = "(if-else "+condition->to_string() + "\n"+ifBody->to_string() +"\n"+ elseBody->to_string() + "\n)\n";

    return out;
}

NodeFunc::NodeFunc(Node *param, Node *fBody,Node *Ret)
{
    Param = param;
    func = fBody;
    ret = Ret;
}

std::string NodeFunc::to_string()
{
    std::string out = "func (" + Param->to_string() + ") {\n";
    out += func->to_string() + "\n}";

    return out;
}

NodeParam::NodeParam() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeParam::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeParam::to_string() {
    std::string out = "(begin";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}

NodeTest::NodeTest(std::string abc) {
    type = ASSN;
    st=abc;
}
 
std::string NodeTest::to_string() {
    return st;
}
