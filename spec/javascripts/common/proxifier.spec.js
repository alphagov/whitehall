describe('GOVUK.proxifier', function () {
  describe('proxifyMethod', function () {
    it('should wrap the specified method in a proxy using the object as context', function () {
      const testObject = {
        testFunction: function () {
          return { calledContext: this }
        }
      }

      GOVUK.Proxifier.proxifyMethod(testObject, 'testFunction')

      expect(testObject.testFunction.call({}).calledContext).toBe(testObject)
    })
  })

  describe('proxifyMethods', function () {
    it('should call proxify on each indicated method', function () {
      const testObject = {
        wibbleMethod: function wibbleMethod() {
          return { calledContext: this }
        },
        wobbleMethod: function wobbleMethod() {
          return { calledContext: this }
        }
      }

      GOVUK.Proxifier.proxifyMethods(testObject, [
        'wibbleMethod',
        'wobbleMethod'
      ])

      expect(testObject.wibbleMethod.call({}).calledContext).toBe(testObject)
      expect(testObject.wibbleMethod.call({}).calledContext).toBe(testObject)
    })
  })

  describe('proxifyAllMethods', function () {
    it('should proxoify all attributes referencing functions not beginning with an uppercase letter (non-constructors only)', function () {
      const testObject = {
        nonMethod: "this isn't a function",
        methodFunction: function () {
          return { calledContext: this }
        },
        ConstructorFunction: function () {
          return { calledContext: this }
        }
      }

      GOVUK.Proxifier.proxifyAllMethods(testObject)

      expect(typeof testObject.nonMethod).not.toEqual('function')
      expect(testObject.methodFunction.call({}).calledContext).toBe(testObject)
      expect(testObject.ConstructorFunction.call({}).calledContext).not.toBe(
        testObject
      )
    })
  })
})
