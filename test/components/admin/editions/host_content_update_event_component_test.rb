require "test_helper"

class Admin::Editions::HostContentUpdateEventComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:created_at) { Time.zone.local(2020, 1, 1, 11, 11) }
  let(:content_title) { "Some content" }
  let(:document_type) { "Email address" }
  let(:user) { build_stubbed(:user) }

  let(:host_content_update_event) do
    build(:host_content_update_event, content_title:, created_at:, author: user, document_type:)
  end

  it "constructs output based on the entry when an actor is present" do
    render_inline(Admin::Editions::HostContentUpdateEventComponent.new(host_content_update_event))

    assert_equal page.find("h4").text, "Content block updated"
    assert_equal page.all("p")[0].text.strip, "#{document_type}: #{content_title}"
    assert_equal page.all("a")[0].native.inner_html, "[View<span class=\"govuk-visually-hidden\"> #{content_title}</span> in Content Block Manager]"
    assert_equal page.all("a")[0].native["href"], content_block_manager_content_block_content_id_path(content_id: host_content_update_event.content_id)

    assert_equal page.all("p")[2].text.strip, "1 January 2020 11:11am by #{user.name}"
  end

  describe "when an actor is not present" do
    let(:user) { nil }

    it "shows removed user when an actor is not present" do
      render_inline(Admin::Editions::HostContentUpdateEventComponent.new(host_content_update_event))

      assert_equal page.all("p")[2].text.strip, "1 January 2020 11:11am by User (removed)"
    end
  end
end
