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
            default:
                throw 'Unexpected expression: ' + expr;
        }
    }
}