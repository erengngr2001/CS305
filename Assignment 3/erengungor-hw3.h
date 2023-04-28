#ifndef __MS_H
#define __MS_H

typedef enum {INTEGER, FLOAT, STRING, NONCONST} ExprTypes;

typedef struct RealNode
{
    char *value;
    int lineNum;
} RealNode;

typedef struct IntNode
{
    char *value;
    int lineNum;
} IntNode;

typedef struct StringNode
{
    char *value;
    int lineNum;
} StringNode;

typedef struct ExprNode 
{
    ExprTypes type;
    char *identifier;
    int intVal;
    float realVal;
    int lineNum;
} ExprNode;

#endif