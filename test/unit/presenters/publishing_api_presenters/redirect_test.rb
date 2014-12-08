require 'test_helper'

class PublishingApiPresenters::RedirectTest < ActiveSupport::TestCase

  setup do
    @case_study = create(:draft_case_study,
                        title: 'Case study title',
                        first_published_at: Time.zone.now,
                        summary: 'The summary')
    @unpublishing = create(:unpublishing, edition: @case_study,
                          explanation: 'it is rubbish',
                          redirect: true,
                          alternative_url: "#{Whitehall.public_root}/foobar")
  end

  def present(edition, options = {})
    PublishingApiPresenters::Redirect.new(edition, options).as_json
  end

  test "presenter generates valid JSON according to the schema" do
    presented_json = present(@case_study).to_json

    validator = GovukContentSchema::Validator.new('redirect', presented_json)
    assert validator.valid?, "JSON not valid against unpublishing schema: #{validator.errors.to_s}"
  end

  test 'presents an unpublished edition with redirect' do
    public_path = Whitehall.url_maker.public_document_path(@case_study)
    expected_hash = {
      base_path: public_path,
      format: 'redirect',
      publishing_app: 'whitehall',
      update_type: 'major',
      redirects: [
        { path: public_path, type: 'exact', destination: '/foobar' }
      ]
    }
    assert_equal expected_hash, present(@case_study)
  end
end
