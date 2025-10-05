package bodrio;

using StringTools;

import bodrio.Tokenizer;

enum Expr
{
    ENumber(value:Float);
    EString(value:String);
    EIdent(name:String);
    EBinop(op:Token, left:Expr, right:Expr);
    EAssign(name:String, value:Expr);
    EVarDecl(name:String, typeName:String, value:Expr);
}

class Parser
{
    var tokens:Array<Token>;

    var pos:Int = 0;

    public function new(tokens:Array<Token>)
    {
        this.tokens = tokens;
    }

    inline function peek():Token
        return pos < tokens.length ? tokens[pos] : null;

    inline function next():Token
        return tokens[pos++];

    public function parse():Array<Expr>
    {
        var result:Array<Expr> = [];

        while (peek() != null)
            result.push(parseStatement());

        return result;
    }

    function parseVarDecl():Expr
    {
        next();

        var name = switch(next())
        {
            case TIdent(n):
                n;
            default:
                throw "Expected variable name";
        }

        var typeName = "";

        if (peek() == TColon)
        {
            next();

            typeName = switch(next())
            {
                case TIdent(n):
                    n;
                default:
                    throw "Expected type name";
            }
        }

        if (peek() != TEqual)
            throw "Expected '='";

        next();

        var value = parseExpression();

        if (peek() == TSemicolon)
            next();

        return EVarDecl(name, typeName, value);
    }
    
    function parseStatement():Expr
    {
        var expr:Expr;
        
        switch(peek())
        {
            case TIdent("var"):
                expr = parseVarDecl();
            default:
                expr = parseExpression();
        }

        if (peek() == TSemicolon)
            next();

        return expr;
    }

    function parseExpression():Expr
    {
        var left = parseTerm();

        while (true)
        {
            var t = peek();

            if (t == TPlus || t == TMinus || t == TStar || t == TSlash)
            {
                var op = next();

                var right = parseTerm();

                left = EBinop(op, left, right);
            } else {
                break;
            }
        }

        return left;
    }


    function parseTerm():Expr
    {
        return switch(peek())
        {
            case TNumber(value):
                next();

                ENumber(value);
            case TString(value):
                next();

                EString(value);
            case TIdent(name):
                next();

                if (peek() == TEqual)
                {
                    next();

                    EAssign(name, parseExpression());
                } else {
                    EIdent(name);
                }
            default:
                throw 'Unexpected token ${peek()}';
        }
    }
}