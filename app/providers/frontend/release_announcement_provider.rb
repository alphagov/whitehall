class Frontend::ReleaseAnnouncementProvider
  def self.all
    release_announcement_hashes = rummager_api.release_announcements
    release_announcement_hashes.map { | release_announcement_hash | build_from_hash(release_announcement_hash) }
  end

private
  def self.build_from_hash(release_announcement_hash)
    Frontend::ReleaseAnnouncement.new(release_announcement_hash)
  end

  def self.rummager_api
    Frontend::ReleaseAnnouncementRummagerStub
  end
end

class Frontend::ReleaseAnnouncementRummagerStub
  def self.release_announcements
    []
  end
end
