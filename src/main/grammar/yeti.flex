/* Yeti language lexer */

package yeti.comp;

import beaver.Symbol;
import beaver.Scanner;

import static yeti.comp.YetiParser.Terminals.*;

%%

%public
%class YetiScanner
%extends Scanner
%function nextToken
%type Symbol
%yylexthrow Scanner.Exception
%eofval{
	return new Symbol(EOF, "end-of-file");
%eofval}

%unicode

%line
%column

%{
	final private StringBuilder string = new StringBuilder();
	
	private Symbol symbol(short type) {
		return new Symbol(type, yyline+1, yycolumn+1, yylength());
	}
	
	private Symbol symbol(short type, Object value) {
		return new Symbol(type, yyline+1, yycolumn+1, yylength(), value);
	}

%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | 
          {DocumentationComment}

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/*" "*"+ [^/*] ~"*/"

IdHead = [a-z?_]
IdRemain = [a-zA-Z0-9?_']
Symbol1 = [!$%&*+./<>?@\^|-~]
Symbol2 = {Symbol1} | [=:]
Digit = [0-9]
StringCharacter = [^\r\n\"\\]

/* identifiers */
Identifier = {IdHead} {IdRemain}*
Variant = [A-Z] {IdRemain}*
SymOper = {Symbol1}+ | {Symbol2} {Symbol2}+
ModId = [A-Za-z]+ \.
QId = {ModId}* Identifier

/* literals */
Number         = {Digit}+ (\. {Digit}*)? ([eE] [+-]? {Digit}+)?
String1        = \' ( [^\r\n\'] | \' \' )* \'

%state STRING2, STRING3

%%

<YYINITIAL> {

  "module"                       { return symbol(MODULE); }
  "program"                      { return symbol(PROGRAM); }
//  "load"                         { return symbol(LOAD); }
  
  "case"                         { return symbol(CASE); }
  "of"                           { return symbol(OF); }
  "esac"                         { return symbol(ESAC); }
  
  "if"                           { return symbol(IF); }
  "else"                         { return symbol(ELSE); }
  "elif"                         { return symbol(ELIF); }
  "then"                         { return symbol(THEN); }
  "fi"                           { return symbol(FI); }

  "var"                          { return symbol(VAR); }

  /* boolean literals */
  "true"                         { return symbol(BOOLEAN_LITERAL, Boolean.TRUE); }
  "false"                        { return symbol(BOOLEAN_LITERAL, Boolean.FALSE); }
  
  /* null literal */
  "()"                           { return symbol(UNIT_LITERAL); }
  
  /* separators */
  "="                            { return symbol(EQ); }
  "("                            { return symbol(LPAREN); }
  ")"                            { return symbol(RPAREN); }
  "["                            { return symbol(LBRACKET); }
  "]"                            { return symbol(RBRACKET); }
  ";"                            { return symbol(SEMI); }
  ","                            { return symbol(COMMA); }
  ".."                           { return symbol(DOTDOT); }
//  "."                            { return symbol(DOT); }
  ":"                            { return symbol(COLON); }
  "::"                           { return symbol(COLONCOLON); }
  ":="                           { return symbol(COLONEQ); }
  "_"                            { return symbol(UNDERLINE); }
  "-"                            { return symbol(MINUS); }
  "`"                            { return symbol(ACCENT); }

  /* identifiers */ 
  {Identifier}                   { return symbol(IDENTIFIER, yytext()); }  
  {QId}                          { return symbol(QID, yytext()); }  
  {SymOper}                      { return symbol(SYMOPER, yytext()); }  

  /* literals */
  /* Maybe we need to split between integers and floats? */
  {Number}                       { return symbol(NUMBER_LITERAL, yytext()); }
/*  {Number}                       { return symbol(NUMBER_LITERAL, new BigDecimal(yytext())); }*/
  {String1}                      { return symbol(STRING1_LITERAL, yytext()); }

%terminals STRING2_LITERAL, STRING3_LITERAL;
  
  "\"\"\""                       { yybegin(STRING3); string.setLength(0); }
  \"                             { yybegin(STRING2); string.setLength(0); }

  /* comments */
  {Comment}                      { /* ignore */ }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */ }
}

/* TODO is it possible to put common stuff of string 2 & string3 altogether? */

<STRING2> {
  \"                             { yybegin(YYINITIAL); return symbol(STRING2_LITERAL, string.toString()); }
  
  {StringCharacter}+             { string.append( yytext() ); }
  
  "\\b"                          { string.append( '\b' ); }
  "\\t"                          { string.append( '\t' ); }
  "\\n"                          { string.append( '\n' ); }
  "\\f"                          { string.append( '\f' ); }
  "\\r"                          { string.append( '\r' ); }
  "\\\""                         { string.append( '\"' ); }
  "\\'"                          { string.append( '\'' ); }
  "\\\\"                         { string.append( '\\' ); }

  /* TODO: missing \(exp) and \uXXXX */  
  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated string at end of line"); }
}

<STRING3> {
  "\"\"\""                       { yybegin(YYINITIAL); return symbol(STRING3_LITERAL, string.toString()); }
  
  {StringCharacter}+             { string.append( yytext() ); }
  "\""                           { string.append( '\"' ); }
  
  "\\b"                          { string.append( '\b' ); }
  "\\t"                          { string.append( '\t' ); }
  "\\n"                          { string.append( '\n' ); }
  "\\f"                          { string.append( '\f' ); }
  "\\r"                          { string.append( '\r' ); }
  "\\'"                          { string.append( '\'' ); }
  "\\\\"                         { string.append( '\\' ); }

  /* TODO: missing \(exp) and \uXXXX */  
  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated string at end of line"); }
}

/* error fallback */
.|\n                             { throw new RuntimeException("Illegal character \""+yytext()+
                                                              "\" at line "+yyline+", column "+yycolumn); }
<<EOF>>                          { return symbol(EOF); }
