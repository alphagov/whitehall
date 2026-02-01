require "test_helper"
require "rake"

class MigrateSocialMediaBlockContentTest < ActiveSupport::TestCase
  setup do
    @original_rake = Rake.application
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "tasks/migrate_social_media_block_content"
    Rake::Task.define_task(:environment)
    ConfigurableDocumentType.instance_variable_set(:@types, nil)
  end

  teardown do
    Rake.application = @original_rake
  end

  test "migrates legacy social media service IDs to slugs" do
    event = create(:topical_event, block_content: { "body" => "Something" })

    twitter = create(:social_media_service, name: "Twitter", id: 1)
    facebook = create(:social_media_service, name: "Facebook", id: 2)

    create(:social_media_account, socialable: event, social_media_service: twitter, url: "https://twitter.com", title: "My Twitter")
    create(:social_media_account, socialable: event, social_media_service: facebook, url: "https://facebook.com", title: "My Facebook")

    # Check the raw column because the model accessor uses a shim to return legacy links
    assert_empty event.reload.read_attribute(:block_content)["social_media_links"]

    @rake["migrate_social_media_block_content"].invoke

    event.reload
    links = event.block_content["social_media_links"]

    assert_equal 2, event.block_content.social_media_links.count

    twitter_link = links.find { |l| l["social_media_service_id"] == "twitter" }
    assert_not_nil twitter_link
    assert_equal "https://twitter.com", twitter_link["url"]
    assert_equal "My Twitter", twitter_link["title"]

    facebook_link = links.find { |l| l["social_media_service_id"] == "facebook" }
    assert_not_nil facebook_link
    assert_equal "https://facebook.com", facebook_link["url"]
  end
end
