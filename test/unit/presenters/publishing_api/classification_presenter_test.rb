require 'test_helper'

class PublishingApi::ClassificationTest < ActiveSupport::TestCase
  test "presents a valid placeholder 'topic' content item" do
    topic = create(:topic, name: "Defence and armed forces")
    public_path = "/government/topics/defence-and-armed-forces"

    expected = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "placeholder",
      document_type: "policy_area",
      title: "Defence and armed forces",
      description: nil,
      locale: "en",
      need_ids: [],
      routes: [
        {
          path: public_path,
          type: "exact"
        }
      ],
      redirects: [],
      public_updated_at: topic.updated_at,
      update_type: "major",
      details: {},
    }

    presenter = ::PublishingApiPresenters.presenter_for(topic)

    assert_equal expected, presenter.content
    assert_valid_against_schema(presenter.content, "placeholder")
  end
end
