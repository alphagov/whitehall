module Admin::OffsiteLinksHelper
  def offsite_link_date_enabled?(parent)
    parent.is_a?(Organisation) || parent.is_a?(WorldLocationNews)
  end
end
