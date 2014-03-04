class Frontend::ReleaseAnnouncementProvider
  def self.all
    release_announcement_hashes = rummager_api.release_announcements
    build_from_hashes(release_announcement_hashes)
  end

private
  def self.build_from_hash(release_announcement_hash)
    Frontend::ReleaseAnnouncement.new(release_announcement_hash)
  end

  def self.build_from_hashes(release_announcement_hashes)
    release_announcement_hashes.map { | release_announcement_hash | build_from_hash(release_announcement_hash) }
  end

  def self.rummager_api
    Frontend::ReleaseAnnouncementRummagerStub
  end
end

class Frontend::ReleaseAnnouncementRummagerStub
  def self.release_announcements
    [
      {
        "title" => '2055 beard lengths',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2055-05-01 12:00:00"),
        "release_date_text" => 'May - June 2055',
        "organisations" => ["Ministry of beards"]
      },
      {
        "title" => 'Womble population in Wimbledon Common 2063',
        "document_type" => 'Statistics',
        "release_date" => Time.zone.parse("2063-02-15 12:45:00"),
        "release_date_text" => nil,
        "organisations" => ["Wombat population regulation authority"]
      }
    ]
  end
end
