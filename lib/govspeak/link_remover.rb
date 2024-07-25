module Govspeak
  class LinkRemover
    def initialize(input, domain)
      raise "domain must be at least 6 characters long (#{domain})" if domain.length < 6
      raise "domain must include a '.' (#{domain})" unless domain.include?(".")

      markdown_pattern = <<~'PATTERN'
        (                              # start a capturing group to cover the whole pattern
        \[                             # a literal open square bracket - the start of a markdown link
        ([^\]]+)                       # anything except square brackets in a capturing group - the link text of the markdown link
        \]                             # a close square bracket - the end of the link text section of the markdown link
        \(                             # an open round bracket - the start of the URL bit of the markdown link
        (?:https?://)?                 # optionally, the protocol of the URL
        DOMAIN                         # the domain we're looking for, escaped for a Regexp so we don't confuse . characters
        [^)]*                          # anything except round brackets to capture the remainder of the link
        \)                             # closing round bracket - the end of a markdown link
        )                              # finally, close the capturing group
      PATTERN
      markdown_pattern.sub!("DOMAIN", Regexp.escape(domain))
      @markdown_pattern = /#{markdown_pattern}/x

      html_pattern = <<~'PATTERN'
        (                              # start a capturing group to cover the whole pattern
        <a                             # start of an HTML opening tag
        [^>]*                          # anything except the > which closes the opening tag
        href="                         # the href attribute
        (?:https?://)?                 # optionally, the protocol of the URL
        DOMAIN                         # the domain we're looking for, escaped for a Regexp so we don't confuse . characters
        [^"]*"                         # anything except double quotes, and then a double quote to get us to the end of the attribute
        [^>]*>                         # anything except closing angle bracket, and then a closing angle bracket to get us to the end of the opening tag
        ([^<]*)                        # anything except opening angle bracket in a capturing group - the link text of the HTML link
        </a>                           # the closing tag
        )                              # finally, close the capturing group
      PATTERN
      html_pattern.sub!("DOMAIN", Regexp.escape(domain))
      @html_pattern = /#{html_pattern}/x

      @input = input
      @domain = domain
    end

    def match?
      @markdown_pattern.match?(@input) || @html_pattern.match?(@input)
    end

    def describe_replacements
      all_matches.map { |match| "- will replace '#{match[0]}' with '#{match[1]}'" }.join("\n")
    end

    def remove_links_for_domain
      @input.gsub(@markdown_pattern, '\2').gsub(@html_pattern, '\2')
    end

  private

    def all_matches
      @input.scan(@markdown_pattern) + @input.scan(@html_pattern)
    end
  end
end
