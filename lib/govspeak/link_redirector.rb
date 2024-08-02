module Govspeak
  class LinkRedirector
    def initialize(input, domain, redirect_url)
      raise "domain must be at least 6 characters long (#{domain})" if domain.length < 6
      raise "domain must include a '.' (#{domain})" unless domain.include?(".")
      raise "redirect_url must start with https://" unless redirect_url.start_with?("https://")

      markdown_pattern = <<~'PATTERN'
        (                              # start a capturing group to cover the whole pattern
        (                              # start a capturing group to cover the first part of the pattern - everything up to the URL we're replacing
        \[                             # a literal open square bracket - the start of a markdown link
        [^\]]+                         # anything except square brackets - the link text of the markdown link
        \]                             # a close square bracket - the end of the link text section of the markdown link
        \(                             # an open round bracket - the start of the URL bit of the markdown link
        )                              # close the first capturing group - next bit is the URL we're going to replace
        (?:https?://)?                 # optionally, the protocol of the URL
        DOMAIN                         # the domain we're looking for, escaped for a Regexp so we don't confuse . characters
        [^)]*                          # anything except round brackets to capture the remainder of the link
        (                              # open a second capturing group to capture everything after the URL we're replacing
        \)                             # closing round bracket - the end of a markdown link
        )                              # close the second capturing group
        )                              # finally, close the outer capturing group
      PATTERN
      markdown_pattern.sub!("DOMAIN", Regexp.escape(domain))
      @markdown_pattern = /#{markdown_pattern}/x

      html_pattern = <<~'PATTERN'
        (                              # start a capturing group to cover the whole pattern
        (                              # start a capturing group to cover the first part of the pattern - everything up to the URL we're replacing
        <a                             # start of an HTML opening tag
        [^>]*                          # anything except the > which closes the opening tag
        href="                         # the href attribute
        )                              # close the first capturing group - next bit is the URL we're going to replace
        (?:https?://)?                 # optionally, the protocol of the URL
        DOMAIN                         # the domain we're looking for, escaped for a Regexp so we don't confuse . characters
        [^"]*                          # anything except double quotes
        (                              # open a second capturing group to capture everything after the URL we're replacing
        "                              # a double quote to get us to the end of the attribute
        [^>]*>                         # anything except closing angle bracket, and then a closing angle bracket to get us to the end of the opening tag
        ([^<]*)                        # anything except opening angle bracket in a capturing group - the link text of the HTML link
        </a>                           # the closing tag
        )                              # close the second capturing group
        )                              # finally, close the outer capturing group
      PATTERN
      html_pattern.sub!("DOMAIN", Regexp.escape(domain))
      @html_pattern = /#{html_pattern}/x

      @input = input
      @domain = domain
      @redirect_url = redirect_url
    end

    def match?
      @markdown_pattern.match?(@input) || @html_pattern.match?(@input)
    end

    def describe_replacements
      all_matches.map { |match| "- will replace '#{match[0]}' with '#{match[1] + @redirect_url + match[2]}'" }.join("\n")
    end

    def redirect_links_for_domain
      @input
        .gsub(@markdown_pattern) { Regexp.last_match[2] + @redirect_url + Regexp.last_match[3] }
        .gsub(@html_pattern) { Regexp.last_match[2] + @redirect_url + Regexp.last_match[3] }
    end

  private

    def all_matches
      @input.to_enum(:scan, @markdown_pattern) { Regexp.last_match } +
        @input.to_enum(:scan, @html_pattern) { Regexp.last_match }
    end
  end
end
