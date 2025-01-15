require "test_helper"

class ContentBlockManager::SignonUser::Show::SummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:organisation) { build(:signon_user_organisation, name: "Department for Example") }
  let(:user) do
    build(
      :signon_user,
      name: "John Smith",
      email: "john.smith@example.com",
      organisation:,
    )
  end

  it "renders a Govuk User correctly" do
    render_inline(ContentBlockManager::SignonUser::Show::SummaryListComponent.new(user:))

    assert_selector ".govuk-summary-list__row", count: 3

    assert_selector ".govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__value", text: user.name

    assert_selector ".govuk-summary-list__key", text: "Email"
    assert_selector ".govuk-summary-list__value", text: user.email

    assert_selector ".govuk-summary-list__key", text: "Organisation"
    assert_selector ".govuk-summary-list__value", text: user.organisation.name
  end
end
