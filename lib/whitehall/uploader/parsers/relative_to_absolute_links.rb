class Whitehall::Uploader::Parsers::RelativeToAbsoluteLinks
  def self.parse(body_text, organisation_url)
    body_text && body_text.gsub(%r{\[([^\]]*)\]\((/[^)]*)\)}, "[\\1](#{organisation_url}\\2)")
  end
end
