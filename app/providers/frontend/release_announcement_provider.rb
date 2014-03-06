module Frontend
  class ReleaseAnnouncementProvider
    def self.find_by(filter_params = {})
      release_announcement_hashes = rummager_api.release_announcements(filter_params)
      build_collection(release_announcement_hashes)
    end

  private
    def self.build_collection(release_announcement_hashes)
      Array(release_announcement_hashes).map { | release_announcement_hash | Frontend::ReleaseAnnouncement.new(release_announcement_hash) }
    end

    def self.rummager_api
      Frontend::ReleaseAnnouncementRummagerStub
    end
  end

  class ReleaseAnnouncementRummagerStub
    RELEASE_ANNOUNCEMENTS = [
      {
        "title" => '2055 beard lengths',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2055-05-01 12:00:00"),
        "release_date_text" => 'May - June 2055',
        "organisations" => [ { "name" => "Ministry of beards", "slug" => "ministry-of-breards" } ]
      },
      {
        "title" => 'Womble population in Wimbledon Common 2063',
        "document_type" => 'Statistics',
        "release_date" => Time.zone.parse("2063-02-15 12:45:00"),
        "release_date_text" => nil,
        "organisations" => [ { "name" => "Wombat population regulation authority", "slug" => "wombat-population-regulation-authority" } ]
      }
    ]

    def self.release_announcements(search_params = {})
      filtered_announcements = RELEASE_ANNOUNCEMENTS.dup
      if search_params[:keywords].present?
        filtered_announcements.select! {|announcement| announcement['title'].include? search_params[:keywords] }
      end
      if search_params[:from_date].present?
        filtered_announcements.select! {|announcement| announcement['release_date'].to_date >= search_params[:from_date] }
      end
      if search_params[:to_date].present?
        filtered_announcements.select! {|announcement| announcement['release_date'].to_date <= search_params[:to_date] }
      end
      filtered_announcements
    end
  end
end
