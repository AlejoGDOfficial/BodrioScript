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
                0;
        };
    }

    static function evalBinaryExpr(binop:Expr, env:Environment):Dynamic
    {
        switch (binop)
        {
            case EBinaryExpr(left, op, right):
                final lhs:Dynamic = eval(left, env);
                final rhs:Dynamic = eval(right, env);

                if ((lhs is Float || lhs is Int) && (rhs is Float || rhs is Int))
                    return evalNumericBinaryExpr(lhs, op, rhs);
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
        final obj:Map<String, Dynamic> = new Map();

        switch (eObj)
        {
            case EObject(props):
                for (prop in props)
                {
                    switch (prop)
                    {
                        case EProperty(key, val):
                            obj.set(key, eval(val, env));
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

                if (!Reflect.isFunction(func))
                    throw 'Cannot call a value that\'s not a function';

                return Reflect.callMethod(null, func, vars);
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
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}