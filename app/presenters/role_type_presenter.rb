class RoleTypePresenter

  class RoleType < Struct.new(:type, :cabinet_member, :permanent_secretary, :chief_of_the_defence_staff)
    def attributes
      { type: type,
        cabinet_member: cabinet_member,
        permanent_secretary: permanent_secretary,
        chief_of_the_defence_staff: chief_of_the_defence_staff }
    end
  end

  GROUPS_VS_NAMES_VS_TYPES = {
    "Ministerial" => {
      "cabinet_minister" => RoleType.new(MinisterialRole.name, true, false, false),
      "minister" => RoleType.new(MinisterialRole.name, false, false, false)
    },
    "Managerial" => {
      "permanent_secretary" => RoleType.new(BoardMemberRole.name, false, true, false),
      "board_level_manager" => RoleType.new(BoardMemberRole.name, false, false, false),
      "chief_scientific_advisor" => RoleType.new(ChiefScientificAdvisorRole.name, false, false, false)
    },
    "DFT only" => {
      "traffic_commissioner" => RoleType.new(TrafficCommissionerRole.name, false, false, false),
    },
    "MOD only" => {
      "chief_of_the_defence_staff" => RoleType.new(MilitaryRole.name, false, false, true),
      "chief_of_staff" => RoleType.new(MilitaryRole.name, false, false, false)
    },
    "FCO only" => {
      "special_representative" => RoleType.new(SpecialRepresentativeRole.name, false, false, false)
    },
    "DH only" => {
      "chief_professional_officer" => RoleType.new(ChiefProfessionalOfficerRole.name, false, false, false),
    },
    "Worldwide orgs only" => {
      "ambassador" => RoleType.new(AmbassadorRole.name, false, false, false),
      "high_commissioner" => RoleType.new(HighCommissionerRole.name, false, false, false),
      "governor" => RoleType.new(GovernorRole.name, false, false, false),
      "deputy_head_of_mission" => RoleType.new(DeputyHeadOfMissionRole.name, false, false, false),
      "worldwide_office_staff" => RoleType.new(WorldwideOfficeStaffRole.name, false, false, false)
    }
  }.freeze

  NAMES_VS_TYPES = RoleTypePresenter::GROUPS_VS_NAMES_VS_TYPES.values.reduce(:merge)

  DEFAULT_NAME, DEFAULT_TYPE = NAMES_VS_TYPES.first

  def self.options
    GROUPS_VS_NAMES_VS_TYPES.map do |group, names_vs_types|
      [group, names_vs_types.map { |name, type| [name.humanize, name] }]
    end
  end

  def self.option_value_for(role, role_type)
    role_type = RoleType.new(role_type, role.cabinet_member?, role.permanent_secretary?, role.chief_of_the_defence_staff?)
    NAMES_VS_TYPES.invert[role_type] || DEFAULT_NAME
  end

  def self.role_attributes_from(params)
    role_type = NAMES_VS_TYPES[params[:type]] || DEFAULT_TYPE
    params.merge(role_type.attributes)
  end
end
