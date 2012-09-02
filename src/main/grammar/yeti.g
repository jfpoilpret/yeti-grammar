/*
Name    : YETI
Author  : Jean-François Poilprêt
Version : 0.4

About :
Initial grammar, first driven by a simplified Haskell grammar
*/

%header {: /* TODO COMMENTS */ :} ;

%package "yeti.comp";
%class "YetiParser";
%embed {: /* Parser class fields go here */:} ;
%init {: /* Parser constructor fields initialization go here */:} ;

%terminals LBRACKET, DOTDOT, RBRACKET;
//%terminals DOT;
//%terminals LBRACE, RBRACE;
%terminals LPAREN, RPAREN;
%terminals EQ;
%terminals SEMI, COMMA;
//%terminals BACKSLASH;
%terminals MINUS;

%terminals MODULE, PROGRAM;
//%terminals LOAD;
%terminals IF, ELSE, ELIF, THEN, FI;
%terminals CASE, OF, COLON, COLONCOLON, UNDERLINE, ESAC;
//%terminals DO, DONE;
//%terminals LOOP;
%terminals VAR, COLONEQ;

%terminals NUMBER_LITERAL, BOOLEAN_LITERAL, UNIT_LITERAL;
%terminals STRING1_LITERAL, STRING2_LITERAL, STRING3_LITERAL;
%terminals IDENTIFIER;
%terminals QID;
//%terminals TAG;
%terminals ACCENT, SYMOPER;

/* Precedence and associativity of symbols shoudl go here 
%left symbol,...
%right symbol,...
*/

//%left SEMI;
//%right SEMI;

%goal program ;

program = PROGRAM QID SEMI decls
        | MODULE QID SEMI decls
        | decls
        ;

//sid = IDENTIFIER DOT;
//qid = sid* IDENTIFIER;

decls = decl* 
      ;

decl = IDENTIFIER arg* EQ atomic SEMI
     | VAR IDENTIFIER EQ atomic SEMI
     | IDENTIFIER COLONEQ atomic SEMI
     | expr SEMI
     | SEMI
     ;

// TODO must also support structs
arg = IDENTIFIER 
    | UNIT_LITERAL
    ;

literal = STRING1_LITERAL
        | STRING2_LITERAL 
        | STRING3_LITERAL
        | NUMBER_LITERAL 
        | BOOLEAN_LITERAL 
        | UNIT_LITERAL 
        ;

operator = ACCENT IDENTIFIER ACCENT 
         | SYMOPER 
         ;

atomic = literal 
       | IDENTIFIER 
       | list 
       | LPAREN expr RPAREN 
       | LPAREN atomic operator RPAREN 
       | LPAREN operator atomic RPAREN 
       | LPAREN SYMOPER RPAREN 
       ;

// TODO is that really the right way to enable function calls?
// the grammar seems to authorize pointless expressions like:
//  [1, 2, 3] var1 var2
expr = atomic 
     | expr atomic 
     | expr operator expr 
     | MINUS expr 
     | IF expr THEN expr elifexpr* ELSE expr FI 
     | CASE expr OF matches ESAC 
//     | expr SEMI expr 
     ;
//TODO above it should be something like this instead:
//   | decl SEMI expr 
//   | expr SEMI expr? 

elifexpr = ELIF expr THEN expr
         ;

matches = match
        | matches SEMI match
        ;
//TODO actually the expr can be a declaration (or several) as long as the last decl is an expression...         
match = pattern COLON expr
      ;

/*
matches = match1
        | match2 matches
        | matches SEMI
        ;
         
match1 = pattern COLON atomic
       ;
match2 = pattern COLON atomic SEMI
       ;
*/

/*
expr = atomic 
     | expr atomic 
     | expr operator expr 
     | MINUS expr 
     | IF expr THEN expr elifexpr* ELSE expr FI 
     | CASE expr OF patternexpr patternexpr1* SEMI? ESAC 
     | expr SEMI expr 
     ;

elifexpr = ELIF expr THEN expr
         ;
         
patternexpr = pattern COLON atomic 
            ;

patternexpr1 = SEMI patternexpr
             ;
*/

pattern = literal 
        | LPAREN pattern RPAREN 
        | LBRACKET RBRACKET 
        | LBRACKET pattern pattern1* RBRACKET 
        | pattern COLONCOLON pattern 
        | IDENTIFIER 
        | UNDERLINE
        ;

pattern1 = COMMA pattern
         ;

list = LBRACKET RBRACKET 
     | LBRACKET expr DOTDOT expr RBRACKET 
     | LBRACKET expr list1* COMMA? RBRACKET 
     ;

list1 = COMMA expr
      ;
