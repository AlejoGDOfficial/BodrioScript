package;

import sys.io.File;

import bodrio.*;

class Main
{
    static function main()
    {
        var code:String = File.getContent('test.hx');

        var tokens:Array<Tokenizer.Token> = Tokenizer.tokenize(code);

        var ast:Parser.Expr = new Parser(tokens).produceAST();

        trace(ast);
    }
}