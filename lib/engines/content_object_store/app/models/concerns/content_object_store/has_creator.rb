module ContentObjectStore
  module HasCreator
    extend ActiveSupport::Concern

    included do
      validates :creator, presence: true
    end

    def creator
      edition_authors.first&.user
    end

    def creator=(user)
      if new_record?
        edition_author = edition_authors.first || edition_authors.build
        edition_author.user = user
      else
        raise "author can only be set on new records"
      end
    end
  end
end
