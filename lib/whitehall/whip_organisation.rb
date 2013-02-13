module Whitehall
  class WhipOrganisation
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :selection_criteria

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    alias :name :label

    def self.find_by_slug(slug)
      all.find { |wo| wo.slug == slug }
    end

    def self.whip_org_for_role(role)
      all.select{|wo| wo.selection_criteria.match(role.name) }
    end

    def self.role_is_a_whip?(role)
      whip_org_for_role(role).any?
    end

    WHIPSHOUSEOFCOMMONS = Regexp.new(
      [
        /^Chief Whip and Parliamentary Secretary to the Treasury/,
        /^Deputy Chief Whip, Comptroller of HM Household/,
        /^Deputy Chief Whip, Treasurer of HM Household/,
        /^Government Whip, Vice Chamberlain of HM Household/,
      ].join("|")
    )
    WHIPSHOUSEOFLORDS = Regexp.new(
      [
        /^Government Deputy Chief Whip and Captain of the Queen's Bodyguard of the Yeomen of the Guard/,
        /^Lords Chief Whip and Captain of the Honourable Corps of Gentlemen at Arms/
      ].join("|"))
    JUNIORLORDSOFTHETREASURY = /^Government Whip, Lord Commissioner of HM Treasury/
    ASSISTANTWHIPS = /^Assistant Whip/
    BARONESSANDLORDSINWAITING = Regexp.new(
      [
        /^Government Whip, Baroness in Waiting/,
        /^Government Whip, Lord in Waiting/
      ].join("|"))
    WhipsHouseOfCommons = create(id: 1, label: "Whips - House of Commons", selection_criteria: WHIPSHOUSEOFCOMMONS)
    WhipsHouseofLords = create(id: 2, label: "Whips - House of Lords", selection_criteria: WHIPSHOUSEOFLORDS)
    JuniorLordsoftheTreasury = create(id: 3, label: "Junior Lords of the Treasury", selection_criteria: JUNIORLORDSOFTHETREASURY)
    AssistantWhips = create(id: 4, label: "Assistant Whips", selection_criteria: ASSISTANTWHIPS)
    BaronessAndLordsInWaiting = create(id: 5, label: "Baroness and Lords in Waiting", selection_criteria: BARONESSANDLORDSINWAITING)
  end
end
