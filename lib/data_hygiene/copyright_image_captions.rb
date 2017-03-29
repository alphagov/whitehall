# encoding: UTF-8

require "csv"

module DataHygiene
  class CopyrightImageCaptions
    def initialize(scope: nil, dry_run: true)
      scope ||= FatalityNotice.published

      @images = scope.joins(:images).includes(:images).map(&:images).flatten
      @dry_run = dry_run
    end

    def run!
      Image.transaction do
        csv = CSV.open("fatality_notices.csv", "w",
                       col_sep: ",", force_quotes: true) do |csv|
          csv << ["url", "alt text", "old caption", "new caption"]
          @images.each do |image|
            old_caption = image.caption
            sanitize_caption(image)
            csv << [
              "https://gov.uk#{image.edition.search_link}",
              image.alt_text,
              old_caption,
              image.caption
            ]
            if !@dry_run && image.changed.include?("caption")
              image.update_attribute(:caption, image.caption)
            end
          end
        end
      end
    end

    def sanitize_caption(image)
      if image.caption =~ /all rights reserved|copyright|©/i ||
         image.alt_text =~ /MOD (Announcement|crest)|Ministry of Defence|army/i
        return image
      else
        image.caption = "#{image.caption.strip}\n© All rights reserved"
        return image
      end
    end
  end
end
