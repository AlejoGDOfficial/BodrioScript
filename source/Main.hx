package;

import sys.io.File;

import bodrio.*;

class Main
{
    static function main()
    {
        var content = File.getContent('test.hx');

        var tokens = Tokenizer.tokenize(content);

        var ast = new Parser(tokens).parse();

        var interp = new Interp();

        trace(interp.run(ast));
    }
}