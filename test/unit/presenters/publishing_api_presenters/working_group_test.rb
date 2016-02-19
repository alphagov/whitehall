require 'test_helper'

class PublishingApiPresenters::WorkingGroupTest < ActiveSupport::TestCase
  test 'presents a valid placeholder "working_group" content item' do
    group = create(:policy_group,
      name: "Government Digital Service",
      email: "group-1@example.com",
      summary: "This is some plaintext in the summary field",
      description: "This is some *Govspeak* in the description field",
                  )
    public_path = '/government/groups/government-digital-service'

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      format: "working_group",
      title: "Government Digital Service",
      description: "This is some plaintext in the summary field", # This is deliberately the 'wrong' way around
      locale: "en",
      need_ids: [],
      routes: [
        {
          path: public_path,
          type: 'exact'
        }
      ],
      redirects: [],
      update_type: 'major',
      public_updated_at: group.updated_at,
      details: {
        email: "group-1@example.com",
        body: "<div class=\"govspeak\"><p>This is some <em>Govspeak</em> in the description field</p>\n</div>", # This is deliberately the 'wrong' way around
      }
    }

    presenter = PublishingApiPresenters::WorkingGroup.new(group)

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, 'working_group')
  end

  test "renders attachments in the body" do
    group = create(:policy_group, :with_file_attachment, description: "#Heading\n\n!@1\n\n##Subheading")

    presenter = PublishingApiPresenters::WorkingGroup.new(group)

    body = Nokogiri::HTML.parse(presenter.content[:details][:body])
    assert_not_nil body.at_css("section.attachment")
    assert_match %r{#{group.attachments.first.title}}, body.at_css("section.attachment")
  end
end
