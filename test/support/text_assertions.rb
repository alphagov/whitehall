module TextAssertions
  def assert_string_includes(expected, actual)
    assert actual.include?(expected), "Expected \"#{actual}\" to include \"#{expected}\"."
  end
end
