# frozen_string_literal: true

require "test_helper"

class Admin::Editions::PublishingPrerequisitesComponentTest < ViewComponent::TestCase
  test "renders a warning for each unmet publishing prerequisite" do
    edition = build(:draft_standard_edition)
    edition.stubs(:unmet_publishing_prerequisites).returns(["First thing to do", "Second thing to do"])

    render_inline(Admin::Editions::PublishingPrerequisitesComponent.new(edition:))

    assert_selector ".govuk-warning-text", count: 2
    assert_selector ".govuk-warning-text", text: "First thing to do"
    assert_selector ".govuk-warning-text", text: "Second thing to do"
  end

  test "does not render when there are no unmet publishing prerequisites" do
    edition = build(:draft_standard_edition)
    edition.stubs(:unmet_publishing_prerequisites).returns([])

    render_inline(Admin::Editions::PublishingPrerequisitesComponent.new(edition:))

    assert page.text.blank?
  end

  test "does not render when the edition is not pre-publication" do
    edition = build(:published_standard_edition)
    edition.stubs(:unmet_publishing_prerequisites).returns(["First thing to do"])

    render_inline(Admin::Editions::PublishingPrerequisitesComponent.new(edition:))

    assert page.text.blank?
  end

  test "does not render for editions that do not support publishing prerequisites" do
    render_inline(Admin::Editions::PublishingPrerequisitesComponent.new(edition: build(:draft_publication)))

    assert page.text.blank?
  end
end
