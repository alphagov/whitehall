require "component_test_helper"

class GovspeakeditorComponentTest < ComponentTestCase
  def component_name
    "govspeak_editor"
  end

  test "errors when no parameters given" do
    assert_raises do
      render_component({})
    end
  end

  test "renders the basic component" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
    })

    assert_select ".app-c-govspeak-editor[data-module='govspeak-editor']"
    assert_select ".govuk-label.govuk-label--s", false
  end

  test "sets label to bold" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
        bold: true,
      },
    })

    assert_select ".govuk-label.govuk-label--s"
  end

  test "includes hint" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      hint: "look out",
      hint_id: "optional",
    })

    assert_select ".govuk-hint[id='optional']", text: "look out"
  end

  test "can display errors" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      error_items: [
        {
          text: "there's nothing here",
          href: "error1",
        },
        {
          text: "no really, there's nothing here",
          href: "error2",
        },
      ],
    })

    assert_select ".app-c-govspeak-editor.govuk-form-group--error"
    assert_select ".govuk-error-message", text: "Error: there's nothing hereno really, there's nothing here"
  end

  test "can set number of rows on the textarea" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      rows: 2,
    })

    assert_select ".govuk-textarea[rows='2']"
  end

  test "can set the textarea to right to left" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      right_to_left: true,
    })

    assert_select ".govuk-textarea[dir='rtl']"
  end

  test "accepts data attributes" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      data_attributes: {
        some_attribute: "This is for the main component",
        module: "one-module",
      },
      textarea_data_attributes: {
        some_attribute: "This is for the textarea",
        module: "two-module",
      },
      preview_button_data_attributes: {
        some_attribute: "This is for the toggle preview button",
        module: "three-module",
      },
    })

    assert_select ".app-c-govspeak-editor[data-some-attribute='This is for the main component'][data-module='one-module govspeak-editor']"
    assert_select ".govuk-textarea[data-some-attribute='This is for the textarea'][data-module='two-module paste-html-to-govspeak']"
    assert_select ".govuk-button[data-some-attribute='This is for the toggle preview button'][data-module='three-module']"
  end

  test "can have a value for the textarea" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      value: "Here is some text I wrote",
    })

    assert_select ".govuk-textarea", text: "Here is some text I wrote"
  end

  test "can have attachments and alternative format provider id" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      data_attributes: {
        alternative_format_provider_id: "123",
        image_ids: [1, 2, 3],
        attachment_ids: [3, 4, 5],
      },
      value: "This is an attachment: !@1 This is an image: !!1",
    })

    assert_select ".app-c-govspeak-editor[data-alternative-format-provider-id='123'][data-image-ids='[1,2,3]'][data-attachment-ids='[3,4,5]']"
    assert_select ".govuk-textarea", text: "This is an attachment: !@1 This is an image: !!1"
  end
end
