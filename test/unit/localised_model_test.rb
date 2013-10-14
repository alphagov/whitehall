require "test_helper"

class LocalisedModelTest < ActiveSupport::TestCase
  class Model
    def locale
      "Locale is '#{I18n.locale}'"
    end
  end

  setup do
    @model = Model.new
    @localised_model = LocalisedModel.new(@model, :es)
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  test "provides access to the translation locale" do
    assert_equal :es, @localised_model.fixed_locale
  end

  test "sets locale before calling decorated method" do
    assert_equal "Locale is 'es'", @localised_model.locale
  end

  test "returns locale to original value after decorated method call" do
    I18n.locale = :original
    @localised_model.locale
    assert_equal :original, I18n.locale
  end

  test "returns locale to original value even if decorated call fails" do
    I18n.locale = :original
    @model.stubs(:locale).raises("any error")
    assert_raise(RuntimeError) { @localised_model.locale }
    assert_equal :original, I18n.locale
  end

  test "has same identity as decorated instance" do
    assert_equal Model, @localised_model.class
  end

  test "ActiveRecord errors are generated in English" do
    model = NewsArticle.new
    localised_model = LocalisedModel.new(model, :es)

    refute localised_model.valid?
    assert_equal ["can't be blank"], localised_model.errors[:title]
  end

  test "ActiveRecord has_many associations are localised" do
    contact = create(:contact)
    create(:contact_number, contact: contact)

    localised_model = LocalisedModel.new(contact, :es, [:contact_numbers])
    assert_equal :es, localised_model.contact_numbers.first.fixed_locale
  end

  test "ActiveRecord belongs_to associations are localised" do
    contact = create(:contact)
    number = create(:contact_number, contact: contact)

    localised_model = LocalisedModel.new(number, :es, [:contact])
    assert_equal :es, localised_model.contact.fixed_locale
  end
end
