describe('GOVUK.init', function () {
  it("it initialises a constructor with the params and stores it on GOVUK.instances.<constructor's name>", function () {
    function TestConstructor (params) {
      this.params = params
    }
    GOVUK.init(TestConstructor, { foo: 'bar' })

    expect(GOVUK.instances.TestConstructor[0].params.foo).toEqual('bar')
  })

  it('calls init on a singleton and returns that singleton', function () {
    var testSingleton = {
      init: function init (params) {
        this.foo = params.foo
      }
    }

    expect(GOVUK.init(testSingleton, { foo: 'bar' })).toBe(testSingleton)
  })
})
