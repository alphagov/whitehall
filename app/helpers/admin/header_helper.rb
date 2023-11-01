module Admin::HeaderHelper
  def sub_nav_item(name, path)
    {
      label: name,
      href: path,
      current: request.path.start_with?(path),
    }
  end

  def main_nav_item(name, path)
    {
      text: name,
      href: path,
      active: request.path.end_with?(path),
    }
  end
end
