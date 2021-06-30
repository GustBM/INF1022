// Eduardo Junqueira / 1710329
// Gustavo Barros / 1521500


%{
    // Foi adicionado uma letra "C" antes da acao para 
    // diferencia-la do token definido mais a frente
    #define CENTRADA 0
    #define CFIM 1
    #define CINC 2
    #define CZERA 3
    #define CATT 4
    #define CSE 5
    #define CSENAO 6
    #define CENQUANTO 7
    #define CREP 8
    #define CEND 9

    #include <stdio.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>
    
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    FILE *arqOut;

    typedef struct linha Linha;
    struct linha
    {
        int comando;
        char *var1;
        char *var2;
    };

    typedef struct lista Lista;
    struct lista 
    {
        Lista *prev;
        Lista *next;
        Linha elemento;
    };

    void insereFinal(Lista *el, Lista *primeiro) 
    {
        // Insere o elemento "el" no apos percorrer ate o final
        // do primeiro item dado.
        
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
        // Insere elemento "el" antes do primeiro item dado
        el->next = primeiro;
        primeiro->prev = el;
    }


    void criaCodigo(Lista *e) 
    {
        while (e != NULL) 
        {
            switch (e->elemento.comando) 
            {
                case CENTRADA:
                {
                    // Tentamos utilizar dos parametros argv[] para popular as variaveis do programa, porem nao 
                    // conseguimos deixar funcional antes da entrega. Portanto utilizamos simplesmente um input
                    // no programa resultante.
                    char *var = strtok(e->elemento.var1, " ");
                    while (var != NULL) 
                    {
                        fprintf(arqOut, "int %s;\n", var);                      
                        fprintf(arqOut, "printf(\"Entrada [%s]:\");\n", var);   
                        fprintf(arqOut, "scanf(\"%s\",&%s);\n", "%d", var);       
                        var = strtok(NULL, " ");
                    }

                    var = strtok(e->elemento.var2, " ");
                    while (var != NULL) 
                    {
                        fprintf(arqOut, "%s = 0\n", var);      
                        var = strtok(NULL, " ");               
                    }
                    break;
                }
                case CFIM:
                {
                    char *var = strtok(e->elemento.var1, " ");  
                    while (var != NULL) 
                    {
                        fprintf(arqOut, "printf(\"%s = %s\\n\" , %s);\n", var, "%d", var);
                        var = strtok(NULL, " ");
                    }
                    break;
                }
                case CINC:
                {
                    // Incrementa var em 1
                    fprintf(arqOut, "%s ++;\n", e->elemento.var1);
                    break;
                }
                case CZERA:
                {
                    // Atualiza o valor de var para zero
                    fprintf(arqOut, "%s = 0;\n", e->elemento.var1);
                    break;
                }
                case CATT:
                {
                    // Atribui o valor de var2 a var1
                    fprintf(arqOut, "%s=%s;\n", e->elemento.var1, e->elemento.var2);
                    break;
                }
                case CSE:
                {
                    // Testa se var1 > 0
                    fprintf(arqOut, "if (%s > 0){\n	", e->elemento.var1);
                    break;
                }
                case CSENAO:
                {
                    // Else
                    fprintf(arqOut, "else{\n");
                    break;
                }
                case CENQUANTO:
                {
                    // Enquanto var1 > 0
                    fprintf(arqOut, "while (%s > 0){\n", e->elemento.var1);
                    
                    break;
                }
                case CREP:
                {
                    // Repete cmd var1 vezes
                    fprintf(arqOut, "int i;\nfor(i=0;i<%s;i++;){\n", e->elemento.var1);
                    
                    break;
                }
                case CEND:
                { 
                    fprintf(arqOut, "}\n");
                    break;
                }
            }
            e = e->next;
        }
        fclose(arqOut);
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
%token FPAR
%token APAR
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

        el1->elemento.comando = CENTRADA;
        el1->elemento.var1 = $2;
        el1->elemento.var2 = $4;
        el2->elemento.comando = CFIM;
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
        el1->elemento.comando = CATT;
        $$ = el1;
    }

    | INC APAR ID FPAR 
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL) 
        {
            printf("Erro no malloc (INC)\n");
            exit(-1);
        }

        el1->elemento.var1 = $3;
        el1->elemento.comando = CINC;
        $$ = el1;
    }

    | ZERA APAR ID FPAR 
    { 
        Lista *el1= (Lista *)malloc(sizeof(Lista));
        if (el1 == NULL) 
        {
            printf("Erro no malloc (ZERA)\n");
            exit(-1);
        }
        
        el1->elemento.var1 = $3;
        el1->elemento.comando = CZERA;
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
        el1->elemento.comando = CREP;
        el2->elemento.comando = CEND;

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
        
        el1->elemento.comando = CSE;
        el1->elemento.var1 = $2;
        el2->elemento.comando = CEND;

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
        el1->elemento.comando = CSE;
        el2->elemento.comando = CSENAO;
        el3->elemento.comando = CEND;

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
        el1->elemento.comando = CENQUANTO;
        el2->elemento.comando = CEND;

        insereFinal($4, el1);
        insereFinal(el2,el1);
        $$ = el1;
    }
    ;
%%

int main(int argc, char **argv) 
{
    // Passar como argumentos os nomes dos arquivos
    // de entrada e saida
    if (argc != 3) 
    {
        printf("\nNumero incorreto de argumentos\n");
        exit(-1);
    }

    // Abre o arquivo de entrada
    FILE *arqIn = fopen(argv[1], "r");
    if (arqIn == NULL) {
        printf("Erro abrindo arquivo de entrada\n");
        exit(-3);
    }
    
    // Abre o arquivo de saida
    arqOut = fopen(argv[2], "w+");
    
    if (arqOut == NULL) 
    {
        printf("Erro na criacao do arquivo de saida\n");
        exit(-1);
    }

    yyin = arqIn;
    yyparse();
    return 0;
}
