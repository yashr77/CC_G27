%option noyywrap

%{
#include "parser.hh"
#include <string>

extern int yyerror(std::string msg);
%}

%%

"+"       { return TPLUS; }
"-"       { return TDASH; }
"*"       { return TSTAR; }
"/"       { return TSLASH; }
";"       { return TSCOL; }
"("       { return TLPAREN; }
")"       { return TRPAREN; }
"="       { return TEQUAL; }
"dbg"     { return TDBG; }
"let"     { return TLET; }
"int"     { return TINTTY;}
"short"   { return TSHORTTY;}
"long"    { return TLONGTY;}
":"       { return TCOL;}
"if"      { return TIF; }
"else"      { return TELSE; }
"{"         { return TLCURL; }
"}"         { return TRCURL; }
"fun"       {return TFUN;}
"ret"       {return TRET;}
","         {return TCOM;}
[0-9]+    { yylval.lexeme = std::string(yytext); return TINT_LIT; }
[a-zA-Z]+ { yylval.lexeme = std::string(yytext); return TIDENT; }
[ \t\n]   { /* skip */ }
.         { yyerror("unknown char"); }

%%

std::string token_to_string(int token, const char *lexeme) {
    std::string s;
    switch (token) {
        case TPLUS: s = "TPLUS"; break;
        case TDASH: s = "TDASH"; break;
        case TSTAR: s = "TSTAR"; break;
        case TSLASH: s = "TSLASH"; break;
        case TSCOL: s = "TSCOL"; break;
        case TLPAREN: s = "TLPAREN"; break;
        case TRPAREN: s = "TRPAREN"; break;
        case TEQUAL: s = "TEQUAL"; break;
        case TINTTY: s = "TINTTY"; break;
        case TDBG: s = "TDBG"; break;
        case TLET: s = "TLET"; break;
        case TIF: s= "TIF"; break;
        case TELSE: s= "TELSE"; break;
        case TLCURL: s= "TLCURL"; break;
        case TRCURL: s= "TRCURL"; break;
        case TSHORTTY: s = "TSHORTTY"; break;
        case TLONGTY: s = "TLONGTY"; break;
        case TFUN:    s="TFUN"; break;
        case TRET:    s="TRET"; break;
        case TCOL: s = "TCOL"; break;
        case TCOM: s= "TCOM"; break;
        case TINT_LIT: s = "TINT_LIT"; s.append("  ").append(lexeme); break;
        case TIDENT: s = "TIDENT"; s.append("  ").append(lexeme); break;
    }

    return s;
}
