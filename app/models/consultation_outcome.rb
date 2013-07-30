class ConsultationOutcome < Response
  def singular_routing_symbol
    :outcome
  end

  def friendly_name
    'outcome'
  end

  def allows_attachment_references?
    true
  end

  def can_have_attached_house_of_commons_papers?
    true
  end
end
