package bodrio;

using StringTools;

enum Token {
    TString(string:String);
    TNumber(float:Float);
    TIdent(string:String);
    TPlus;
    TMinus;
    TStar;
    TSlash;
    TEqual;
    TEqualEqual;
    TPlusEqual;
    TMinusEqual;
    TColon;
    TSemicolon;
    TLeftParen;
    TRightParen;
}

class Tokenizer
{
    static final numReg:EReg = ~/[0-9]/;
    static final numericReg:EReg = ~/[\d\.]/;
    static final alphaReg:EReg = ~/[a-zA-Z_]/;
    static final alphaNumericReg:EReg = ~/[\w]/;
    static final spaceReg:EReg = ~/[\s]/;

    static final operators:Map<String, Token> = [
        '==' => TEqualEqual,
        '+=' => TPlusEqual,
        '-=' => TMinusEqual,
        '=' => TEqual,
        '+' => TPlus,
        '-' => TMinus,
        '*' => TStar,
        '/' => TSlash,
        ':' => TColon,
        ';' => TSemicolon,
        '(' => TLeftParen,
        ')' => TRightParen
    ];

    public static function tokenize(base:String):Array<Token> {
        var tokens:Array<Token> = [];

        var i:Int = 0;

        var maxOp = 0;

        for (str in operators.keys())
            if (str.length > maxOp)
                maxOp = str.length;

        while (i < base.length)
        {
            var opMatch:Bool = false;

            for (baseLength in 0...maxOp)
            {
                var length:Int = maxOp - baseLength;

                var result:Token = operators.get(base.substr(i, length));

                if (result != null)
                {
                    tokens.push(result);

                    i += length;

                    opMatch = true;

                    break;
                }
            }
            
            if (opMatch)
                continue;

            var cur:String = base.charAt(i);

            if (spaceReg.match(cur))
            {
                i++;

                continue;
            }

            if (alphaReg.match(cur))
            {
                var str:String = '';

                while (i < base.length && alphaNumericReg.match(base.charAt(i)))
                    str += base.charAt(i++);

                tokens.push(TIdent(str));

                continue;
            }

            if (numReg.match(cur))
            {
                var str:String = '';

                while (i < base.length && numericReg.match(base.charAt(i)))
                    str += base.charAt(i++);

                tokens.push(TNumber(Std.parseFloat(str)));

                continue;
            }

            if (['\'', '"'].contains(cur))
            {
                var quote = cur;

                var str:String = '';

                i++;

                while (i < base.length)
                {
                    var char:String = base.charAt(i);

                    if (char == '\\')
                    {
                        i++;

                        if (i >= base.length)
                            throw 'Unfinished escape';

                        var next:String = base.charAt(i);

                        str += switch (next)
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
                    } else if (char == quote) {
                        i++;

                        break;
                    } else {
                        str += char;
                    }

                    i++;
                }

                tokens.push(TString(str));

                continue;
            }

            throw 'Unexpected token ${base.charAt(i)}';
        }

        return tokens;
    }
}
