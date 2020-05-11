module Whitehall
  class WhipOrganisation
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :sort_order

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    alias_method :name, :label

    def self.find_by_slug(slug)
      all.detect { |wo| wo.slug == slug }
    end

    WhipsHouseOfCommons = create(id: 1, label: "House of Commons", sort_order: 1)
    WhipsHouseofLords = create(id: 2, label: "House of Lords", sort_order: 4)
    JuniorLordsoftheTreasury = create(id: 3, label: "Junior Lords of the Treasury", sort_order: 2)
    AssistantWhips = create(id: 4, label: "Assistant Whips", sort_order: 3)
    BaronessAndLordsInWaiting = create(id: 5, label: "Baronesses and Lords in Waiting", sort_order: 5)
  end
end
