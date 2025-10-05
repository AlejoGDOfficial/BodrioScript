package;

import sys.io.File;

import bodrio.Tokenizer;

class Main
{
    static function main()
    {
        var content = File.getContent('test.hx');

        var tokens = Tokenizer.tokenize(content);

        trace(tokens);
    }
}