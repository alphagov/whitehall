require "test_helper"

class Admin::Editions::HostContentUpdateEventComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:created_at) { Time.zone.local(2020, 1, 1, 11, 11) }
  let(:content_title) { "Some content" }
  let(:user) { build_stubbed(:user) }

  let(:host_content_update_event) do
    build(:host_content_update_event, content_title:, created_at:, author: user)
  end

  it "constructs output based on the entry when an actor is present" do
    render_inline(Admin::Editions::HostContentUpdateEventComponent.new(host_content_update_event))

    assert_equal page.find("h4").text, "Content Block Update"
    assert_equal page.all("p")[0].text.strip, "#{content_title} updated"
    assert_equal page.all("p")[1].text.strip, "1 January 2020 11:11am by #{user.name}"
  end

  describe "when an actor is not present" do
    let(:user) { nil }

    it "shows removed user when an actor is not present" do
      render_inline(Admin::Editions::HostContentUpdateEventComponent.new(host_content_update_event))

      assert_equal page.all("p")[1].text.strip, "1 January 2020 11:11am by User (removed)"
    end
  end
end
