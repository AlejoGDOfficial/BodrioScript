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

                if (lhs is Float && rhs is Float)
                    return evalNumericBinaryExpr(lhs, op, rhs);
            default:
        }

        return null;
    }

    static function evalIdentifier(iden:Expr, env:Environment):Dynamic
    {
        return switch (iden)
        {
            case EIdent(id):
                env.lookupVar(id);
            default:
                null;
        }
    }

    public static function eval(expr:Expr, env:Environment):Dynamic
    {
        switch (expr)
        {
            case ENumeric(val):
                return val;
            case EBinaryExpr(left, oper, right):
                return evalBinaryExpr(expr, env);
            case ENull:
                return null;
            case EProgram(body):
                return evalProgram(expr, env);
            case EIdent(id):
                return evalIdentifier(expr, env);
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}