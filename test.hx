var obj = {
    foo: {
    }
};

obj = {
    foo: {
        bar: 0
    }
}

Reflect.setField(obj.foo, 'bar', 1)

trace(obj)

obj.foo.bar = 10

obj.foo.bar