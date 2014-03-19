module ServiceListeners
  AnnouncementClearer = Struct.new(:edition) do
    def clear!
      if announced_statistics?
        Searchable::Delete.later(statistics_announcement)
      end
    end

    def announced_statistics?
      edition.is_a?(Publication) && statistics_announcement.present?
    end

    def statistics_announcement
      edition.statistics_announcement
    end
  end
end
