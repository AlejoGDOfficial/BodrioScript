package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    EProgram(body:Array<Expr>);

    EBinaryExpr(left:Expr, op:String, rigth:Expr);
    ENumeric(value:Float);

    EIdent(symbol:String);

    ENull;
}

class Parser
{
    var tokens:Array<Token> = [];

    public function new() {}

    function at():Token
        return tokens[0];

    function next():Token
        return tokens.shift();

    function expect(base:Token, err:String):Token
    {
        var tk:Token = next();

        if (tk == null || Type.enumIndex(tk) != Type.enumIndex(base))
            throw 'Expected token: ' + err;

        return tk;
    }

    function notEof():Bool
        return !at().match(TEof);

    public function produceAST(tokens:Array<Token>):Expr
    {
        this.tokens = tokens;

        final ast:Array<Expr> = [];

        while (notEof())
            ast.push(parseStatement());

        return EProgram(ast);
    }

    function parseStatement():Expr
    {
        return parseExpr();
    }

    function parseExpr():Expr
    {
        return parseAdditiveExpr();
    }
    
    function parseAdditiveExpr():Expr
    {
        var left:Expr = parseMultiplicativeExpr();

        while (true)
        {
            switch (at())
            {
                case TAdditiveOp(op):
                    next();
                    
                    final oper:String = op;

                    final right:Expr = parseMultiplicativeExpr();

                    left = EBinaryExpr(left, oper, right);
                default:
                    break;
            }
        }

        return left;
    }

    function parseMultiplicativeExpr():Expr
    {
        var left:Expr = parsePrimaryExpr();

        while (true)
        {
            switch (at())
            {
                case TMultiplicativeOp(op):
                    next();
                    
                    final oper:String = op;

                    final right:Expr = parsePrimaryExpr();

                    left = EBinaryExpr(left, oper, right);
                default:
                    break;
            }
        }

        return left;
    }

    function parsePrimaryExpr():Expr
    {
        final tk:Token = at();

        switch (tk)
        {
            case TIdent(val):
                next();

                return EIdent(val);
            case TNull:
                next();

                return ENull;
            case TNumeric(val):
                next();

                return ENumeric(val);
            case TOpenParen:
                next();

                final value:Expr = parseExpr();

                expect(TCloseParen, ')');

                return value;
            default:
                throw 'Unexpected Token: ' + tk;
        }
    }
}