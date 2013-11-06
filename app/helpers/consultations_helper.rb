module ConsultationsHelper
  def consultation_css_class(consultation)
    consultation_class = ''
    if consultation.outcome_published?
      consultation_class = 'consultation-responded'
    elsif consultation.closed?
      consultation_class = 'consultation-closed'
    elsif consultation.open?
      consultation_class = 'consultation-open'
    end
    "consultation #{consultation_class}"
  end
end
