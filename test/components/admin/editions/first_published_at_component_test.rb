# frozen_string_literal: true

require "test_helper"

class Admin::Editions::FirstPublishedAtComponentTest < ViewComponent::TestCase
  test "doesn't render when the edition is a consultation" do
    edition = build(:consultation)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(edition:, previously_published: true))

    assert page.text.blank?
  end
end
