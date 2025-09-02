require "addressable/uri"

class InternalPathLinksValidator < ActiveModel::Validator
  def validate(record)
    matches(record.body, /\[.*?\]\((\S*?)(?:\s+"[^"]+")?\)/) do |match|
      link = match[1]

      fix = if link.start_with?("//")
              # Collapse //, ///, //// etc down to a single leading slash for the suggestion
              suggestion = "/#{link.gsub(/\A\/+/, '')}"
              "This is an invalid admin link. Did you mean #{suggestion} instead of #{link}?"
            elsif self.class.is_internal_admin_link?("/#{link}")
              "This is an invalid admin link. Did you mean /#{link} instead of #{link}?"
            end

      record.errors.add(:base, "Issue with 'admin path' link `#{link}`: #{fix}") if fix
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
