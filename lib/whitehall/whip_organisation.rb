module Whitehall
  class WhipOrganisation
    include ActiveRecordLikeInterface

    attr_accessor :id, :label

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    alias :name :label

    def self.find_by_slug(slug)
      all.find { |wo| wo.slug == slug }
    end

    WhipsHouseOfCommons = create(id: 1, label: "House of Commons")
    WhipsHouseofLords = create(id: 2, label: "House of Lords")
    JuniorLordsoftheTreasury = create(id: 3, label: "Junior Lords of the Treasury")
    AssistantWhips = create(id: 4, label: "Assistant Whips")
    BaronessAndLordsInWaiting = create(id: 5, label: "Baroness and Lords in Waiting")
  end
end
