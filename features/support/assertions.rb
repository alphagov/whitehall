module Assertions
  # Fix pending - https://github.com/bbatsov/rubocop/issues/4885
  # rubocop:disable Style/MixinUsage
  include LocalisedUrlPathHelper
  # rubocop:enable Style/MixinUsage

  def assert_current_url(url, message = nil)
    uri = Addressable::URI.parse(url)
    current_uri = Addressable::URI.parse(current_url)

    assert_equal uri.path, current_uri.path, message

    if uri.port.nil?
      assert_nil uri.port, message
    else
      assert_equal uri.port, current_uri.port, message
    end

    if uri.query.nil?
      assert_nil uri.query, message
    else
      assert_equal uri.query, current_uri.query, message
    end

    if uri.fragment.nil?
      assert_nil uri.fragment, message
    else
      assert_equal uri.fragment, current_uri.fragment, message
    end
  end

  def assert_path(path)
    assert_equal path, page.current_path
  end
end

World(Assertions)
