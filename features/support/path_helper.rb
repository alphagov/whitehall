module PathHelper
  def assert_final_path(path, expected)
    previous_location = page.current_path
    visit path
    page.current_path.should match(expected)
    visit previous_location
  end
end

World(PathHelper)
