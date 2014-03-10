module ServiceListeners
  AnnouncementClearer = Struct.new(:edition) do
    def clear!
      if announced_statistics?
        Searchable::Delete.later(release_announcement)
      end
    end

    def announced_statistics?
      edition.is_a?(Publication) && release_announcement.present?
    end

    def release_announcement
      edition.statistical_release_announcement
    end
  end
end
