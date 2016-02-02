require 'test_helper'

class PublishingApiPresenters::ItemRedirectTest < ActiveSupport::TestCase
  class TestObj
    def redirects
      [
          path: "/test", type: "exact", destination: "/eagles"
      ]
    end

    def base_path
      "/test"
    end
  end

  test '#content returns a redirect representation' do
    expected_hash = {
      base_path: '/test',
      format: 'redirect',
      publishing_app: 'whitehall',
      redirects: [
        { path: '/test', type: 'exact', destination: '/eagles' }
      ],
    }

    presenter = PublishingApiPresenters::ItemRedirect.new(TestObj.new)

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, 'redirect')
  end

  test "#content_id is a random uuid" do
    uuid = SecureRandom.uuid
    SecureRandom.stubs(:uuid).returns(uuid)

    presenter = PublishingApiPresenters::ItemRedirect.new(TestObj.new)
    assert_equal uuid, presenter.content_id
  end
end
