package bodrio;

using StringTools;

enum Token {
    TString(string:String);
    
    TNumber(float:Float);
    TIdent(string:String);

    TBinOp(sym:String);
    TEqual;
    TOpenParen;
    TCloseParen;

    TColon;
    TSemicolon;

    TEof;
}

class Tokenizer
{
    static final numReg:EReg = ~/[0-9]/;
    static final numericReg:EReg = ~/[\d\.]/;
    static final alphaReg:EReg = ~/[a-zA-Z_]/;
    static final alphaNumericReg:EReg = ~/[\w]/;
    static final spaceReg:EReg = ~/[\s]/;

    static final operators:Map<String, Token> = [
        ':' => TColon,
        ';' => TSemicolon,
        '(' => TOpenParen,
        ')' => TCloseParen,
        '=' => TEqual
    ];

    static final binOps:Array<String> = [
        '==',
        '+=',
        '-=',
        '+',
        '-',
        '*',
        '/'
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

            var binRes:String = readAhead(source, binOps);

            if (binRes != null)
            {
                tokens.push(TBinOp(binRes));

                continue;
            }

            var opRes:String = readAhead(source, [for (k in operators.keys()) k]);

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

                tokens.push(TIdent(res));
            } else if (numericReg.match(source[0])) {
                var res:String = '';

                while (source.length > 0 && numericReg.match(source[0]))
                    res += source.shift();

                tokens.push(TNumber(Std.parseFloat(res)));
            } else if (['"', '\''].contains(source[0])) {
                var quote:String = source.shift();

                var res:String = '';

                while (source.length > 0)
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

                source.shift();

                tokens.push(TString(res));
            } else {
                trace(tokens);

                throw 'Unexpected Token: ' + source[0];
            }
        }
        
        tokens.push(TEof);

        return tokens;
    }

    static function readAhead(source:Array<String>, map:Array<String>):Null<String>
    {
        var max = 0;
        
        for (element in map)
            if (element.length > max)
                max = element.length;

        for (len in 0...max + 1)
        {
            var substr = source.slice(0, len).join('');

            if (map.contains(substr))
            {
                for (i in 0...len)
                    source.shift();

                return substr;
            }
        }

        return null;
    }
}
