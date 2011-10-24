module ConsultationsHelper
  def consultation_opening_phrase(consultation)
    if consultation.opening_on < Date.today
      "Opened on #{consultation.opening_on.to_s(:long_ordinal)}"
    else
      "Opens on #{consultation.opening_on.to_s(:long_ordinal)}"
    end
  end

  def consultation_closing_phrase(consultation)
    if consultation.closing_on < Date.today
      "Closed on #{consultation.closing_on.to_s(:long_ordinal)}"
    else
      "Closes on #{consultation.closing_on.to_s(:long_ordinal)}"
    end
  end
end