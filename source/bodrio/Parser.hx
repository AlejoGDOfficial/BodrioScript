package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    Program(body:Array<Expr>);
    BinaryExpr(left:Expr, rigth:Expr, op:String);
    Identifier(symbol:String);
    NumericLiteral(value:Float);
}

class Parser
{
    var tokens:Array<Token> = [];

    public function new(tokens:Array<Token>)
    {
        this.tokens = tokens;
    }

    function at():Token
        return tokens[0];

    function eat():Token
        return tokens.shift();

    function notEof():Bool
    {
        return switch (at())
        {
            case TEof:
                true;
            default:
                false; 
        }
    }

    public function produceAST():Expr
    {
        final programBody:Array<Expr> = [];

        while (notEof())
        {
            programBody.push(parseStatement());
        }

        return Program(programBody);
    }

    function parseStatement():Expr
    {
        return parseExpr();
    }

    function parseExpr():Expr
    {
        return null;
    }

    function parsePrimaryExpr():Expr
    {
        final tk:Token = at();

        switch (tk)
        {
            case TIdent(val):
                return Identifier(val);
            default:
                return null;
        }

        return null;
    }
}