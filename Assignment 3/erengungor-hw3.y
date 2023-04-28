%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "erengungor-hw3.h"

void yyerror (const char *s) {
	//printf("hop\n");
	return;
}

ExprNode * makeExpressionNodeFromInt(IntNode);
ExprNode * makeExpressionNodeFromReal(RealNode);
ExprNode * makeExpressionNodeFromString(StringNode);
ExprNode * makeNonConstExpression();
ExprNode * sumExpr(ExprNode *, ExprNode *);
ExprNode * subtractExpr(ExprNode *, ExprNode *);
ExprNode * divideExpr(ExprNode *, ExprNode *);
ExprNode * multiplyExpr(ExprNode *, ExprNode *);
void assign(ExprNode *, ExprNode *);
void printTopLevelResult(ExprNode *);

%}

%union {
	IntNode intNode;
	RealNode realNode;
	StringNode stringNode;
	ExprNode * exprNodePtr;
	int lineNum;
}

%token <intNode> tINT
%token <realNode> tREAL
%token <stringNode> tSTRING
%token <lineNum> tADD tSUB tDIV tMUL
%token tIDENT tPRINT tGET tSET tFUNCTION tRETURN tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC

%type <exprNodePtr> expr
%type <exprNodePtr> operation

%start prog

%%
prog:		'[' stmtlst ']'
;

stmtlst:	stmtlst stmt |
;

stmt:		setStmt 
			| if 
			| print 
			| unaryOperation 
			| expr { printTopLevelResult($1); /*printf("Statement selected expression\n");*/ }
			| returnStmt
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']' 
		| '[' tGET ',' tIDENT ',' '[' ']' ']'
		| '[' tGET ',' tIDENT ']'
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']'
;

if:		    '[' tIF ',' condition ',' '[' stmtlst ']' ']'
		| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']'
;

print:		'[' tPRINT ',' expr ']'
;

operation:	'[' tADD ',' expr ',' expr ']' { $$ = sumExpr($4,$6); $$->lineNum = $2; }
		| '[' tSUB ',' expr ',' expr ']' { $$ = subtractExpr($4,$6); $$->lineNum = $2; }
		| '[' tMUL ',' expr ',' expr ']' { $$ = multiplyExpr($4,$6); $$->lineNum = $2; }
		| '[' tDIV ',' expr ',' expr ']' { $$ = divideExpr($4,$6); $$->lineNum = $2; }
;

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;

expr:		tINT { $$ = makeExpressionNodeFromInt($1); }
			| tREAL { $$ = makeExpressionNodeFromReal($1); }
			| tSTRING { $$ = makeExpressionNodeFromString($1); /*printf("token recognized by bison\n");*/ }
			| getExpr { $$ = makeNonConstExpression(); }
			| function { $$ = makeNonConstExpression(); }
			| operation { assign($$,$1); }
			| condition { $$ = makeNonConstExpression(); }
;

function:	'[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
;

condition:	'[' tEQUALITY ',' expr ',' expr ']'
		| '[' tGT ',' expr ',' expr ']'
		| '[' tLT ',' expr ',' expr ']'
		| '[' tGEQ ',' expr ',' expr ']'
		| '[' tLEQ ',' expr ',' expr ']'
;

returnStmt:	'[' tRETURN ',' expr ']'
		| '[' tRETURN ']'
;

parametersList: parametersList ',' tIDENT | tIDENT
;

exprList:	exprList ',' expr | expr
;

%%

//----------------------------------------FUNCTIONS----------------------------------------
ExprNode * makeExpressionNodeFromInt(IntNode integer) {
	
	//printf("SA-makeintexp\n");
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	newNode->type = INTEGER;
	newNode->intVal = atoi(integer.value);
    newNode->lineNum = integer.lineNum;
    return newNode;

}
ExprNode * makeExpressionNodeFromReal(RealNode real) {

	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->type = FLOAT;
	newNode->realVal = atof(real.value);
    newNode->lineNum = real.lineNum;
    return newNode;

}
ExprNode * makeExpressionNodeFromString(StringNode string) {

	//printf("makeExpFromStr func entered\n");
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->identifier = string.value;
	newNode->type = STRING;
    newNode->lineNum = string.lineNum;
	//printf("Node saved => identifier: %s\n", newNode->identifier);
    return newNode;

}
ExprNode * makeNonConstExpression() {
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	newNode->type = NONCONST;
	return newNode;
}
//-----------------------------------------------------------------------------------------------------
void assign(ExprNode * expr1, ExprNode * expr2) {
	expr1->type = expr2->type;
	expr1->identifier = expr2->identifier;
	expr1->intVal = expr2->intVal;
	expr1->realVal = expr2->realVal;
	expr1->lineNum = expr2->lineNum;
}
//-----------------------------------------------------------------------------------------------------
ExprNode * sumExpr(ExprNode * expr1, ExprNode * expr2) {

	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));

	if(expr1->type == INTEGER && expr2->type == INTEGER) {
		newNode->intVal = expr1->intVal + expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = INTEGER;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->intVal);
		//printf("RESULT: %d\n", newNode->intVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == FLOAT) {
		newNode->realVal = expr1->realVal + expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == STRING && expr2->type == STRING) {
		
		char result[ strlen(expr1->identifier) + strlen(expr2->identifier) - 2 ];

		strncpy(result, expr1->identifier + 1, strlen(expr1->identifier) - 2);
		result[strlen(expr1->identifier) - 2] = '\0';

		strncat(result, expr2->identifier + 1, strlen(expr2->identifier) - 2);
		result[strlen(expr1->identifier) + strlen(expr2->identifier) - 3] = '\0';
		newNode->identifier = result;
		printf("Result of expression on %d is (%s)\n", newNode->lineNum, newNode->identifier);
		//printf("\tnewNode->identifier (at the end): %s\n", newNode->identifier);
		return newNode;

	}
	else if(expr1->type == INTEGER && expr2->type == FLOAT) {
		newNode->realVal = expr1->intVal + expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == INTEGER) {
		newNode->realVal = expr1->realVal + expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == NONCONST || expr2->type == NONCONST) {
		newNode->type = NONCONST;
		return newNode;
	}
	else {
		printf("Type mismatch on %d\n", expr1->lineNum);
		return NULL;
	}

}
//-----------------------------------------------------------------------------------------------------
ExprNode * subtractExpr(ExprNode * expr1, ExprNode * expr2) {

	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));

	if(expr1->type == INTEGER && expr2->type == INTEGER) {
		newNode->intVal = expr1->intVal - expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = INTEGER;
		printf("Result of expression on %d is (%d)\n", newNode->lineNum, newNode->intVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == FLOAT) {
		newNode->realVal = expr1->realVal - expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == INTEGER && expr2->type == FLOAT) {
		newNode->realVal = expr1->intVal - expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == INTEGER) {
		newNode->realVal = expr1->realVal - expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == NONCONST || expr2->type == NONCONST) {
		newNode->type = NONCONST;
		return newNode;
	}
	else {
		printf("Type mismatch on %d\n", expr1->lineNum);
		return NULL;
	}

}
//-----------------------------------------------------------------------------------------------------
ExprNode * multiplyExpr(ExprNode * expr1, ExprNode * expr2) {

	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	//STRING EKLE BURAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	if(expr1->type == INTEGER && expr2->type == INTEGER) {
		newNode->intVal = expr1->intVal * expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = INTEGER;
		printf("Result of expression on %d is (%d)\n", newNode->lineNum, newNode->intVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == FLOAT) {
		newNode->realVal = expr1->realVal * expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == INTEGER && expr2->type == FLOAT) {
		newNode->realVal = expr1->intVal * expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == INTEGER) {
		newNode->realVal = expr1->realVal * expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == NONCONST || expr2->type == NONCONST) {
		newNode->type = NONCONST;
		return newNode;
	}
	else {
		printf("Type mismatch on %d\n", expr1->lineNum);
		return NULL;
	}

}
//-----------------------------------------------------------------------------------------------------
ExprNode * divideExpr(ExprNode * expr1, ExprNode * expr2) {

	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));

	if(expr1->type == INTEGER && expr2->type == INTEGER) {
		newNode->intVal = expr1->intVal / expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = INTEGER;
		printf("Result of expression on %d is (%d)\n", newNode->lineNum, newNode->intVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == FLOAT) {
		newNode->realVal = expr1->realVal / expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == INTEGER && expr2->type == FLOAT) {
		newNode->realVal = expr1->intVal / expr2->realVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == FLOAT && expr2->type == INTEGER) {
		newNode->realVal = expr1->realVal / expr2->intVal;
		newNode->lineNum = expr1->lineNum;
		newNode->type = FLOAT;
		printf("Result of expression on %d is (%f)\n", newNode->lineNum, newNode->realVal);
		return newNode;
	}
	else if(expr1->type == NONCONST || expr2->type == NONCONST) {
		newNode->type = NONCONST;
		return newNode;
	}
	else {
		printf("Type mismatch on %d\n", expr1->lineNum);
		return NULL;
	}

}
//-----------------------------------------------------------------------------------------------------
void printTopLevelResult(ExprNode * expr) {

	//printf("printTopLevelResult function entered.\n");
	if(expr->type == INTEGER && expr != NULL) {
		//printf("entered int\n");
		printf("Result of expression on %d is (%d)\n", expr->lineNum, expr->intVal);
	}
	else if(expr->type == FLOAT && expr != NULL) {
		//printf("entered float\n");
		printf("Result of expression on %d is (%f)\n", expr->lineNum, expr->realVal);
	}
	else if(expr->type == STRING && expr != NULL) {
		//printf("entered string\n");
		printf("Result of expression on %d is (%s)\n", expr->lineNum, expr->identifier);
	}
	else {
		//printf("entered none\n");
		return;
	}

}
//-----------------------------------------------------------------------------------------------------
										    /* M A I N */
//-----------------------------------------------------------------------------------------------------
int main ()
{
if (yyparse()) {
// parse error
printf("ERROR\n");
return 1;
}
else {
// successful parsing
printf("\n");
return 0;
}
}
