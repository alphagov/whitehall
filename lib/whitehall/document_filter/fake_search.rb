require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class FakeSearch < Filterer
    def announcements_search
      # Announcement.all
    end

    def publications_search
      # Publication.all
    end

    def documents
      @documents ||= Kaminari.paginate_array([]).page(@page).per(@per_page)
    end
  end
end
