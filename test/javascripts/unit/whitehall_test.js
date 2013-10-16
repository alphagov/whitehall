
test("Whitehall.init new's the constructor with the params and leaves the returned instance in Whitehall.instances.<constructor's name>", function() {
  function TestConstructor(params) {
    this.params = params;
  }
  Whitehall.init(TestConstructor, {foo: 'bar'});
  ok(Whitehall.instances["TestConstructor"][0].params.foo == 'bar', "was in the right place with it's params.")
});
