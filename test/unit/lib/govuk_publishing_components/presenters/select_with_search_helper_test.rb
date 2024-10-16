require "test_helper"

class SelectWithSearchHelperPresenterTest < PresenterTestCase
  test "should generate options for select" do
    described_class = GovukPublishingComponents::Presenters::SelectWithSearchHelper

    instance = described_class.new(
      options: [
        {
          text: "Foo",
          value: "Bar",
        },
        {
          text: "Option",
          value: "opt",
          selected: true,
        },
        {
          text: "Baz",
          value: "Bam",
        },
      ],
    )

    expected = <<~HTML.strip
      <option value="Bar">Foo</option>
      <option selected="selected" value="opt">Option</option>
      <option value="Bam">Baz</option>
    HTML

    assert_equal expected, instance.options_html
  end

  test "should generate grouped options for select" do
    described_class = GovukPublishingComponents::Presenters::SelectWithSearchHelper

    instance = described_class.new(
      grouped_options: [
        [
          "",
          [
            {
              text: "All organisations",
              value: "",
              selected: true,
            },
          ],
        ],
        [
          "",
          [
            {
              text: "All foo",
              value: "foo",
            },
          ],
        ],
        [
          "Live organisations",
          %w[foo bar baz].map do |key|
            {
              text: key,
              value: key,
            }
          end,
        ],
      ],
    )

    expected = <<~HTML.strip
      <optgroup label="">
      <option selected="selected" value="">All organisations</option>
      </optgroup>

      <optgroup label="">
      <option value="foo">All foo</option>
      </optgroup>

      <optgroup label="Live organisations">
      <option value="foo">foo</option>
      <option value="bar">bar</option>
      <option value="baz">baz</option>
      </optgroup>
    HTML

    assert_equal expected.delete("\n"), instance.options_html.delete("\n")
  end

  test "should include a blank option when told to" do
    described_class = GovukPublishingComponents::Presenters::SelectWithSearchHelper

    instance = described_class.new(
      include_blank: true,
      options: [
        {
          text: "Foo",
          value: "Bar",
        },
      ],
    )

    expected = <<~HTML.strip
      <option value=""></option><option value="Bar">Foo</option>
    HTML

    assert_equal expected, instance.options_html
  end
end
