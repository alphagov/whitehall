require 'test_helper'

class PublishingApiPresenters::WorkingGroupTest < ActiveSupport::TestCase
  test 'presents a valid placeholder "working_group" content item' do
    group = create(:policy_group,
      name: "Government Digital Service"
    )

    expected_hash = {
      content_id: group.content_id,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      format: "placeholder_working_group",
      title: "Government Digital Service",
      locale: "en",
      update_type: "major",
      routes: [
        {
          path: '/government/groups/government-digital-service',
          type: 'exact'
        }
      ],
      public_updated_at: group.updated_at,
    }

    presenter = PublishingApiPresenters::WorkingGroup.new(group)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'placeholder')
  end
end
