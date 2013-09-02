# == Schema Information
#
# Table name: responses
#
#  id           :integer          not null, primary key
#  edition_id   :integer
#  summary      :text
#  created_at   :datetime
#  updated_at   :datetime
#  published_on :date
#  type         :string(255)
#

class ConsultationPublicFeedback < Response
  def singular_routing_symbol
    :public_feedback
  end

  def friendly_name
    'public feedback'
  end
end
