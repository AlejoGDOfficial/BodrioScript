package bodrio;

import bodrio.Parser;

import bodrio.Environment;

class Interp
{
    static function evalProgram(program:Expr, env:Environment):Dynamic
    {
        var lastEval:Dynamic = null;

        switch (program)
        {
            case EProgram(body):
                for (statement in body)
                    lastEval = eval(statement, env);
            default:
        }

        return lastEval;
    }

    static function evalNumericBinaryExpr(left:Float, op:String, right:Float):Float
    {
        return switch (op)
        {
            case '+':
                left + right;
            case '-':
                left - right;
            case '*':
                left * right;
            case '/':
                left / right;
            case '%':
                left % right;
            default:
                throw 'Invalid Operation ' + op;
        };
    }

    static function evalStringBinaryExpr(left:Dynamic, op:String, right:Dynamic):String
    {
        return switch (op)
        {
            case '+':
                Std.string(left) + Std.string(right);
            default:
                throw 'Invalid Operation ' + op;
        };
    }

    static function evalBinaryExpr(binop:Expr, env:Environment):Dynamic
    {
        switch (binop)
        {
            case EBinaryExpr(left, op, right):
                final lhs:Dynamic = eval(left, env);
                final rhs:Dynamic = eval(right, env);

                function is(cls:Dynamic)
                    return Std.isOfType(lhs, cls) && Std.isOfType(rhs, cls);
                
                if (is(Int) && is(Float))
                    return evalNumericBinaryExpr(lhs, op, rhs);

                return evalStringBinaryExpr(lhs, op, rhs);
            default:
        }

        return null;
    }

    static function evalIdentifier(iden:Expr, env:Environment):Dynamic
    {
        switch (iden)
        {
            case EIdent(id):
                return env.lookupVar(id);
            default:
                return null;
        }
    }

    static function evalVarDecl(eVar:Expr, env:Environment):Dynamic
    {
        switch(eVar)
        {
            case EVarDecl(isConstant, id, val):
                return env.declareVar(id, val == null ? null : eval(val, env), isConstant);
            default:
                return null;
        }
    }

    static function evalVarAssign(eVar:Expr, env:Environment):Dynamic
    {
        switch (eVar)
        {
            case EVarAssign(assigne, value):
                switch (assigne)
                {
                    case EIdent(id):
                        return env.assignVar(id, eval(value, env));
                    default:
                        throw 'Invalid assigne: ' + assigne;
                }
            default:
                return null;
        }
    }

    static function evalObjectExpr(eObj:Expr, env:Environment):Map<String, Dynamic>
    {
        final obj:Dynamic = {};

        switch (eObj)
        {
            case EObject(props):
                for (prop in props)
                {
                    switch (prop)
                    {
                        case EProperty(key, val):
                            Reflect.setField(obj, key, eval(val, env));
                        default:
                            return null;
                    }
                }
            default:
                return null;
        }

        return obj;
    }

    static function evalCallExpr(expr:Expr, env:Environment):Map<String, Dynamic>
    {
        switch (expr)
        {
            case ECallExpr(caller, args):
                final vars:Array<Dynamic> = [
                    for (arg in args)
                        eval(arg, env)
                ];

                final func:Dynamic = eval(caller, env);

                if (func is Expr)
                {
                    switch (func)
                    {
                        case EFuncDecl(name, params, body):
                            final scope:Environment = new Environment(env);

                            for (index => param in params)
                                scope.declareVar(param, vars[index], false);

                            var result:Dynamic = null;

                            for (stat in body)
                                result = eval(stat, scope);

                            return result;
                        default:
                    }
                } else if (Reflect.isFunction(func)) {
                    return Reflect.callMethod(null, func, vars);
                }

                throw 'Cannot call a value that\'s not a function';
            default:
        }

        return null;
    }

    static function evalMemberExpr(expr:Expr, env:Environment):Dynamic
    {
        switch (expr)
        {
            case EMemberExpr(left, right, computed):
                final lhs:Dynamic = eval(left, env);

                switch (right)
                {
                    case EIdent(id):
                        return Reflect.getProperty(lhs, id);
                    default:
                }
            default:
        }

        return null;
    }

    public static function eval(expr:Expr, env:Environment):Dynamic
    {
        switch (expr)
        {
            case ENumeric(val):
                return val;
            case EString(val):
                return val;
            case EBinaryExpr(left, oper, right):
                return evalBinaryExpr(expr, env);
            case EProgram(body):
                return evalProgram(expr, env);
            case EIdent(id):
                return evalIdentifier(expr, env);
            case EVarDecl(isConstant, id, val):
                return evalVarDecl(expr, env);
            case EVarAssign(asiggne, value):
                return evalVarAssign(expr, env);
            case EObject(props):
                return evalObjectExpr(expr, env);
            case ECallExpr(caller, args):
                return evalCallExpr(expr, env);
            case EFuncDecl(name, params, body):
                return env.declareVar(name, expr, true);
            case EMemberExpr(left, right, computed):
                return evalMemberExpr(expr, env);
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}