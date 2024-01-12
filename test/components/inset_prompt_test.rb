require "component_test_helper"

class InsetpromptComponentTest < ComponentTestCase
  def component_name
    "inset_prompt"
  end

  test "renders nothing when no parameters given" do
    assert_empty render_component({})
  end

  test "shows a title" do
    render_component({
      title: "My title",
    })

    assert_select ".app-c-inset-prompt"
    assert_select ".app-c-inset-prompt__title", text: "My title"
  end

  test "shows a description" do
    render_component({
      description: "My description",
    })

    assert_select ".app-c-inset-prompt"
    assert_select ".app-c-inset-prompt__body", text: "My description"
  end

  test "accepts an id" do
    render_component({
      description: "My description",
      id: "my-id",
    })

    assert_select ".app-c-inset-prompt[id='my-id']"
  end

  test "can show items" do
    render_component({
      description: "My description",
      items: [
        {
          text: "item 1",
          href: "#item1",
          data_attributes: {
            test: "item-1",
          },
        },
        {
          text: "item 2",
          data_attributes: {
            test: "item-2",
          },
        },
      ],
    })

    assert_select ".app-c-inset-prompt__list"
    assert_select ".govuk-link[href='#item1'][data-test='item-1']", text: "item 1"
    assert_select ".app-c-inset-prompt__list li span[data-test='item-2']", text: "item 2"
  end

  test "can show an error" do
    render_component({
      description: "My description",
      error: true,
    })

    assert_select ".app-c-inset-prompt.app-c-inset-prompt--error"
  end

  test "can accept data attributes" do
    render_component({
      description: "My description",
      data_attributes: {
        module: "not-a-module",
        banoffee: "pie",
      },
    })

    assert_select ".app-c-inset-prompt[data-module='not-a-module'][data-banoffee='pie']"
  end
end
