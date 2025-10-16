package bodrio;

import bodrio.Parser;

import bodrio.Interp;

class Environment
{
    public var parent:Null<Environment>;

    public var variables:Map<String, Dynamic>;

    public function new(?par:Environment)
    {
        parent = par;

        variables = new Map();
    }

    public function declareVar(name:String, val:Dynamic):Dynamic
    {
        if (variables.exists(name))
            throw 'Duplicate class field declaration: ' + name;

        variables.set(name, val);

        return val;
    }

    public function assignVar(name:String, val:Dynamic):Dynamic
    {
        this.resolve(name).variables.set(name, val);

        return val;
    }

    public function lookupVar(name:String):Dynamic
        return this.resolve(name).variables.get(name);

    public function resolve(name:String):Environment
    {
        if (variables.exists(name))
            return this;

        if (parent == null)
            throw 'Unknown variable: ' + name;

        return parent; 
    }
}