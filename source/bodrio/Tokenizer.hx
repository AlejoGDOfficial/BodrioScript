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
    static final floatReg:EReg = ~/[\d\.]/;
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
            for (baseLength in 0...maxOp)
            {
                var result:Token = operators.get(base.substr(i, maxOp - baseLength));

                if (result != null)
                {
                    tokens.push(result);

                    i++;

                    continue;
                }
            }

            i++;
        }

        return tokens;
    }
}
