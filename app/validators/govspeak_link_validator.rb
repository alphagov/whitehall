require "addressable/uri"

class GovspeakLinkValidator < ActiveModel::Validator
  def validate(record)
    matches(record.body, /\[.*?\]\((\S*?)(?:\s+"[^"]+")?\)/) do |match|
      link = match[1]

      fix = if self.class.is_internal_admin_link?("/#{link}")
              "This is an invalid admin link.  Did you mean /#{link} instead of #{link}?"
            elsif !self.class.is_internal_admin_link?(link) && !%r{^(?:https?://|mailto:|#)}.match?(link)
              "Non-document or external links should start with http://, https://, mailto:, or # (for linking to sections on the same page, eg #actions on a policy)"
            elsif link.match?(/whitehall-admin/)
              "This links to the whitehall-admin domain. Please use paths, eg /government/admin/publications/3373, for documents created in publisher (see guidance on creating links) or full URLs for other GOV.UK links."
            end

      record.errors.add(:base, "Issue with link `#{link}`: #{fix}") if fix
    end
  end

  def self.is_internal_admin_link?(href)
    return false unless href.is_a? String

    begin
      href = Addressable::URI.parse(href)
      href.path.start_with?("#{Whitehall.router_prefix}/admin")
    rescue Addressable::URI::InvalidURIError
      false
    end
  end

protected

  def matches(string, regex)
    start_at = 0
    matches = []

    return matches if string.nil?

    while (match = string.match(regex, start_at))
      error = yield(match)
      matches << error if error
      start_at = match.end(0)
    end

    matches
  end
end
