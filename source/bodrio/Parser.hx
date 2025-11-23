package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    EProgram(body:Array<Expr>);

    EVarDecl(constant:Bool, id:String, ?value:Expr);
    EVarAssign(assigne:Expr, value:Expr);
    EMemberExpr(obj:Expr, prop:Expr, computed:Bool);
    EMemberAssign(left:Expr, right:Expr, value:Expr);
    ECallExpr(caller:Expr, args:Array<Expr>);
    EFuncDecl(name:String, params:Array<String>, body:Array<Expr>);

    ENumeric(value:Float);
    EString(value:String);

    EBinaryExpr(left:Expr, op:String, right:Expr);
    EProperty(key:String, ?value:Expr);
    EObject(props:Array<Expr>);

    EIdent(symbol:String);
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
        switch(at())
        {
            case TVar, TFinal:
                return parseVarDecl();
            case TFunc:
                return parseFuncDecl();
            default:
                return parseExpr();
        }
    }

    function parseFuncDecl():Expr
    {
        next();

        final name:String = switch(expect(TIdent(''), 'identifier'))
        {
            case TIdent(id):
                id;
            default:
                null;
        };

        final args:Array<Expr> = parseArgs();

        final params:Array<String> = [];

        for (arg in args)
        {
            switch (arg)
            {
                case EIdent(id):
                    params.push(id);
                default:
                    throw 'Expected identifier';
            }
        }

        expect(TOpenBrace, '{');

        final body:Array<Expr> = [];

        while (notEof() && !at().match(TCloseBrace))
        {
            body.push(parseStatement());
        }

        expect(TCloseBrace, '}');

        final func:Expr = EFuncDecl(name, params, body);

        return func;
    }

    function parseVarDecl():Expr
    {
        final isConstant:Bool = next().match(TFinal);
        final id:String = switch (expect(TIdent(''), 'identifier'))
        {
            case TIdent(name):
                name;
            default:
                null;
        }

        if (at().match(TSemicolon))
        {
            next();

            if (isConstant)
                throw 'Must assigne avalue to final expression';

            return EVarDecl(true, id, null);
        }

        expect(TEqual, '=');

        final declaration = EVarDecl(isConstant, id, parseExpr());

        expect(TSemicolon, ';');

        return declaration;
    }

    function parseExpr():Expr
    {
        return parseAssignExpr();
    }

    function parseAssignExpr():Expr
    {
        final left:Expr = parseObjectExpr();

        trace(left);

        if (at().match(TEqual))
        {
            next();

            return switch (left)
            {
                case EMemberExpr(l, r, c):
                    EMemberAssign(l, r, parseAssignExpr());
                default:
                    EVarAssign(left, parseAssignExpr());
            }
        }

        return left;
    }

    function parseObjectExpr():Expr
    {
        if (!at().match(TOpenBrace))
            return parseAdditiveExpr();

        next();

        final props:Array<Expr> = [];

        while (notEof() && !at().match(TCloseBrace))
        {
            final key:String = switch (expect(TIdent(''), 'ident'))
            {
                case TIdent(id):
                    id;
                default:
                    null;
            }

            if (at().match(TCloseBrace))
            {
                props.push(EProperty(key, null));

                continue;
            }

            expect(TColon, ':');

            final value:Expr = parseExpr();

            props.push(EProperty(key, value));

            if (!at().match(TCloseBrace))
            {
                expect(TComma, ',');
            }
        }

        expect(TCloseBrace, ']');

        return EObject(props);
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
        var left:Expr = parseCallMemberExpr();

        while (true)
        {
            switch (at())
            {
                case TMultiplicativeOp(op):
                    next();
                    
                    final oper:String = op;

                    final right:Expr = parseCallMemberExpr();

                    left = EBinaryExpr(left, oper, right);
                default:
                    break;
            }
        }

        return left;
    }

    function parseCallMemberExpr():Expr
    {
        final member:Expr = parseMemberExpr();

        if (at().match(TOpenParen))
            return parseCallExpr(member);

        return member;
    }

    function parseCallExpr(caller:Expr):Expr
    {
        var callExpr:Expr = ECallExpr(caller, parseArgs());

        if (at().match(TOpenParen))
            callExpr = parseCallExpr(callExpr);

        return callExpr;
    }

    function parseArgs():Array<Expr>
    {
        expect(TOpenParen, '(');

        final args:Array<Expr> = at().match(TCloseParen) ? [] : parseArgsList();

        expect(TCloseParen, ')');

        return args;
    }

    function parseArgsList():Array<Expr>
    {
        final args:Array<Expr> = [parseExpr()];

        while (notEof() && at().match(TComma) && next() != null)
        {
            args.push(parseAssignExpr());
        }

        return args;
    }

    function parseMemberExpr():Expr
    {
        var obj:Expr = parsePrimaryExpr();

        while (at().match(TDot) || at().match(TOpenBrace))
        {
            final op:Token = next();

            var prop:Expr;
            var computed:Bool;

            if (op.match(TDot))
            {
                computed = false;
                prop = parsePrimaryExpr();

                if (!prop.match(EIdent(_)))
                    throw 'Expected identifier';
            } else {
                computed = true;
                prop = parseExpr();

                expect(TCloseBrace, ']');
            }
            
            obj = EMemberExpr(obj, prop, computed);
        }

        return obj;
    }

    function parsePrimaryExpr():Expr
    {
        final tk:Token = at();

        switch (tk)
        {
            case TIdent(val):
                next();

                return EIdent(val);
            case TNumeric(val):
                next();

                return ENumeric(val);
            case TString(val):
                next();

                return EString(val);
            case TOpenParen:
                next();

                final value:Expr = parseExpr();

                expect(TCloseParen, ')');

                return value;
            default:
        }
        
        throw 'Unexpected Token Type: ' + tk;
    }
}