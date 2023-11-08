require "test_helper"

class SummaryCardComponentTest < ActionView::TestCase
  test "the component requires a title to render" do
    error = assert_raises ActionView::Template::Error do
      render("components/summary_card_component")
    end

    assert error.message.include?("undefined local variable or method `title'")
  end

  test "renders a summary card component with a title" do
    render("components/summary_card_component", {
      title: "Title",
    })

    assert_select ".app-c-summary-card-component", count: 1
    assert_select ".govuk-summary-card__title", text: "Title"
  end

  test "renders links in the summary card title when passed" do
    render("components/summary_card_component", {
      title: "Title",
      summary_card_actions: [
        {
          label: "View",
          href: "#1",
        },
        {
          label: "Edit",
          href: "#2",
        },
      ],
    })

    assert_select ".govuk-summary-card__title-wrapper" do
      assert_select ".govuk-summary-card__action:nth-child(1) a[href='#1']", text: "View Title"
      assert_select ".govuk-summary-card__action:nth-child(2) a[href='#2']", text: "Edit Title"
    end
  end

  test "renders summary card title link with the correct class when destructive: true is passed" do
    render("components/summary_card_component", {
      title: "Title",
      summary_card_actions: [
        {
          label: "Delete",
          href: "#1",
          destructive: true,
        },
      ],
    })

    assert_select ".govuk-summary-card__title-wrapper" do
      assert_select ".govuk-summary-card__action .gem-link--destructive", text: "Delete Title"
    end
  end

  test "renders a summary card component with a title and a summary list with key value pairs when provided" do
    render("components/summary_card_component", {
      title: "Title",
      rows: [
        {
          key: "Key 1",
          value: "Value 1",
        },
        {
          key: "Key 2",
          value: "Value 2",
        },
      ],
    })

    assert_select ".app-c-summary-card-component", count: 1
    assert_select ".govuk-summary-card__title", text: "Title"
    assert_select ".govuk-summary-list .govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Key 1"
    assert_select ".govuk-summary-list .govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "Value 1"
    assert_select ".govuk-summary-list .govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Key 2"
    assert_select ".govuk-summary-list .govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "Value 2"
  end

  test "renders summary list links when provided" do
    render("components/summary_card_component", {
      title: "Title",
      rows: [
        {
          key: "Key 1",
          value: "Value 1",
          actions: [
            {
              label: "View",
              href: "#1",
            },
            {
              label: "Edit",
              href: "#2",
            },
          ],
        },
        {
          key: "Key 2",
          value: "Value 2",
          actions: [
            {
              label: "View",
              href: "#3",
            },
            {
              label: "Edit",
              href: "#4",
            },
          ],
        },
      ],
    })

    assert_select ".govuk-summary-list__row:nth-child(1)" do
      assert_select ".govuk-summary-list__actions a:nth-child(1)[href='#1']", text: "View Key 1"
      assert_select ".govuk-summary-list__actions a:nth-child(2)[href='#2']", text: "Edit Key 1"
    end

    assert_select ".govuk-summary-list__row:nth-child(2)" do
      assert_select ".govuk-summary-list__actions a:nth-child(1)[href='#3']", text: "View Key 2"
      assert_select ".govuk-summary-list__actions a:nth-child(2)[href='#4']", text: "Edit Key 2"
    end
  end

  test "renders summary card list action link with the correct class when destructive: true is passed" do
    render("components/summary_card_component", {
      title: "Title",
      rows: [
        {
          key: "Key 1",
          value: "Value 1",
          actions: [
            {
              label: "Delete",
              href: "#1",
              destructive: true,
            },
          ],
        },
      ],
    })

    assert_select ".govuk-summary-list__actions .gem-link--destructive", text: "Delete Key 1"
  end

  test "renders summary card list action link with the correct rel and target when opens_in_new_tab: true is passed" do
    render("components/summary_card_component", {
      title: "Title",
      rows: [
        {
          key: "Key 1",
          value: "Value 1",
          actions: [
            {
              label: "View",
              href: "#1",
              opens_in_new_tab: true,
            },
          ],
        },
      ],
    })

    assert_select ".govuk-summary-list__actions .govuk-link" do |link|
      link = link.first
      assert_equal "View Key 1 (opens in new tab)", link.text
      assert_equal "noreferrer noopener", link[:rel]
      assert_equal "_blank", link[:target]
    end
  end
end
