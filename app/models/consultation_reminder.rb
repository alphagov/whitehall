class ConsultationReminder
  # Authors must publish a response within 12 weeks of the consultation closing.
  PUBLISH_DEADLINE = 12

  class << self
    def send_all
      send_deadline_reminder(weeks_left: 4)
      send_deadline_reminder(weeks_left: 1)
      send_deadline_passed_notification
    end

  private

    def send_deadline_reminder(weeks_left:)
      Consultation.awaiting_response.closed_on((PUBLISH_DEADLINE - weeks_left).weeks.ago.to_date).each do |consultation|
        log(consultation)
        Notifications.consultation_deadline_upcoming(consultation, weeks_left: weeks_left).deliver_now
      end
    end

    def send_deadline_passed_notification
      Consultation.awaiting_response.closed_on((PUBLISH_DEADLINE.weeks + 1.day).ago.to_date).each do |consultation|
        log(consultation)
        Notifications.consultation_deadline_passed(consultation).deliver_now
      end
    end

    def log(consultation)
      Rails.logger.info("Sending reminder for consultation ##{consultation.id} '#{consultation.title}' to #{obfuscated_email_addresses(consultation)}")
    end

    def obfuscated_email_addresses(consultation)
      consultation.authors.uniq.map { |author|
        author.email.gsub(/^(.{2}).*(.{2})$/, '\1*****\2')
      }.to_sentence
    end
  end
end
