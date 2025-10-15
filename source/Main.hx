package;

import bodrio.*;

import haxe.Json;

using StringTools;

class Main
{
    static function main()
    {
        var parser:Parser = new Parser();

        Sys.println('\nBodrioScript v0.1');

        while (true)
        {
            Sys.print('\n> ');

            var input:String = Sys.stdin().readLine();

            if ((input ?? '').trim() == '')
                break;

            var tokens:Array<Tokenizer.Token> = Tokenizer.tokenize(input);

            prettyArrayPrint('Tokens', tokens);

            var ast:Array<Parser.Expr> = parser.produceAST(tokens);

            prettyArrayPrint('AST', ast);
        }
    }

    static function prettyArrayPrint<T>(title:String, array:Array<T>)
    {
        Sys.println('\n- ' + title + ':');

        for (obj in array)
            Sys.println('    ' + obj);
    }
}