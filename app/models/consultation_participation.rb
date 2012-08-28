class ConsultationParticipation < ActiveRecord::Base
  validates :link_url, format: URI::regexp(%w(http https)), allow_blank: true
end
