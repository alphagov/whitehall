class ConsultationParticipation < ActiveRecord::Base
  belongs_to :consultation_response_form
  accepts_nested_attributes_for :consultation_response_form,
                                reject_if: :all_blank,
                                allow_destroy: true

  validates :link_url, format: URI::regexp(%w(http https)), allow_blank: true
  validates :email, email_format: { allow_blank: true }

  def has_link?
    link_url.present? && link_text.present?
  end

  def has_email?
    email.present?
  end


  after_destroy :destroy_form_if_required

  private

  def destroy_form_if_required
    if consultation_response_form.present? &&
      self.class.where(consultation_response_form_id: consultation_response_form.id).empty?
      consultation_response_form.destroy
    end
  end
end
