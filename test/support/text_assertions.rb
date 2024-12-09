module TextAssertions
  def assert_string_includes(expected, actual)
    assert actual.include?(expected), "Expected \"#{actual}\" to include \"#{expected}\"."
  end

  def assert_equal_ignoring_whitespace(expected, actual)
    expected_without_whitespace = expected.gsub(/\s+/, "").strip
    actual_without_whitespace = actual.gsub(/\s+/, "").strip

    assert_equal expected_without_whitespace, actual_without_whitespace
  end
end
