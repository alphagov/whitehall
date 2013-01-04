module ConsultationHelper
  def select_most_recent_consultation_from_list
    click_link(Consultation.last.title)
  end

  def view_visible_consultation_on_website
    click_link("View")
  end

  def should_have_consultation_response_attachment
    assert has_css?(".consultation-responded .attachment", count: 1)
  end

  def should_have_consultation_response_attachment_with_published_date(date)
    assert has_css?(".consultation-responded .attachment abbr.date[title='#{date}']")
  end
end

World(ConsultationHelper)
