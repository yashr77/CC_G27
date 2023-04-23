%define api.value.type { ParserValue }

%code requires {
#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <bits/stdc++.h>
#include "parser_util.hh"
#include "symbol.hh"
#include "scopeheader.hh"

}

%code {

#include <bits/stdc++.h>
using namespace std;
extern int yylex();
extern int yyparse();
int c=0;
extern NodeStmts* final_values;
SymbolTable symbol_table;
SymbolTable1 symbol_table1;
scopetable scpt;
int d=0;
int ty=0;
int y=0;
int id=0;
int yyerror(std::string msg);

int check(std::string s)
{
    std::string t="";
    for(auto it:s)
    {
        if(it>='a' && it<='z' )
            return 0;
        else if(it>='A' && it<='Z')return 0;
        
    }
    return 1;
}

string constFolding(string str){  
    
    for (int i=0; i<str.length(); i++)
    {
        if (str[i]!=')')
            continue;
        
        int j = i-1;
        bool valid = true;
        while (str[j]!='(' && valid)
        {
            if (str[j]!=' ' && str[j]!='+' && str[j]!='-' && str[j]!='*' && str[j]!='/' && !(str[j]>='0' && str[j]<='9'))
                valid = false;
            j--;
        }

        if (!valid)
            continue;

        vector <int> num;
        int temp = 0;
        int op = -1;
        for (int z=j+1; z<i; z++)
        {
            if (str[z]=='+')
                op = 0;
            else if (str[z]=='-')
                op = 1;
            else if (str[z]=='*')
                op = 2;
            else if (str[z]=='/')
                op = 3;
            else if (str[z]==' ')
            {
                num.push_back(temp);
                temp = 0;
            }
            else
                temp = temp*10 + (str[z]-'0');
        }

        int b = num.back();
        num.pop_back();
        int a = num.back();

        int res;
        if (op==0)
            res = a+b;
        else if (op==1)
            res = a-b;
        else if (op==2)
            res = a*b;
        else 
            res = a/b;

        str.erase(j, i-j+1);
        str.insert(j, std::to_string(res));
        i = j;
    }
 
    cout << str << endl;
    return str;
}

/*long long solver(string str)
{
    vector<string> vec;
    for(int i=0;i<str.length();i++){
        string temp="";
        while(i<str.length() && str[i]!=' '){
            temp+=str[i];
            i++;
        }
        vec.push_back(temp);
    }
    // for(auto x:vec) cout<<x<<endl;
    
    stack<string> st;
    long long  ind=0;
    while(ind<vec.size()){
        if(vec[ind]==")"){
            long long int a,b;
            a=stoll(st.top());  st.pop();
            b=stoll(st.top());  st.pop();
            if(st.top()=="+"){
                st.pop();   st.pop();
                st.push(to_string(a+b));
            }
            else if(st.top()=="*"){
                st.pop();   st.pop();
                st.push(to_string(a*b));
            }
            else if(st.top()=="-"){
                st.pop();   st.pop();
                st.push(to_string(b-a));
            }
            else if(st.top()=="/"){
                st.pop();   st.pop();
                st.push(to_string(b/a));
            }           
        }
        else{
            st.push(vec[ind]);
        }
        ind++;
    }
    return stoll(st.top());   
    return 0;
}*/


long long valueSolver(string s){
    string str="";
    for(int i=0;i<s.length();i++){
        string temp="";
        while(i<s.length() && ((s[i]>='a' && s[i]<='z') || (s[i]>='A' && s[i]<='Z'))){
            temp+=s[i];
            i++;
        }
        if(temp.length()!=0){
            int p=scpt.get(temp);
            str+=to_string(p);
            i--;
            continue;
        }
        str+=s[i];
 
    }

    return stoll(constFolding(str));
}

}

%token TPLUS TDASH TSTAR TSLASH
%token TINTTY TSHORTTY TLONGTY TCOL
%token <lexeme> TINT_LIT TIDENT
%token INT TLET TDBG
%token TSCOL TLPAREN TRPAREN TEQUAL
%token TIF TELSE TLCURL TRCURL TFUN TRET TCOM

%type <node> Expr Stmt IF FUNC Ret
%type <stmts> Program StmtList
%type <param> Param
%left TPLUS TDASH
%left TSTAR TSLASH
%%
Program :                
        { final_values = nullptr;}
        | StmtList TSCOL 
        { printf("Valid Syntax \n");
        final_values = $1; }
        |StmtList TSCOL FUNC
        { std::cout<<"abc "<<std::endl;
            $1->push_back($3);
        final_values = $1;}
        |StmtList TSCOL IF
        { $1->push_back($3);
        final_values = $1;}
        |StmtList FUNC
        {
            $1->push_back($2);
            final_values = $1;
        }
        |StmtList IF
        { $1->push_back($2);
        final_values = $1;}
        |IF
        {
            $$ = new NodeStmts(); $$->push_back($1);
            final_values = $$;
        }
        |FUNC
        {
            $$ = new NodeStmts(); $$->push_back($1);
            final_values = $$;
        }
	    ;

StmtList : Stmt                
         { $$ = new NodeStmts(); $$->push_back($1); }
	     | StmtList TSCOL Stmt 
         { $$->push_back($3); }
	     ;
	     | StmtList Stmt
         {
            printf("StmtList Stmt\n");
            $$->push_back($2);
            std::cout<<$$<<std::endl;
         }
         |StmtList TSCOL
         | StmtList TSCOL IF
         {
            printf("StmtList TSCOL IF\n");
            $$->push_back($3);
            std::cout<<$$<<std::endl;
         }
         | StmtList TSCOL FUNC
         {
            printf("Stmtlist expanding\n");
            $$->push_back($3);
         }
    ;

Stmt : TLET TIDENT TCOL Type TEQUAL Expr
         {
            if(scpt.present($2)) {
                // tried to redeclare variable, so error
                yyerror("tried to redeclare variable.\n");
            } else {
            symbol_table.insert($2);
    	    symbol_table1.insert($2,ty);
            std::cout << $2 << " -> " << valueSolver($6->to_string()) << endl;
             scpt.insert($2, valueSolver($6->to_string()));
    	    if(d>symbol_table1.value($2))
    	     yyerror("Type casting error\n");
    	    d=0;
            long long ans = 0;
            string ss=$6->to_string();
            if(check(ss))
            {
                ans = stoll(constFolding(ss));
                Node* Node1= new NodeLong(ans);
                // Node->value=ans;
               
                $$ = new NodeDecl($2, Node1,Node1);
            }

            else
            {
                string type = constFolding(ss);
                Node* Node2= new NodeTest(type);
                $$ = new NodeDecl($2, $6, Node2);
            }

            /*$$ = new NodeDecl($2, $6);*/
        }
     }
     | TDBG Expr
     {
     std::string s=$2->to_string();
     long long ans=valueSolver(s);
        std::cout<<"hel "<< $2->to_string() << " " << ans << std::endl;
        
        
        Node* Node= new NodeLong(ans);

        $$ = new NodeDebug(Node);
     }
     |TIDENT TEQUAL Expr
     {
        if(symbol_table1.contains($1))
        {
            if(d>symbol_table1.value($1))
            {
                yyerror("Type Casting Error\n");
            }
        }

        long long ans = valueSolver($3->to_string());
        scpt.update($1, ans);
                        std::cout<<"the value of the assignment will be "<<scpt.get($1)<<std::endl;
        Node* zxy= new NodeLong(ans);
        string ss=$3->to_string();
        if(check(ss))
            {
                ans = stoll(constFolding(ss));
                Node* Node1= new NodeLong(ans);
                // Node->value=ans;
               
                $$ = new NodeDecl($1, zxy, zxy);
            }

            else
            {
                string type = constFolding(ss);
                Node* wyu = new NodeTest(type);
                $$ = new NodeDecl($1, $3, wyu);
            }
        //$$=new NodeDecl($1, Node);
        d=0;
     }
     | IF
     {
        $$=$1;
     }
    | FUNC
    {
        $$=$1;
    }
     ;

Type : TINTTY
	{
	ty=2;
	c=1;}
    | TSHORTTY
    {
    ty=1;
    c=2;}
    | TLONGTY
    {
    ty=3;
    c=3;}
    ;
IF: TIF Expr TLCURLGRAM StmtList TSCOL TRCURLGRAM TELSE TLCURLGRAM StmtList TSCOL TRCURLGRAM
    {   printf("IF\n");
        //$$ = new NodeIfElse($2,$4,$9);
        string ss=$2->to_string();
        //td::cout<<stoi($2)<<std::endl;
        long long ans=0;
        string type = "";

        if(check(ss))
        {
            ans = stoll(constFolding(ss));
            Node* Node1= new NodeLong(ans);
            // Node->value=ans;
           
            $$ = new NodeIfElse(Node1,$4,$9);
        }

        else
        {
            type = constFolding(ss);

            $$ = new NodeIfElse($2,$4,$9);
        }
        cout<<"XXXX"<<ans<<endl;
       
    }
    |
    TIF Expr TLCURLGRAM StmtList TRCURLGRAM TELSE TLCURLGRAM StmtList TRCURLGRAM
    {   printf("IF\n");
        //$$ = new NodeIfElse($2,$4,$9);
        string ss=$2->to_string();
        //td::cout<<stoi($2)<<std::endl;
        long long ans=0;
        string type = "";

        if(check(ss))
        {
            ans = stoll(constFolding(ss));
            Node* Node1= new NodeLong(ans);
            // Node->value=ans;
           
            $$ = new NodeIfElse(Node1,$4,$8);
        }

        else
        {
            type = constFolding(ss);

            $$ = new NodeIfElse($2,$4,$8);
        }
    }
    |TIF Expr TLCURLGRAM StmtList TRCURLGRAM TELSE TLCURLGRAM StmtList TRCURLGRAM
    {   printf("IF\n");
        //$$ = new NodeIfElse($2,$4,$9);
        string ss=$2->to_string();
        //td::cout<<stoi($2)<<std::endl;
        long long ans=0;
        string type = "";

        if(check(ss))
        {
            ans = stoll(constFolding(ss));
            Node* Node1= new NodeLong(ans);
            // Node->value=ans;
           
            $$ = new NodeIfElse(Node1,$4,$8);
        }

        else
        {
            type = constFolding(ss);

            $$ = new NodeIfElse($2,$4,$8);
        }
    }
    |TIF Expr TLCURLGRAM StmtList TSCOL TRCURLGRAM TELSE TLCURLGRAM StmtList TSCOL TRCURLGRAM
    {   printf("IF\n");
        //$$ = new NodeIfElse($2,$4,$9);
        string ss=$2->to_string();
        //td::cout<<stoi($2)<<std::endl;
        long long ans=0;
        string type = "";

        if(check(ss))
        {
            ans = stoll(constFolding(ss));
            Node* Node1= new NodeLong(ans);
            // Node->value=ans;
           
            $$ = new NodeIfElse(Node1,$4,$9);
        }

        else
        {
            type = constFolding(ss);

            $$ = new NodeIfElse($2,$4,$9);
        }
    }
    |
    TIF Expr TLCURLGRAM StmtList TRCURLGRAM TELSE TLCURLGRAM StmtList TSCOL TRCURLGRAM
    {   printf("IF\n");
        //$$ = new NodeIfElse($2,$4,$9);
        string ss=$2->to_string();
        //td::cout<<stoi($2)<<std::endl;
        long long ans=0;
        string type = "";

        if(check(ss))
        {
            ans = stoll(constFolding(ss));
            Node* Node1= new NodeLong(ans);
            // Node->value=ans;
           
            $$ = new NodeIfElse(Node1,$4,$8);
        }

        else
        {
            type = constFolding(ss);

            $$ = new NodeIfElse($2,$4,$8);
        }
    } 
    ;

TLCURLGRAM: TLCURL
{
    scpt.inc();
    printf ("scp inc\n");
}
;

TRCURLGRAM: TRCURL
{
    scpt.dec();
    printf ("scp dec\n");
}
;


FUNC: TFUN TIDENT TLPAREN Param TRPAREN TCOL Type TLCURLGRAM StmtList Ret TRCURLGRAM
    {
        std::cout<<"hi "<<std::endl;
        $$= new NodeFunc($4,$9,$10);
    }
    |TFUN TIDENT TLPAREN Param TRPAREN TCOL Type TLCURLGRAM Ret TRCURLGRAM
    {
        $$= new NodeFunc($4,nullptr,$9);
    }
    ;
Ret: TRET Expr TSCOL
{
    $$=$2;
}
Param: TIDENT TCOL Type
        {
            $$ = new NodeParam();
            $$->push_back(new NodeIdent($1));
        }
       | Param TCOM TIDENT TCOL Type
       {
        $$->push_back(new NodeIdent($3));
       }
       ;
Expr : TINT_LIT               
     {
        if(c==1) 
	    {
	        if (stoll($1)>INT_MAX)
		    {
		        yyerror("Value out of bounds\n");
		    }
		    else
		    {
		        $$ = new NodeInt(stoi($1));
		        c=0;
		    }
	    }
	    else if(c==2)
	    {
	       if (stoi($1)>SHRT_MAX)
		    {
		        yyerror("Value out of bounds\n");
		    }
		    else
		    {
		        $$ = new NodeShort(stoi($1));
		        c=0;
		    }
	    }
	    else if(c==3)
	    {
            $$ = new NodeLong(stoll($1)); 
	        c=0;
        }
        else
        {
            $$ = new NodeLong(stoll($1)); 
        }
    }
     | TIDENT
     { 
        if(symbol_table.contains($1))
        {
        if(symbol_table1.contains($1))
            {
                if(d<symbol_table1.value($1))
                {
                    d=symbol_table1.value($1);
                }
            }
            $$ = new NodeIdent($1); 
            }
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr TPLUS Expr
     { $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3); }
     | Expr TDASH Expr
     {$$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3); }
     | Expr TSTAR Expr
     { $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3); }
     | Expr TSLASH Expr
     { $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3); }
     | TLPAREN Expr TRPAREN { $$ = $2; }
     ;

%%

int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}
