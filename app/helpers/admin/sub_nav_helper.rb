module Admin::SubNavHelper
  def sub_nav_item(name, path)
    {
      label: name,
      href: path,
      current: request.path.start_with?(path),
    }
  end
end
