require "test_helper"

class SummaryCardListTest < ActionView::TestCase
  test "the component requires a title to render" do
    error = assert_raises ActionView::Template::Error do
      render("components/summary_card/summary_card")
    end

    assert error.message.include?("undefined local variable or method `title'")
  end

  test "renders a summary card component with a title" do
    render("components/summary_card/summary_card", {
      title: "Title",
    })

    assert_select ".app-c-summary_card-list", count: 1
    assert_select ".govuk-summary-card__title", text: "Title"
  end

  test "renders links in the summary card title when passed" do
    render("components/summary_card/summary_card", {
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
    render("components/summary_card/summary_card", {
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

  test "yields the provided markup inside the content area" do
    render("components/summary_card/summary_card", {
      title: "Title",
    }) do
      tag.p("Hello world", class: "test")
    end

    assert_select ".govuk-summary-card__content .test", text: "Hello world"
  end
end
