package bodrio;

import bodrio.Parser;

enum Value
{
    VNull;
    VNumeric(val:Float);
}

class Interp
{
    static function evalProgram(program:Expr):Value
    {
        var lastEval:Value = VNull;

        switch (program)
        {
            case EProgram(body):
                for (statement in body)
                    lastEval = eval(statement);
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

    static function evalBinaryExpr(binop:Expr):Value
    {
        switch (binop)
        {
            case EBinaryExpr(left, op, right):
                final lhs:Value = eval(left);
                final rhs:Value = eval(right);

                if (lhs.match(VNumeric(0)) && rhs.match(VNumeric(0)))
                    return evalNumericBinaryExpr(lhs, op, rhs);
            default:
        }

        return VNull;
    }

    public static function eval(expr:Expr):Value
    {
        switch (expr)
        {
            case ENumeric(val):
                return VNumeric(val);
            case EBinaryExpr(left, oper, right):
                return evalBinaryExpr(expr);
            case ENull:
                return VNull;
            case EProgram(body):
                return evalProgram(expr);
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}