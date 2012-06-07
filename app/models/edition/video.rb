module Edition::Video
  extend ActiveSupport::Concern

  included do
    class VideoUrlValidator < ActiveModel::Validator
      def validate(record)
        return if record.video_url.blank?
        matches = URI::regexp(%w(http https)).match(record.video_url)
        if matches.present?
          host, path, query = matches[4], matches[7], matches[8]
          unless (host == "www.youtube.com") && (path == "/watch") && query[%r{v=\w+}]
            record.errors.add(:video_url, "is not a YouTube video URL")
          end
        else
          record.errors.add(:video_url, "is invalid")
        end
      end
    end

    validates_with VideoUrlValidator
  end
end


