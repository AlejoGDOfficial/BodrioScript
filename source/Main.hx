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

            Sys.println(parser.produceAST(Tokenizer.tokenize(input)));
        }
    }
}