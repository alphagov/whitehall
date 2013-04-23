module HistoricAppointmentsHelper
  def historical_fact(title, text)
    return if text.blank?
    content_tag(:h3, title) + content_tag(:p, text)
  end
end
