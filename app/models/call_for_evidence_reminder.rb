class CallForEvidenceReminder
  WEEKS_FROM_CLOSE_TO_REMINDER = 8

  class << self
    def send_reminder
      CallForEvidence.awaiting_response.closed_at_or_within_24_hours_of(WEEKS_FROM_CLOSE_TO_REMINDER.weeks.ago).each do |call_for_evidence|
        log(call_for_evidence)
        MultiNotifications.call_for_evidence_reminder(call_for_evidence).map(&:deliver_now)
      end
    end

  private

    def log(call_for_evidence)
      Rails.logger.info("Sending reminder for call for evidence ##{call_for_evidence.id} '#{call_for_evidence.title}' to #{obfuscated_email_addresses(call_for_evidence)}")
    end

    def obfuscated_email_addresses(call_for_evidence)
      call_for_evidence.authors.uniq.map { |author|
        author.email.gsub(/^(.{2}).*(.{2})$/, '\1*****\2')
      }.to_sentence
    end
  end
end
