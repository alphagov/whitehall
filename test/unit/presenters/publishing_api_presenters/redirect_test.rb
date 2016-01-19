require 'test_helper'

class PublishingApiPresenters::RedirectTest < ActiveSupport::TestCase
  test '#content returns a redirect representation' do
    expected_hash = {
      base_path: '/foo',
      format: 'redirect',
      publishing_app: 'whitehall',
      redirects: [
        { path: '/foo', type: 'exact', destination: '/bar' },
        { path: '/foo', type: 'exact', destination: '/baz/qux' }
      ],
    }

    presenter = PublishingApiPresenters::Redirect.new('/foo', [
      { path: '/foo', type: 'exact', destination: '/bar' },
      { path: '/foo', type: 'exact', destination: '/baz/qux' }])

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, 'redirect')
  end

  test "#content_id is a random uuid" do
    uuid = SecureRandom.uuid
    SecureRandom.stubs(:uuid).returns(uuid)

    presenter = PublishingApiPresenters::Redirect.new('/foo', ['/bar', '/baz/qux'])
    assert_equal uuid, presenter.content_id

    SecureRandom.unstub(:uuid)

    assert_not_equal PublishingApiPresenters::Redirect.new('/foo', ['/bar', '/baz/qux']).content_id, presenter.content_id
  end
end
