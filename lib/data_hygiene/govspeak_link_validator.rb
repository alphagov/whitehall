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
                  "If you are linking to a document created within Whitehall publisher, please use the internal admin path, e.g. /government/admin/publications/3373. If you are linking to other GOV.UK links, please use full URLs."
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
