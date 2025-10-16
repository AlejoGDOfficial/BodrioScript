package bodrio;

import bodrio.Parser;

import bodrio.Environment;

enum Value
{
    VNull;
    VNumeric(val:Float);
}

class Interp
{
    static function evalProgram(program:Expr, env:Environment):Value
    {
        var lastEval:Value = VNull;

        switch (program)
        {
            case EProgram(body):
                for (statement in body)
                    lastEval = eval(statement, env);
            default:
        }

        return lastEval;
    }

    static function evalNumericBinaryExpr(lhs:Value, op:String, rhs:Value):Value
    {
        var left:Float = switch (lhs)
        {
            case VNumeric(val):
                val;
            default:
                0;
        }

        var right:Float = switch (rhs)
        {
            case VNumeric(val):
                val;
            default:
                0;
        }
        
        return VNumeric(
            switch (op)
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
            }
        );
    }

    static function evalBinaryExpr(binop:Expr, env:Environment):Value
    {
        switch (binop)
        {
            case EBinaryExpr(left, op, right):
                final lhs:Value = eval(left, env);
                final rhs:Value = eval(right, env);

                if (lhs.match(VNumeric(_)) && rhs.match(VNumeric(_)))
                    return evalNumericBinaryExpr(lhs, op, rhs);
            default:
        }

        return VNull;
    }

    static function evalIdentifier(iden:Expr, env:Environment):Value
    {
        return switch (iden)
        {
            case EIdent(id):
                env.lookupVar(id);
            default:
                VNull;
        }
    }

    public static function eval(expr:Expr, env:Environment):Value
    {
        switch (expr)
        {
            case ENumeric(val):
                return VNumeric(val);
            case EBinaryExpr(left, oper, right):
                return evalBinaryExpr(expr, env);
            case ENull:
                return VNull;
            case EProgram(body):
                return evalProgram(expr, env);
            case EIdent(id):
                return evalIdentifier(expr, env);
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}