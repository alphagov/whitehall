module ConsultationHelper
  def select_most_recent_consultation_from_list
    click_link(Consultation.last.title)
  end

  def view_visible_consultation_on_website
    click_link("View on website")
  end
end

World(ConsultationHelper)
