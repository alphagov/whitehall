module PathHelper
  def assert_final_path(path, expected)
    previous_location = page.current_path
    visit path
    assert_match /#{Regexp.escape(expected)}/, page.current_path
    visit previous_location
  end

  def ensure_path(path)
    unless current_path == path
      visit path
    end
  end
end

World(PathHelper)
