%{
#include <stdio.h>
void yyerror(const char * msg)
{
    return;
}
%}

%token tCOMMA tDEC tDIV tFOR tFUNCTION 
tGET tIDENT tIF tINC tLBRAC tOP tPRINT 
tRBRAC tRETURN tSET tSTRING tCOMP tNUM

%%

start: tLBRAC statements tRBRAC
;

statements:
    | statement statements
;

statement: setStatement
    | ifStatement
    | printStatement 
    | incrementStatement
    | decrementStatement
    | returnStatement
    | expression
;

setStatement: tLBRAC tSET tCOMMA tIDENT tCOMMA expression tRBRAC
;

ifStatement: tLBRAC tIF tCOMMA condition tCOMMA thenPartForIf tRBRAC
    | tLBRAC tIF tCOMMA condition tCOMMA thenPartForIf elsePartForIf tRBRAC
;
thenPartForIf: tLBRAC statements tRBRAC ;
elsePartForIf: tLBRAC statements tRBRAC ;

printStatement: tLBRAC tPRINT tCOMMA expression tRBRAC ;

incrementStatement: tLBRAC tINC tCOMMA tIDENT tRBRAC ;
decrementStatement: tLBRAC tDEC tCOMMA tIDENT tRBRAC ;

condition: tLBRAC tCOMP tCOMMA expression tCOMMA expression tRBRAC ; 

expressions: expression
    | expressions tCOMMA expression
;

expression: tNUM 
    | tSTRING 
    | getExpression 
    | functionDeclaration 
    | operatorApplication 
    | condition
;

getExpression: tLBRAC tGET tCOMMA tIDENT tRBRAC
    | tLBRAC tGET tCOMMA tIDENT tCOMMA tLBRAC expressions tRBRAC tRBRAC
    | tLBRAC tGET tCOMMA tIDENT tCOMMA tLBRAC tRBRAC tRBRAC
;

functionDeclaration: tLBRAC tFUNCTION tCOMMA tLBRAC parameters tRBRAC tCOMMA tLBRAC statements tRBRAC tRBRAC
    | tLBRAC tFUNCTION tCOMMA tLBRAC tRBRAC tCOMMA tLBRAC statements tRBRAC tRBRAC
;
parameters: tIDENT
    | parameters tCOMMA tIDENT
;

operatorApplication: tLBRAC tOP tCOMMA expression tCOMMA expression tRBRAC ;

returnStatement: tLBRAC tRETURN tRBRAC
    | tLBRAC tRETURN tCOMMA expression tRBRAC
;

%%


int main ()
{
    if (yyparse())
    {
        // parse error
        printf("ERROR\n");
        return 1;
    }
    else
    {
        // successful parsing
        printf("OK\n");
        return 0;
    }
}
