class ConsultationParticipation < ActiveRecord::Base
  validates :link_url, format: URI::regexp(%w(http https)), allow_blank: true
  validates :email, email_format: { allow_blank: true }

  def has_link?
    link_url.present? && link_text.present?
  end

  def has_email?
    email.present?
  end
end
