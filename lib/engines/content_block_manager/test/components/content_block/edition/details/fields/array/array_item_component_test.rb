require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::Array::ItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::Array::ItemComponent.new(
      field_name:,
      array_items:,
      name_prefix:,
      id_prefix:,
      value: field_value,
      index:,
    )
  end

  describe "if the array item is a string" do
    let(:field_name) { "Bar" }
    let(:array_items) { { "type" => "string" } }
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { ["", "Some text"] }
    let(:index) { 1 }

    it "renders a text field" do
      render_inline(component)

      assert_selector "label", text: "Bar"
      assert_selector "input[type='text'][value='Some text'][name='foo[bar][]'][id='foo_bar_1']"
    end
  end

  describe "if the array item is an enum" do
    let(:field_name) { "Bar" }
    let(:array_items) { { "type" => "string", "enum" => %w[foo bar baz] } }
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { nil }
    let(:index) { 1 }

    it "renders a select field" do
      render_inline(component)

      assert_selector "label", text: "Bar"
      assert_selector "select[name='foo[bar][]'][id='foo_bar_1']" do |select|
        select.assert_selector "option[value='foo']", text: "Foo"
        select.assert_selector "option[value='bar']", text: "Bar"
        select.assert_selector "option[value='baz']", text: "Baz"
      end
    end

    describe "when the value is set" do
      let(:field_value) { "baz" }

      it "marks the appropriate option as selected" do
        render_inline(component)

        assert_selector "label", text: "Bar"
        assert_selector "select[name='foo[bar][]'][id='foo_bar_1']" do |select|
          select.assert_selector "option[value='foo']", text: "Foo"
          select.assert_selector "option[value='bar']", text: "Bar"
          select.assert_selector "option[value='baz'][selected]", text: "Baz"
        end
      end
    end
  end

  describe "if the array item is an object" do
    let(:field_name) { "Bar" }
    let(:array_items) do
      {
        "type" => "object",
        "properties" => {
          "fizz" => { "type" => "string" },
          "buzz" => { "type" => "string" },
        },
      }
    end
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { [{}, { "fizz" => "Something", "buzz" => "Else" }] }
    let(:index) { 1 }

    it "renders a text field for each item" do
      render_inline(component)

      assert_selector ".govuk-form-group", text: /Fizz/ do |form_group|
        form_group.assert_selector "label", text: "Fizz"
        form_group.assert_selector "input[type='text'][value='Something'][name='foo[bar][][fizz]'][id='foo_bar_1_fizz']"
      end

      assert_selector ".govuk-form-group", text: /Buzz/ do |form_group|
        form_group.assert_selector "label", text: "Buzz"
        form_group.assert_selector "input[type='text'][value='Else'][name='foo[bar][][buzz]'][id='foo_bar_1_buzz']"
      end
    end

    describe "when an enum is included" do
      let(:array_items) do
        {
          "type" => "object",
          "properties" => {
            "fizz" => { "type" => "string", "enum" => %w[foo bar baz] },
          },
        }
      end

      it "renders a select field" do
        render_inline(component)

        assert_selector "label", text: "Fizz"
        assert_selector "select[name='foo[bar][][fizz]'][id='foo_bar_1_fizz']" do |select|
          select.assert_selector "option[value='foo']", text: "Foo"
          select.assert_selector "option[value='bar']", text: "Bar"
          select.assert_selector "option[value='baz']", text: "Baz"
        end
      end

      describe "when the value is set" do
        let(:field_value) { [{}, { "fizz" => "baz" }] }

        it "marks the appropriate option as selected" do
          render_inline(component)

          assert_selector "label", text: "Fizz"
          assert_selector "select[name='foo[bar][][fizz]'][id='foo_bar_1_fizz']" do |select|
            select.assert_selector "option[value='foo']", text: "Foo"
            select.assert_selector "option[value='bar']", text: "Bar"
            select.assert_selector "option[value='baz'][selected]", text: "Baz"
          end
        end
      end
    end
  end
end
