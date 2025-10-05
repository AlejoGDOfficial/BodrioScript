package;

import sys.io.File;

import bodrio.*;

class Test
{
    public static function oso()
    {
        trace('Si te mueve');
    }
}

class Main
{
    static function main()
    {
        var content = File.getContent('test.hx');

        var tokens = Tokenizer.tokenize(content);

        trace(tokens);
    }
}