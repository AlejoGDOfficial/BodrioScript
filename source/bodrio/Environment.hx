package bodrio;

import bodrio.Parser;

import bodrio.Interp;

class Environment
{
    public var parent:Null<Environment>;

    public var variables:Map<String, Dynamic> = new Map();
    public var constants:Map<String, Dynamic> = new Map();

    public function new(?par:Environment)
    {
        parent = par;

        final imports:Array<Class<Dynamic>> = [
            Math,
            Reflect
        ];

        for (cls in imports)
            declareVar(Type.getClassName(cls), cls, true);

        final globalVariables:Map<String, Dynamic> = [
            'true' => true,
            'false' => false,
            'null' => null
        ];

        for (variable in globalVariables.keys())
            declareVar(variable, globalVariables.get(variable), true);

        final globalFunctions:Map<String, Dynamic> = [
            'trace' => Reflect.makeVarArgs(
                function (args:Array<Dynamic>)
                {
                    Sys.println(args.join(','));

                    return null;
                }
            )
        ];

        for (func in globalFunctions.keys())
            declareVar(func, globalFunctions.get(func), true);
    }

    public function declareVar(name:String, val:Dynamic, isConstant:Bool):Dynamic
    {
        if (variables.exists(name))
            throw 'Duplicate class field declaration: ' + name;

        variables.set(name, val);

        if (isConstant)
            constants.set(name, val);

        return val;
    }

    public function assignVar(name:String, val:Dynamic):Dynamic
    {
        final env:Environment = this.resolve(name);

        if (env.constants.exists(name))
            throw 'Cannot reasign a final variable';

        env.variables.set(name, val);

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