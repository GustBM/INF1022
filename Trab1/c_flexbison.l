%{

#include <stdio.h>
#include <string.h>
#define HASH_SIZE 1000
void showError();

typedef struct Ht_item Ht_item;
struct Ht_item {
    char* key;
    int value;
};

typedef struct HashTable HashTable;
struct HashTable {
    Ht_item** items;
};

HashTable* create();
void insert(int val, HashTable* hs_table);
int get(int val, HashTable* hs_table);
unsigned long hash_function(char* str);

/* Token type.  */
enum yytokentype
  {
    EOL = 258,
    ABS = 259,
    ADD = 260,
    SUB = 261,
    MUL = 262,
    DIV = 263,
    NUM = 264,
    STRING = 265,
    SEMICOLON = 266,
    EQ = 267,
    OTHER = 268,
    INT = 269
  };

  int yylval;
%}

numbers     ([0-9])+
alpha       ([a-zA-Z])+

%%

\n      return(EOL);
"|"    { return ABS; }
"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
"="     return(EQ);
"int"   {return INT;}
{alpha}		{sscanf(yytext, "%s", yylval.name); return (STRING);}
{numbers}	{yylval.number = atoi(yytext); return (NUM);}
";"		{return (SEMICOLON);}
.		{showError(); return(OTHER);}

%%


void showError(){
    printf("Other input");
}

HashTable* create(int size) {
    HashTable *hashtable = malloc(sizeof(HashTable) * 1);
    hashtable->items = malloc(sizeof(Ht_item*) * HASH_SIZE);

    int i = 0;
    for (; i < HASH_SIZE; ++i) {
        hashtable->items[i] = NULL;
    }
    return hashtable;
}

unsigned long hash_function(char* str) {
    unsigned long i = 0;
    for (int j=0; str[j]; j++)
        i += str[j];
    return i % HASH_SIZE;
}

void insert(int val, HashTable* hs_table) {
    unsigned long pos = hash_function(val);
    while(hs_table->items[pos]->value != NULL)
        pos++;
    hs_table->items[pos]-> value = val;
}

int get(int val, HashTable* hs_table) {
    unsigned long pos = hash_function(val);
    while(hs_table->items[pos]->value != NULL || hs_table->items[pos]->value != val)
        pos+1;
    if(hs_table->items[pos]->value == val) return pos;
    else return -1;
}

int main()
{
    yylex();
    return 0;
}
