package;

import bodrio.Tokenizer;
import bodrio.Tokenizer.Token;

import bodrio.Parser;
import bodrio.Parser.Expr;

import bodrio.Interp;

import bodrio.Environment;

import haxe.Json;

import sys.io.File;

using StringTools;

class Main
{
    static function main()
    {
        Sys.println('\nBodrioScript v0.1');

        final parser:Parser = new Parser();

        final env:Environment = new Environment();

        env.declareVar('x', 100);

        //fileTest('test', parser, env);

        inputTest(parser, env);
    }

    static function inputTest(parser:Parser, env:Environment)
    {
        while (true)
        {
            Sys.print('\n> ');

            var input:String = Sys.stdin().readLine();

            if ((input ?? '').trim() == '')
                break;

            execute(input, parser, env);
        }
    }

    static function fileTest(path:String, parser:Parser, env:Environment)
    {
        execute(File.getContent(path + '.hx'), parser, env);
    }

    static function execute(code:String, parser:Parser, env:Environment)
    {
        try
        {
            var tokens:Array<Token> = Tokenizer.tokenize(code);

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

    static function prettyArrayPrint<T>(title:String, array:Array<T>)
    {
        Sys.println('\n- ' + title + ':');

        for (obj in array)
            Sys.println('    ' + obj);
    }
}