module Admin::StatisticsAnnouncementsHelper

  def organisations_list(organisations)
    content_tag(:ul,
      raw(organisations.map { |organisation| content_tag(:li, organisation.name) }.join("\n")))
  end

end
