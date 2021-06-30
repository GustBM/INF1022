// Eduardo Junqueira / 1710329
// Gustavo Barros / 1521500


%{
    
    #define COMANDOENTRADA 0
    #define COMANDOFIM 1
    #define COMANDOINC 2
    #define COMANDOZERA 3
    #define COMANDOATT 4
    #define COMANDOSE 5
    #define COMANDOSENAO 6
    #define COMANDOENQUANTO 7
    #define COMANDOREP 8
    #define COMANDOEND 9

    #include <stdio.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>
    
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    FILE *outputFile;


    //comandos e suas variaveis
    typedef struct line Line;
    struct line
    {
        int comando;
        char *var1;
        char *var2;
    };

    //lista encadeada para os comandos
    typedef struct lista Lista;
    struct lista 
    {
        Lista *prev;
        Lista *next;
        Line elemento;
    };

    void insereFinal(Lista *el, Lista *primeiro) 
    {

        
        Lista *ultimo = primeiro;
        while (ultimo->next != NULL) 
        {
            ultimo = ultimo->next;
        }
        ultimo->next = el;
        el->prev = ultimo; 
        return;
    }

    void insereInicio(Lista *el, Lista *primeiro) 
    {
        el->next = primeiro;
        primeiro->prev = el;
    }


    void criaCodigo(Lista *e) 
    {
        while (e != NULL) 
        {
            switch (e->elemento.comando) 
            {
                case COMANDOENTRADA:
                {

                    char *var = strtok(e->elemento.var1, " ");
                    while (var != NULL) 
                    {
                        fprintf(outputFile, "int %s;\n", var);                      
                        fprintf(outputFile, "printf(\"Input %s:\");\n", var);   
                        fprintf(outputFile, "scanf(\"%s\",&%s);\n", "%d", var);       
                        var = strtok(NULL, " ");
                    }

                    var = strtok(e->elemento.var2, " ");
                    while (var != NULL) 
                    {
                        fprintf(outputFile, "%s = 0\n", var);      
                        var = strtok(NULL, " ");               
                    }
                    break;
                }
                case COMANDOFIM:
                {
                    char *var = strtok(e->elemento.var1, " ");  
                    while (var != NULL) 
                    {
                        fprintf(outputFile, "printf(\"%s = %s\\n\" , %s);\n", var, "%d", var);
                        var = strtok(NULL, " ");
                    }
                    break;
                }
                case COMANDOINC:
                {
                    fprintf(outputFile, "%s ++;\n", e->elemento.var1);
                    break;
                }
                case COMANDOZERA:
                {
                    fprintf(outputFile, "%s = 0;\n", e->elemento.var1);
                    break;
                }
                case COMANDOATT:
                {
                    fprintf(outputFile, "%s=%s;\n", e->elemento.var1, e->elemento.var2);
                    break;
                }
                case COMANDOSE:
                {
                    fprintf(outputFile, "if (%s > 0){\n	", e->elemento.var1);
                    break;
                }
                case COMANDOSENAO:
                {
                    fprintf(outputFile, "else{\n");
                    break;
                }
                case COMANDOENQUANTO:
                {
                    fprintf(outputFile, "while (%s > 0){\n", e->elemento.var1);
                    
                    break;
                }
                case COMANDOREP:
                {
                    fprintf(outputFile, "int i;\nfor(i=0;i<%s;i++;){\n", e->elemento.var1);
                    
                    break;
                }
                case COMANDOEND:
                { 
                    fprintf(outputFile, "}\n");
                    break;
                }
            }
            e = e->next;
        }
        fclose(outputFile);
    }

    void yyerror(const char *s) 
    {
        fprintf(stderr, "\n%s\n", s);
        exit(errno);
    };
%}

%union 
{
    int dval;
    char *sval;
    struct lista *val;
}

%token ENTRADA
%token SAIDA
%token FIM
%token FACA
%token INC
%token ZERA
%token PARFECHA
%token PARABRE
%token IGUAL
%token ENQUANTO
%token <sval> ID
%token VEZES
%token SE
%token SENAO

%type <dval> program
%type <sval> varlist
%type <val> cmds
%type <val> cmd


%start program
%%

program 
    : ENTRADA varlist SAIDA varlist cmds FIM 
    {
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        Lista *el2 = (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL || el2 == NULL) 
        {
            printf("Erro no malloc\n");
            exit(-1);
        }

        el1->elemento.comando = COMANDOENTRADA;
        el1->elemento.var1 = $2;
        el1->elemento.var2 = $4;
        el2->elemento.comando = COMANDOFIM;
        el2->elemento.var1 = $4;

        insereInicio(el1, $5);
        insereFinal(el2, el1);
        criaCodigo(el1);
    }
    ;

varlist 
    : varlist ID    
    {
        char buff[100];
        snprintf(buff, 100, "%s %s", $1, $2);
        $$ = buff;
    }

    | ID
    {
        $$ = $1;
    }
    ;
        

cmds : 
    cmds cmd
    { 
        insereFinal($2, $1); $$ = $1;
    }
    | cmd
    { 
        $$ = $1; 
    }
    ;


cmd :
    ID IGUAL ID 
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL) 
        {
            printf("Erro no malloc (IGUAL)\n");
            exit(-1);
        }

        el1->elemento.var1 = $1;
        el1->elemento.var2 = $3;
        el1->elemento.comando = COMANDOATT;
        $$ = el1;
    }

    | INC PARABRE ID PARFECHA 
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL) 
        {
            printf("Erro no malloc (INC)\n");
            exit(-1);
        }

        el1->elemento.var1 = $3;
        el1->elemento.comando = COMANDOINC;
        $$ = el1;
    }

    | ZERA PARABRE ID PARFECHA
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL) 
        {
            printf("Erro no malloc (ZERA)\n");
            exit(-1);
        }
        
        el1->elemento.var1 = $3;
        el1->elemento.comando = COMANDOZERA;
        $$ = el1;
    }

    | FACA ID VEZES cmds FIM 
    {
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        Lista *el2 = (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL || el2 == NULL) 
        {
            printf("Erro no malloc (FACA)\n");
            exit(-1);
        }

        el1->elemento.var1 = $2;
        el1->elemento.comando = COMANDOREP;
        el2->elemento.comando = COMANDOEND;

        insereFinal($4, el1);
        insereFinal(el2,el1);
        $$ = el1;
    }

    | SE ID cmds FIM 
    {
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        Lista *el2 = (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL || el2 == NULL) 
        {
            printf("Erro no malloc (SE)\n");
            exit(-1);
        }
        
        el1->elemento.comando = COMANDOSE;
        el1->elemento.var1 = $2;
        el2->elemento.comando = COMANDOEND;

        insereFinal($3, el1);
        insereFinal(el2,el1);
        $$ = el1;
        
    }

    | SE ID cmds SENAO cmds FIM 
    {
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        Lista *el2 = (Lista *)malloc(sizeof(Lista));
        Lista *el3 = (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL || el2 == NULL || el3 == NULL) 
        {
            printf("Erro no malloc (SENAO)\n");
            exit(-1);
        }

        el1->elemento.var1 = $2;
        el1->elemento.comando = COMANDOSE;
        el2->elemento.comando = COMANDOSENAO;
        el3->elemento.comando = COMANDOEND;

        insereFinal($3, el1);
        insereFinal(el2, el1);
        insereFinal($5, el1);
        insereFinal(el3, el1);

        $$ = el1;
    }

    | ENQUANTO ID FACA cmds FIM 
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        Lista *el2 = (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL || el2 == NULL) 
        {
            printf("Erro no malloc (ENQUANTO)\n");
            exit(-1);
        }

        el1->elemento.var1 = $2;
        el1->elemento.comando = COMANDOENQUANTO;
        el2->elemento.comando = COMANDOEND;

        insereFinal($4, el1);
        insereFinal(el2,el1);
        $$ = el1;
    }
    ;
%%

int main(int argc, char **argv) 
{
    if (argc != 3) 
    {
        printf("provol-One: <Arquivo de Entrada> <Arquivo de Saida>");
        exit(-1);
    }
    printf("Programa iniciado \n");

    printf("Abrindo arquivo %s...", argv[1]);
    FILE *inputFile = fopen(argv[1], "r");
    if (inputFile == NULL) {
        printf("Erro abrindo arquivo de entrada\n");
        exit(-3);
    }

    printf("Arquivo %s aberto \n", argv[1]);
    printf("Abrindo arquivo %s...", argv[2]);
    outputFile = fopen(argv[2], "w+");

    if (outputFile == NULL) 
    {
        printf("Erro na criacao do arquivo de saida\n");
        exit(-1);
    }
    printf("Arquivo %s aberto \n", argv[2]);

    yyin = inputFile;
    yyparse();
    return 0;
}
