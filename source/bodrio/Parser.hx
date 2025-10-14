package bodrio;

import bodrio.Tokenizer;

enum Expr
{
    ENumber(value:Float);
    EString(value:String);
    EIdent(name:String);
    EBinop(op:Token, left:Expr, right:Expr);
    EAssign(name:String, value:Expr);
    EVarDecl(name:String, value:Expr);
    EReturn(value:Expr);
}

class Parser
{
    var tokens:Array<Token> = [];

    public function new()
    {
        
    }
}