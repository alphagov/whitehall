module("Proxifier test ", {
  setup: function(){
  }
});

test('proxifyMethod should wrap the specified method in a proxy using the object as context', function() {
  var testObject = {
    testFunction: function testFunction() {
      return {
        calledContext: this
      }
    }
  }

  GOVUK.Proxifier.proxifyMethod(testObject, 'testFunction');

  ok(testObject.testFunction.call({}).calledContext == testObject);
});

test('proxifyMethods should call proxify each indicated method', function() {
  var testObject = {
    wibbleMethod: function wibbleMethod() { return { calledContext: this }; },
    wobbleMethod: function wobbleMethod() { return { calledContext: this }; }
  };

  GOVUK.Proxifier.proxifyMethods(testObject, ['wibbleMethod', 'wobbleMethod']);

  ok(testObject.wibbleMethod.call({}).calledContext == testObject);
  ok(testObject.wobbleMethod.call({}).calledContext == testObject);
});

test('proxifyAllMethods should proxoify all attributes referencing functions not beginning with an uppercase letter (non-constructors only)', function() {
  var testObject = {
    nonMethod: "this isn't a function",
    methodFunction: function() { return { calledContext: this }; },
    ConstructorFunction: function() { return { calledContext: this }; }
  };

  GOVUK.Proxifier.proxifyAllMethods(testObject);

  ok(typeof testObject.nonMethod != 'function');
  ok(testObject.methodFunction.call({}).calledContext == testObject);
  ok(testObject.ConstructorFunction.call({}).calledContext != testObject);
});
