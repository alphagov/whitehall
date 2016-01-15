require 'test_helper'

class PublishingApiPresenters::WorkingGroupTest < ActiveSupport::TestCase
  test 'presents a valid placeholder "working_group" content item' do
    group = create(:policy_group,
      name: "Government Digital Service"
                  )
    public_path = '/government/groups/government-digital-service'

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      format: "placeholder_working_group",
      title: "Government Digital Service",
      description: nil,
      locale: "en",
      need_ids: [],
      routes: [
        {
          path: public_path,
          type: 'exact'
        }
      ],
      redirects: [],
      public_updated_at: group.updated_at,
      details: {}
    }

    presenter = PublishingApiPresenters::WorkingGroup.new(group)

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, 'placeholder')
  end
end
