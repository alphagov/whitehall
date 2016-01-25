require 'test_helper'
require 'securerandom'

class PublishingApiPresenters::GoneTest < ActiveSupport::TestCase
  test 'presents a valid "gone" content item' do
    content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: content_id)

    public_path = '/government/case-studies/case-study-title'
    expected_hash = {
      base_path: public_path,
      publishing_app: 'whitehall',
      format: 'gone',
      routes: [{ path: public_path, type: 'exact' }],
    }

    presenter = PublishingApiPresenters::Gone.new(public_path)

    assert_equal expected_hash, presenter.content
    assert_equal content_id, presenter.content_id
    assert_valid_against_schema(presenter.content, 'gone')
  end
end
