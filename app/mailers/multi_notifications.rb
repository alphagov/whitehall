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

  def self.call_for_evidence_reminder(call_for_evidence, mailer: MailNotifications)
    addresses = call_for_evidence.authors.pluck(:email).uniq
    addresses.map do |address|
      mailer.call_for_evidence_reminder(call_for_evidence, recipient_address: address)
    end
  end
end
