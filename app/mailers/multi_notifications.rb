class MultiNotifications < ApplicationMailer
  def self.consultation_deadline_upcoming(consultation, weeks_left:, mailer: MailNotifications)
    addresses = consultation.authors.pluck(:email).uniq
    addresses.map do |address|
      mailer.consultation_deadline_upcoming(consultation, weeks_left:, recipient_address: address)
    end
  end

  def self.consultation_deadline_passed(consultation, mailer: MailNotifications)
    addresses = consultation.authors.pluck(:email).uniq
    addresses.map do |address|
      mailer.consultation_deadline_passed(consultation, recipient_address: address)
    end
  end
end
