module Admin::GetInvolvedHelper
  def get_involved_tab_navigation(_section = nil)
    tab_navigation({
      "Get involved" => admin_get_involved_path,
      "Take part pages" => admin_take_part_pages_path
    })
  end
end
