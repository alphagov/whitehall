class NoFootnotesInGovspeakValidatorTest < ActiveSupport::TestCase
  test "it invalidates records where the attribute specified by :attribute has a govspeak footnote tag ([^something])" do
    subject = NoFootnotesInGovspeakValidator.new(attribute: :body)

    test_model = Edition.new(body: 'some body text without a footnote')

    subject.validate(test_model)

    assert_equal 0, test_model.errors.count

    test_model.body = 'some body text with footnote[^1]'

    subject.validate(test_model)

    assert_equal 1, test_model.errors.count
    assert_equal "cannot include footnotes on this type of document (Body includes '[^1]')", test_model.errors.messages[:body].join
  end

  test "it can validate multiple attributes" do
    subject = NoFootnotesInGovspeakValidator.new(attributes: [:description, :about_us])
    test_model = Organisation.new(description: 'footnotes[^1]', about_us: 'footnotes[^1]')

    subject.validate(test_model)

    assert_equal 2, test_model.errors.count
  end
end
