package bodrio;

import bodrio.Parser;

class Interp
{
    var variables:Map<String, Dynamic> = [];

    public function new() {}

    public function run(exprs:Array<Expr>):Dynamic
    {
        var last:Dynamic = null;

        for (expr in exprs)
        {
            var result = eval(expr);

            if (expr.match(EReturn(_)))
                return result;

            last = result;
        }

        return last;
    }

    public function eval(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case ENumber(value):
                return value;
            case EString(value):
                return value;
            case EIdent(name):
                if (!variables.exists(name))
                    throw 'Unknown variable $name';

                variables.get(name);
            case EBinop(op, left, right):
                var l = eval(left);
                var r = eval(right);

                switch (op)
                {
                    case TPlus:
                        l + r;
                    case TMinus:
                        l - r;
                    case TStar:
                        l * r;
                    case TSlash:
                        l / r;
                    default:
                        throw 'Unsupported operator $op';
                }
            case EAssign(name, value):
                if (!variables.exists(name))
                    throw 'Unknown variable $name';

                var v = eval(value);

                variables.set(name, v);

                v;
            case EVarDecl(name, value):
                var v = eval(value);

                variables.set(name, v);

                v;
            case EReturn(value):
                return eval(value);
            default:
                throw 'Unsupported expressionl $expr';
        }
    }
}