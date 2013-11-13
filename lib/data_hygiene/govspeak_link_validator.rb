require 'addressable/uri'

module DataHygiene
  class GovspeakLinkValidator

    def initialize(string)
      @string = string
    end

    def errors
      matches(/\[.*?\]\((\S*?)(?:\s+"[^"]+")?\)/) do |match|
        link = match[1]

        fix = if link.first == '/'
          unless self.class.is_internal_admin_link?(link)
            'Please use either absolute paths for documents created in publisher, e.g. /government/admin/policies/3373, or full URLs for other GOV.UK links'
          end
        else
          if self.class.is_internal_admin_link?("/#{link}")
            "This is an invalid admin link.  Did you mean /#{link} instead of #{link}?"
          elsif link !~ %r{^(?:https?://|mailto:|#)}
            'Non-document or external links should start with http:// or https://'
          elsif link =~ /whitehall-admin/
            'This links to the whitehall-admin domain. Please use paths, eg /government/admin/policies/3373, for documents created in publisher (see guidance on creating links) or full URLs for other GOV.UK links.'
          end
        end

        {link: link, start: match.begin(0), end: match.end(0), fix: fix} if fix
      end
    end

    def self.is_internal_admin_link?(href)
      return false unless href.is_a? String

      begin
        href = Addressable::URI.parse(href)
        href.path.start_with?("#{Whitehall.router_prefix}/admin")
      rescue Addressable::URI::InvalidURIError
        return false
      end
    end

  protected

    def matches(regex)
      start_at = 0
      matches = []

      while (match = @string.match(regex, start_at))
        error = yield(match)
        matches << error if error
        start_at = match.end(0)
      end

      return matches
    end
  end
end
