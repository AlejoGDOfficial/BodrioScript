package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    EBinaryExpr(left:Expr, rigth:Expr, op:String);
    EIdentifier(symbol:String);
    ENumericLiteral(value:Float);
}

class Parser
{
    var tokens:Array<Token> = [];

    public function new() {}

    function at():Token
        return tokens[0];

    function next():Token
        return tokens.shift();

    function notEof():Bool
    {
        return switch (at())
        {
            case TEof:
                false;
            default:
                true; 
        }
    }

    public function produceAST(tokens:Array<Token>):Array<Expr>
    {
        this.tokens = tokens;

        final ast:Array<Expr> = [];

        while (notEof())
            ast.push(parseStatement());

        return ast;
    }

    function parseStatement():Expr
    {
        return parseExpr();
    }

    function parseExpr():Expr
    {
        return parsePrimaryExpr();
    }

    function parsePrimaryExpr():Expr
    {
        final tk:Token = at();

        switch (tk)
        {
            case TIdent(val):
                next();

                return EIdentifier(val);
            case TNumber(val):
                next();

                return ENumericLiteral(val);
            default:
                throw 'Unexpected Token: ' + tk;
        }
    }
}