module Assertions
  def assert_current_url(url, message = nil)
    uri = Addressable::URI.parse(url)
    current_uri = Addressable::URI.parse(current_url)

    assert_equal uri.port, current_uri.port, message
    assert_equal uri.path, current_uri.path, message
    assert_equal uri.query, current_uri.query, message
    assert_equal uri.fragment, current_uri.fragment, message
  end

  def assert_path(path)
    assert_equal path, page.current_path
  end
end

World(Assertions)
