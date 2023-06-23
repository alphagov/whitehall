class ConsultationPublicFeedback < ConsultationResponse
  def singular_routing_symbol
    :public_feedback
  end

  def friendly_name
    "public feedback"
  end
end
