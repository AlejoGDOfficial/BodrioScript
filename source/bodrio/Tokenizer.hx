package bodrio;

using StringTools;

enum Token
{
    TString(string:String);
    TNumber(float:Float);
    TIdent(string:String);
    TPlus;
    TMinus;
    TStar;
    TSlash;
    TEqual;
    TColon;
    TSemicolon;
}

class Tokenizer
{
    static final numReg:EReg = ~/[0-9]/;
    static final floatReg:EReg = ~/[\d\.]/;
    static final alphaReg:EReg = ~/[a-zA-Z_]/;
    static final alphaNumericReg:EReg = ~/[\w]/;
    static final spaceReg:EReg = ~/[\s]+/;

    public static function tokenize(base:String):Array<Token>
    {
        var tokens:Array<Token> = [];

        var i:Int = 0;

        while (i < base.length)
        {
            var cur:String = base.charAt(i);

            switch (cur)
            {
                case ' ', '\t', '\n':
                    i++;
                case '+':
                    tokens.push(TPlus);
                    
                    i++;
                case '-':
                    tokens.push(TMinus);
                    
                    i++;
                case '*':
                    tokens.push(TStar);
                    
                    i++;
                case '/':
                    tokens.push(TSlash);
                    
                    i++;
                case '=':
                    tokens.push(TEqual);
                    
                    i++;
                case ':':
                    tokens.push(TColon);

                    i++;
                case ';':
                    tokens.push(TSemicolon);

                    i++;
                case '"', '\'':
                    var quote = cur;

                    i++;

                    var str:String = '';

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
                                    str += next;
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
                default:
                    if (spaceReg.match(cur)) {
                        i++;
                    } else if (numReg.match(cur)) {
                        var num:String = '';

                        while (i < base.length && floatReg.match(base.charAt(i)))
                            num += base.charAt(i++);

                        tokens.push(TNumber(Std.parseFloat(num)));
                    } else if (alphaReg.match(cur)) {
                        var id = '';

                        while (i < base.length && alphaNumericReg.match(base.charAt(i)))
                            id += base.charAt(i++);

                        tokens.push(TIdent(id));
                    } else {
                        throw 'Unexpected token $cur';
                    }
            }
        }

        return tokens;
    }
}