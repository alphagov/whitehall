module CacheControlTestHelpers
  def assert_cache_control(expected_directive)
    cache_control_header = response.headers['Cache-Control']
    assignments, directives = cache_control_header.split(/, */).partition {|stmt| stmt.include?("=")}
    if expected_directive.include?("=")
      expected_name, expected_value = expected_directive.split("=")
      assignments = Hash[assignments.map {|a| a.split("=")}]
      assert assignments.has_key?(expected_name), "No #{expected_name} directive found in #{cache_control_header}"
      assert_equal expected_value, assignments[expected_name]
    else
      assert directives.include?(expected_directive), "No #{expected_name} directive found in #{cache_control_header}"
    end
  end
end
