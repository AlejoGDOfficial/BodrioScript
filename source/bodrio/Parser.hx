package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    ENumber(value:Float);
    EString(value:String);
    EIdent(name:String);
    EBinop(op:Token, left:Expr, right:Expr);
    EAssign(name:String, value:Expr);
    EVarDecl(name:String, value:Expr);
    EReturn(value:Expr);
}

class Parser
{
    var tokens:Array<Token>;

    var pos:Int = 0;

    function current():Token
        return tokens[pos];

    function advance():Token
        return tokens[pos++];

    function next():Token
        return tokens[++pos];

    function back():Token
        return tokens[pos - 1];

    public function new(tokens:Array<Token>)
    {
        this.tokens = tokens;
    }

    public function parse()
    {
        var result:Array<Expr> = [];

        while (pos < tokens.length)
        {
            result.push(parseStatement());

            if (back() != TSemicolon)
                throw 'Expected ;';
        }

        return result;
    }
    
    function isStatementStart(tok:Token):Bool
    {
        if (tok == null)
            return true;

        return switch (tok)
        {
            case TIdent("var") | TIdent("return"):
                true;
            default:
                false;
        }
    }


    function parseStatement():Expr
    {
        var token:Token = current();

        switch (token)
        {
            case TIdent('var'):
                return parseVarDecl();
            default:
                var expr:Expr = parseExpr();

                if (current() == TSemicolon)
                    advance();

                return expr;
        }
    }

    function parseVarDecl():Expr
    {
        advance();

        var nameTok:Token = advance();

        var name:String = switch (nameTok)
        {
            case TIdent(v):
                v;
            default:
                throw 'Expected variable name';
        }

        if (current() == TColon)
        {
            advance();

            switch (current())
            {
                case TIdent(typeName):
                    advance();
                default:
                    throw 'Expected type name';
            }
        }

        var value:Expr = null;

        if (current() == TEqual)
        {
            advance();

            value = parseExpr();
        }

        if (current() == TSemicolon)
            advance();
        else
            throw 'Expected ;';

        return EVarDecl(name, value);
    }

    function parseExpr():Expr
    {
        var token:Token = current();

        switch (token)
        {
            case TIdent('return'):
                advance();

                return EReturn(parseExpr());
            default:
                return parseBinop();
        }
    }

    function parseBinop(minPrec:Int = 0):Expr
    {
        var left = parseFactor();

        while (pos < tokens.length)
        {
            var op = current();

            var prec = switch (op)
            {
                case TPlus, TMinus:
                    1;
                case TStar, TSlash:
                    2;
                default:
                    -1;
            };

            if (prec < minPrec || prec == -1)
                break;

            advance();

            var right = parseBinop(prec + 1);

            left = EBinop(op, left, right);
        }

        return left;
    }

    function parseFactor()
    {
        var token:Token = advance();

        switch (token)
        {
            case TNumber(value):
                return ENumber(value);
            case TString(value):
                return EString(value);
            case TIdent(value):
                return EIdent(value);
            case TPlus:
                return parseFactor();
            case TMinus:
                return EBinop(TMinus, ENumber(0), parseFactor());
            case TLeftParen:
                var expr:Expr = parseExpr();

                if (current() != TRightParen)
                    throw 'Expected )';

                advance();

                return expr;
            default:
                throw 'Unexpected token $token';
        }
    }
}