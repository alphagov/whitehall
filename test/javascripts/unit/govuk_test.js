
test("GOVUK.init new's the constructor with the params and leaves the returned instance in GOVUK.instances.<constructor's name>", function() {
  function TestConstructor(params) {
    this.params = params;
  }
  GOVUK.init(TestConstructor, {foo: 'bar'});
  ok(GOVUK.instances["TestConstructor"][0].params.foo == 'bar', "was in the right place with it's params.");
});

test("GOVUK.init calls init on a singleton and returns that singleton", function() {
  var testSingleton = {
    init: function init(params) {
      this.foo = params.foo;
    }
  };
  ok(GOVUK.init(testSingleton, {foo: 'bar'}).foo == 'bar', "initialised the singleton with the params");
});
