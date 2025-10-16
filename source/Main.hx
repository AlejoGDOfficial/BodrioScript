package;

import bodrio.Tokenizer;
import bodrio.Tokenizer.Token;

import bodrio.Parser;
import bodrio.Parser.Expr;

import bodrio.Interp;

import bodrio.Environment;

import haxe.Json;

using StringTools;

class Main
{
    static function main()
    {
        final parser:Parser = new Parser();

        final env:Environment = new Environment();

        env.declareVar('oso', 100);

        Sys.println('\nBodrioScript v0.1');

        while (true)
        {
            Sys.print('\n> ');

            var input:String = Sys.stdin().readLine();

            if ((input ?? '').trim() == '')
                break;

            try
            {
                var tokens:Array<Token> = Tokenizer.tokenize(input);

                prettyArrayPrint('Tokens', tokens);            

                var ast:Expr = parser.produceAST(tokens);

                switch (ast)
                {
                    case Expr.EProgram(body):
                        prettyArrayPrint('AST', body);
                    default:
                }

                final result:Dynamic = Interp.eval(ast, env);

                prettyArrayPrint('Result', [result]);
            } catch(e) {
                prettyArrayPrint('ERROR', [e.message]);
            }
        }
    }

    static function prettyArrayPrint<T>(title:String, array:Array<T>)
    {
        Sys.println('\n- ' + title + ':');

        for (obj in array)
            Sys.println('    ' + obj);
    }
}