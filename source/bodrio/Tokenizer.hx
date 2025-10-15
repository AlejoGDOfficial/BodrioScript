package bodrio;

using StringTools;

enum Token {
    TString(string:String);

    TVar;
    TNull;
    
    TNumeric(float:Float);
    TIdent(string:String);

    TAdditiveOp(op:String);
    TMultiplicativeOp(op:String);

    TEqual;
    TOpenParen;
    TCloseParen;

    TColon;
    TSemicolon;

    TEof;
}

class Tokenizer
{
    static final numericReg:EReg = ~/[\d\.]/;
    static final alphaReg:EReg = ~/[a-zA-Z_]/;
    static final alphaNumericReg:EReg = ~/[\w]/;
    static final spaceReg:EReg = ~/[\s]/;

    static final operators:Map<String, Token> = [
        '==' => null,
        '+=' => null,
        '-=' => null,
        ':' => TColon,
        ';' => TSemicolon,
        '(' => TOpenParen,
        ')' => TCloseParen,
        '=' => TEqual,
        '+' => TAdditiveOp('+'),
        '-' => TAdditiveOp('-'),
        '*' => TMultiplicativeOp('*'),
        '/' => TMultiplicativeOp('/'),
        '%' => TMultiplicativeOp('%')
    ];

    static final keywords:Map<String, Token> = [
        'var' => TVar,
        'null' => TNull
    ];

    public static function tokenize(sourceCode:String):Array<Token> {
        final source:Array<String> = sourceCode.split('');

        var tokens:Array<Token> = [];

        while (source.length > 0)
        {
            if (spaceReg.match(source[0]))
            {
                source.shift();

                continue;
            }

            var opRes:String = readAhead(source, operators);

            if (opRes != null)
            {
                tokens.push(operators[opRes]);
                
                continue;
            }

            if (alphaReg.match(source[0]))
            {
                var res:String = '';

                while (source.length > 0 && alphaNumericReg.match(source[0]))
                    res += source.shift();

                if (keywords.exists(res))
                    tokens.push(keywords[res]);
                else
                    tokens.push(TIdent(res));
            } else if (numericReg.match(source[0])) {
                var res:String = '';

                while (source.length > 0 && numericReg.match(source[0]))
                    res += source.shift();

                tokens.push(TNumeric(Std.parseFloat(res)));
            } else if (['"', '\''].contains(source[0])) {
                var quote:String = source.shift();

                var res:String = '';

                while (source.length > 0 && source[0] != quote)
                {
                    var minRes:String = source.shift();

                    if (source.length <= 0)
                        throw 'Expected ' + quote;

                    if (minRes == '\\')
                    {
                        var next:String = source.shift();

                        if (source.length <= 0)
                            throw 'Expected ' + quote;

                        res += switch (next)
                        {
                            case '"':
                                '"';
                            case '\'':
                                '\'';
                            case '\\':
                                '\\';
                            case 'n':
                                '\n';
                            case 't':
                                '\t';
                            default:
                                next;
                        }
                    } else if (minRes == quote) {
                        break;
                    } else {
                        res += minRes;
                    }
                }

                if (source.shift() != quote)
                    throw 'Expected ' + quote;

                tokens.push(TString(res));
            } else {
                throw 'Unexpected Token: ' + source[0];
            }
        }
        
        tokens.push(TEof);

        return tokens;
    }

    static function readAhead(source:Array<String>, map:Map<String, Token>):Null<String>
    {
        var max = 0;
        
        for (element in map.keys())
            if (element.length > max)
                max = element.length;

        for (len in 0...max + 1)
        {
            var substr = source.slice(0, len).join('');

            if (map.exists(substr))
            {
                for (i in 0...len)
                    source.shift();

                return substr;
            }
        }

        return null;
    }
}
