# frozen_string_literal: true

require "test_helper"

class Admin::Editions::FactCheckingTabComponentTest < ViewComponent::TestCase
  test "renders fact checking responses and requests correctly when an edition has fact checks" do
    edition = create(:case_study)
    create(:fact_check_request, email_address: "user-1@example.com", comments: "This is accurate.", updated_at: 2.days.ago, edition:)
    create(:fact_check_request, email_address: "user-2@example.com", comments: "This is inaccurate.", updated_at: 1.day.ago, edition:)
    create(:fact_check_request, email_address: "user-3@example.com", edition:)

    render_inline(Admin::Editions::FactCheckingTabComponent.new(edition:))

    assert_selector ".responses h3", text: "Responses"
    assert_selector ".responses li", count: 2
    assert_selector ".responses li", text: "user-2@example.com 1 day agoThis is inaccurate."
    assert_selector ".responses li", text: "user-1@example.com 2 days agoThis is accurate."

    assert_selector ".pending h3", text: "Pending requests"
    assert_selector ".pending li", count: 1
    assert_selector ".pending li", text: "user-3@example.com less than a minute ago"
  end

  test "renders `Document doesn't have any fact checking responses yet.` when none have been requested" do
    edition = create(:case_study)

    render_inline(Admin::Editions::FactCheckingTabComponent.new(edition:))

    assert_selector ".responses h3", text: "Responses", count: 0
    assert_selector ".responses p", text: "Document doesn't have any fact checking responses yet."
  end

  test "renders guidance on requested a fact check when `send_request_section` isnt set to true" do
    edition = create(:case_study)

    render_inline(Admin::Editions::FactCheckingTabComponent.new(edition:))

    assert_selector ".send-request p", text: "To send a fact check request, save your changes."

    assert_selector ".send-request h3", text: "Send request", count: 0
    assert_selector "input[type='text'][name='fact_check_request[email_address]']", count: 0
    assert_selector "textarea[name='fact_check_request[instructions]']", count: 0
  end

  test "renders fact check request form fields when `send_request_section` is set to true" do
    edition = create(:case_study)

    render_inline(Admin::Editions::FactCheckingTabComponent.new(edition:, send_request_section: true))

    assert_selector ".send-request h3", text: "Send request"
    assert_selector "input[type='text'][name='fact_check_request[email_address]']"
    assert_selector "textarea[name='fact_check_request[instructions]']"

    assert_selector ".send-request p", text: "To send a fact check request, save your changes.", count: 0
  end
end
