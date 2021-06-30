%{

    #define Compile_ENTRADA 0
    #define Compile_FINAL 1
    #define Compile_INCREMENTA 2
    #define Compile_ZERA 3
    #define Compile_ENQUANTO 4
    #define Compile_ATRIBUICAO 5
    #define Compile_REPETICAO 6
    #define Compile_SE 7
    #define Compile_SENAO 8
    #define Compile_END 100
    #define comando_t short
    
    #include <stdio.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>

    struct linha{
        comando_t comando;      // comando principal
        char *var1;             // variavel 1
        char *var2;             // variavel 2
    };
    typedef struct linha Linha;

    typedef struct elemento Elemento;
    struct elemento {
        struct elemento *prev;
        struct elemento *next;
        Linha linha;
    };

    void insereElementoFinal(Elemento *e, Elemento *lista) {
        // andando ate o final
        Elemento *ultimo = lista;
        while (ultimo->next != NULL) {
            ultimo = ultimo->next;
        }
        ultimo->next = e;
        e->prev = ultimo; 
        return;
    }

    void insereElementoInicio(Elemento *e, Elemento *lista) {
        Elemento *ultimo = e;
        while (ultimo->next != NULL) {
            ultimo = ultimo->next;
        }
        e->next = lista;
        lista->prev = e;
    }

    extern int yylex();
    extern FILE *yyin;      
    extern int yyparse();   
    FILE *fileC;
    int tipoArquivo;

    void yyerror(const char *s) {
        fprintf(stderr, "%s\n", s);
        exit(errno);
    };

    void openFile() {
        fileC = fopen("resultado.c", "w+");
        if (fileC == NULL) {
            printf("Houve um problema na criacao do arquivo\n");
            exit(-1);
        }
    }

    void closeFile() {
        fclose(fileC);
        return;
    }

    /*
        Recebe uma quantidade de tabs, e retorna uma string contendo
        os tabs (exemplo para q=3: "\t\t\t\0")
        Usando para o Python, mas pode ser usado nos outros códigos para
        melhorar o código gerado
    */
    char *criaIdent(int q) {
        char *tabs = (char *) malloc (sizeof(char) * (q+1));
        for (int i = 0 ; i <= q ; i++) {
            tabs[i] = '\t';
        }
        tabs[q] = '\0';
        return tabs;
    }

        void criaCodigoC(Elemento *e) {
        openFile();
        fprintf(fileC, "#include <stdio.h>\nvoid main() {\n");
        while (e != NULL) {
            switch (e->linha.comando) {
                case Compile_ATRIBUICAO: {
                    fprintf(fileC, "%s = %s;\n", e->linha.var1, e->linha.var2);
                    break;
                }
                case Compile_ZERA: {
                    fprintf(fileC, "%s = 0;\n", e->linha.var1);
                    break;
                }
                case Compile_INCREMENTA: {
                    fprintf(fileC, "%s++;\n", e->linha.var1);
                    break;
                }
                case Compile_ENQUANTO: {
                    fprintf(fileC, "while (%s > 0) {\n", e->linha.var1);
                    break;
                }
                case Compile_END: {
                    fprintf(fileC, "}\n"); 
                    break;
                }
                case Compile_FINAL: {
                    // var1 eh a lista de variaveis
                    // splitando a lista de strings
                    
                    char *variavel = strtok(e->linha.var1, " ");  // faz um split na lista de variaveis
                    while (variavel != NULL) {
                        fprintf(fileC, "printf(\"Saida: [%s] = %s\\n\", %s);\n", variavel, "%d", variavel);  // imprime a saida
                        variavel = strtok(NULL, " ");   // proxima string da lista de variaveis
                    }
                    fprintf(fileC, "return;}"); // coloca as ultimas linhas
                    break;
                }
                case Compile_ENTRADA: {
                    // var1 eh a lista de variaveis a serem iniciadas
                    // splitando a lista de strings
                    char *variavel = strtok(e->linha.var1, " ");
                    while (variavel != NULL) {
                        // para cada variavel, sera inicializada e scaneada
                        fprintf(fileC, "int %s;\n", variavel);                      // inicia a variavel
                        fprintf(fileC, "printf(\"Entrada [%s]:\");\n", variavel);   // coloca um print
                        fprintf(fileC, "scanf(\"%s\",&%s);\n", "%d", variavel);      // coloca um scan
                        
                        variavel = strtok(NULL, " ");   // proxima string da lista de variaveis
                    }

                    // var2 eh a lista de variaveis finais, que devem ser inicializadas
                    variavel = strtok(e->linha.var2, " ");
                    while (variavel != NULL) {
                        // para cada variavel, ela deve ser inicializada
                        fprintf(fileC, "int %s = 0;\n", variavel);      // inicia a variavel
                        variavel = strtok(NULL, " ");               // proxima string da lista de variaveis
                    }
                    break;
                }
                case Compile_REPETICAO: {
                    fprintf(fileC, "for (int _i = 0; _i<%s; _i++) {\n", e->linha.var1);
                    break;
                }

                case Compile_SE: {
                    fprintf(fileC, "if (%s){ ", e->linha.var1);
                    break;
                }

                case Compile_SENAO: {
                    fprintf(fileC, "} else {\n");
                    break;
                }
            }
            e = e->next;
        }
        closeFile();
    }

%}

%token ENTRADA
%token SAIDA
%token FIM
%token ENQUANTO
%token FACA
%token INC
%token ZERA
%token PARFECHA
%token PARABRE
%token IGUAL
%token <sval> ID
%token VEZES
%token SE
%token SENAO


%union {
    int ival;
    char *sval;
    struct elemento *eval;
}

%type <ival> program
%type <sval> varlist
%type <eval> cmds
%type <eval> cmd


%start program
%%

program : ENTRADA varlist SAIDA varlist cmds FIM {
    Elemento *e = (Elemento *)malloc(sizeof(Elemento));
    if (e == NULL) {printf("Erro no while!\n");exit(-1);}
    e->linha.var1 = $2;
    e->linha.var2 = $4;
    e->linha.comando = Compile_ENTRADA;
    insereElementoInicio(e, $5);

    Elemento *ee = (Elemento *)malloc(sizeof(Elemento));
    if (ee == NULL) {printf("Erro no while!\n");exit(-1);}
    ee->linha.var1 = $4;
    ee->linha.comando = Compile_FINAL;
    insereElementoFinal(ee, e);
    
    criaCodigoC(e);
   
}
    ;

varlist : varlist ID    {
        char buffer[100];
        snprintf(buffer, 100, "%s %s", $1, $2);
        $$ = buffer;
    }

    | ID            {$$ = $1;}
    ;
        

cmds : cmds cmd         { insereElementoFinal($2, $1); $$ = $1; }
     | cmd              { $$ = $1; }
     ;


cmd : ENQUANTO ID FACA cmds FIM { 
    Elemento *e = (Elemento *)malloc(sizeof(Elemento));
    if (e == NULL) {printf("Erro no while!\n");exit(-1);}

    e->linha.var1 = $2;
    e->linha.comando = Compile_ENQUANTO;
    insereElementoFinal($4, e);

    Elemento *ee = (Elemento *)malloc(sizeof(Elemento));
    if (ee == NULL) {printf("Erro no while!\n");exit(-1);}
    
    ee->linha.comando = Compile_END;
    insereElementoFinal(ee,e);
    $$ = e;
 }

    | ID IGUAL ID { 
        Elemento *e = (Elemento *)malloc(sizeof(Elemento));
        if (e == NULL) {printf("Erro na atribuicao!\n");exit(-1);}

        e->linha.var1 = $1;
        e->linha.var2 = $3;
        e->linha.comando = Compile_ATRIBUICAO;
        $$ = e;
    }

    | INC PARABRE ID PARFECHA { 
        Elemento *e = (Elemento *)malloc(sizeof(Elemento));
        if (e == NULL) {printf("Erro na incrementacao!\n");exit(-1);}
        e->linha.var1 = $3;
        e->linha.comando = Compile_INCREMENTA;
        $$ = e;
    }

    | ZERA PARABRE ID PARFECHA { 
        Elemento *e = (Elemento *)malloc(sizeof(Elemento));
        if (e == NULL) {printf("Erro no zerar!\n");exit(-1);}
        e->linha.var1 = $3;
        e->linha.comando = Compile_ZERA;
        $$ = e;
    }

    | FACA ID VEZES cmds FIM {

        Elemento *e = (Elemento *)malloc(sizeof(Elemento));
        if (e == NULL) {printf("Erro no VEZES!\n");exit(-1);}

        e->linha.var1 = $2;
        e->linha.comando = Compile_REPETICAO;
        insereElementoFinal($4, e);

        Elemento *ee = (Elemento *)malloc(sizeof(Elemento));
        if (ee == NULL) {printf("Erro no while!\n");exit(-1);}
    
        ee->linha.comando = Compile_END;
        insereElementoFinal(ee,e);
        $$ = e;
    }

    | SE ID cmds FIM {
        
        Elemento *e = (Elemento*)malloc(sizeof(Elemento ));
        if (e == NULL) {printf("Erro no VEZES!\n");exit(-1);}
        
        e->linha.comando = Compile_SE;
        e->linha.var1 = $2;

        insereElementoFinal($3, e);
        
        Elemento *ee = (Elemento *)malloc(sizeof(Elemento));
        if (ee == NULL) {printf("Erro no while!\n");exit(-1);}
    
        ee->linha.comando = Compile_END;
        insereElementoFinal(ee,e);
        $$ = e;
        
    }

    | SE ID cmds SENAO cmds FIM {

        Elemento *e = (Elemento *)malloc(sizeof(Elemento));
        if (e == NULL) {printf("Erro no SE-SENAO!\n");exit(-1);}

        e->linha.var1 = $2;
        e->linha.comando = Compile_SE;
        insereElementoFinal($3, e);

        Elemento *ee = (Elemento *)malloc(sizeof(Elemento));
        if (ee == NULL) {printf("Erro no SE-SENAO!\n");exit(-1);}

        ee->linha.comando = Compile_SENAO;
        insereElementoFinal(ee, e);
        insereElementoFinal($5, e);

        Elemento *eee = (Elemento *)malloc(sizeof(Elemento));
        if (eee == NULL) {printf("Erro no SE-SENAO!\n");exit(-1);}

        eee->linha.comando = Compile_END;
        insereElementoFinal(eee, e);

        $$ = e;
    }
    ;
%%


int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Uso correto: %s arquivo.provolone", argv[0]);
        exit(-1);
    }
    FILE *arquivoInput = fopen(argv[1], "r");
    if (arquivoInput == NULL) {
        printf("Erro abrindo arquivo de leitura!\n");
        exit(-3);
    }
 
    openFile();

    printf("Executando parser\n");
    yyin = arquivoInput;
    yyparse();

    printf("Finalizando parser\n");
    return 0;
}
