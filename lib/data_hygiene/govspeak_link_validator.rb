require "addressable/uri"

module DataHygiene
  class GovspeakLinkValidator
    def initialize(string)
      @string = string
    end

    def errors
      matches(/\[.*?\]\((\S*?)(?:\s+"[^"]+")?\)/) do |match|
        link = match[1]

        fix = if link.first == "/"
                unless self.class.is_internal_admin_link?(link)
                  "Please use either absolute paths for documents created in publisher, e.g. /government/admin/publications/3373, or full URLs for other GOV.UK links"
                end
              elsif self.class.is_internal_admin_link?("/#{link}")
                "This is an invalid admin link.  Did you mean /#{link} instead of #{link}?"
              elsif !%r{^(?:https?://|mailto:|#)}.match?(link)
                "Non-document or external links should start with http://, https://, mailto:, or # (for linking to sections on the same page, eg #actions on a policy)"
              elsif link.match?(/whitehall-admin/)
                "This links to the whitehall-admin domain. Please use paths, eg /government/admin/publications/3373, for documents created in publisher (see guidance on creating links) or full URLs for other GOV.UK links."
              end

        { link:, start: match.begin(0), end: match.end(0), fix: } if fix
      end
    end

    def errors_to_html
      output = "<p>This edition contains links which violate linking guidelines</p>"
      errors.each do |error|
        output << (
          "<p class='govuk-!-margin-top-4 govuk-!-margin-bottom-2'>Link: <a href='#{error[:link]}' class='govuk-link'>#{error[:link]}</a></p>" \
          "<p>Fix: #{error[:fix]}</p>"
        )
      end

      output
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

    def matches(regex)
      start_at = 0
      matches = []

      return matches if @string.nil?

      while (match = @string.match(regex, start_at))
        error = yield(match)
        matches << error if error
        start_at = match.end(0)
      end

      matches
    end
  end
end
