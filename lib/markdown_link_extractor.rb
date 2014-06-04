class MarkdownLinkExtractor
  def initialize(markdown)
    @markdown = markdown
  end

  def links
    @links ||= extract_links
  end

private

  def extract_links
    Nokogiri::HTML.parse(html_from_markdown).css('a').map { |link| link['href'] }
  end

  def html_from_markdown
    Govspeak::Document.new(@markdown).to_html
  end
end
