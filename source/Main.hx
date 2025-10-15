package;

import bodrio.Tokenizer;
import bodrio.Tokenizer.Token;

import bodrio.Parser;
import bodrio.Parser.Expr;

import bodrio.Interp;

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

            var tokens:Array<Token> = Tokenizer.tokenize(input);

            var ast:Expr = parser.produceAST(tokens);

            final result:Dynamic = Interp.eval(ast);

            trace(result);
        }
    }
}