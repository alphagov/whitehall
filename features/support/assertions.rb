module Assertions
  def assert_current_url(url, message=nil)
    assert_equal URI.split(url)[3..-1], URI.split(current_url)[3..-1], message
  end

  def assert_path(path)
    assert_equal path, page.current_path
  end
end

World(Assertions)