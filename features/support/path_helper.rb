module PathHelper
  def ensure_path(path)
    unless current_path == path
      visit path
    end
  end
end

World(PathHelper)
