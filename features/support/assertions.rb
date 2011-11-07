module Assertions
  def assert_current_url(url, message=nil)
    assert_equal URI.split(url)[3..-1], URI.split(current_url)[3..-1], message
  end
end

World(Assertions)