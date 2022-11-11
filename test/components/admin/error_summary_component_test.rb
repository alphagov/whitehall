require "test_helper"

class Admin::ErrorSummaryComponentTest < ViewComponent::TestCase
  setup do
    @object_with_no_errors = ErrorSummaryTestObject.new("title", Time.zone.today)
    @object_with_errors = ErrorSummaryTestObject.new(nil, nil)
    @object_with_errors.validate
  end

  test "does not render if there are no errors on the object passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_no_errors))
    assert_empty page.text
  end

  test "uses the noun to construct the title if one is passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors, noun: "withdrawal explanation"))
    assert_selector "h2", text: "To save the withdrawal explanation please fix the following issues:"
  end

  test "editions use the self.format_name method to construct the noun in the title if one is not passed in" do
    detailed_guide = build(:detailed_guide, title: nil)
    detailed_guide.validate
    render_inline(Admin::ErrorSummaryComponent.new(object: detailed_guide))

    assert_selector "h2", text: "To save the detailed guidance please fix the following issues:"
  end

  test "other objects use the class of the object to construct the title if no noun is passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors))

    assert_selector "h2", text: "To save the error summary test object please fix the following issues:"
  end

  test "uses the `verb` to constuct the title if passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors, verb: "karate chop"))
    assert_selector "h2", text: "To karate chop the error summary test object please fix the following issues:"
  end

  test "defaults the verb of the to `save` if a verb is not passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors))
    assert_selector "h2", text: "To save the error summary test object please fix the following issues:"
  end

  test "constructs a list of links which link to an id based on the objects class and attribute of the error" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#error_summary_test_object_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#error_summary_test_object_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#error_summary_test_object_date"
  end

  test "overrides the class in the href with `parent class` if passed in" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors, parent_class: "parent_class"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#parent_class_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#parent_class_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#parent_class_date"
  end

  test "constructs data modules for tracking analytics based on the class name and error message" do
    render_inline(Admin::ErrorSummaryComponent.new(object: @object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal first_link["data-module"], "auto-track-event"
    assert_equal first_link["data-track-category"], "form-error"
    assert_equal first_link["data-track-action"], "error summary test object-error"
    assert_equal first_link["data-track-label"], "Title can't be blank"
    assert_equal second_link["data-module"], "auto-track-event"
    assert_equal second_link["data-track-category"], "form-error"
    assert_equal second_link["data-track-action"], "error summary test object-error"
    assert_equal second_link["data-track-label"], "Date can't be blank"
    assert_equal third_link["data-module"], "auto-track-event"
    assert_equal third_link["data-track-category"], "form-error"
    assert_equal third_link["data-track-action"], "error summary test object-error"
    assert_equal third_link["data-track-label"], "Date is invalid"
  end

  test "when an errors attribute is base it renders the error as text not a link" do
    object = ErrorSummaryTestObject.new("title", Time.zone.today)
    object.errors.add(:base, "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input.")
    render_inline(Admin::ErrorSummaryComponent.new(object:))

    assert_selector ".gem-c-error-summary__list-item a", count: 0
    assert_selector ".gem-c-error-summary__list-item span", text: "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input."
  end
end

class ErrorSummaryTestObject
  include ActiveModel::Model
  attr_accessor :title, :date

  validates :title, :date, presence: true
  validate :date_is_a_date

  def initialize(title, date)
    @title = title
    @date = date
  end

  def date_is_a_date
    errors.add(:date, :invalid) unless date.is_a?(Date)
  end
end
