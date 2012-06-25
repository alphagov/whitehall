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
      "board_member" => RoleType.new(BoardMemberRole.name, false, false, false)
    },
    "Military" => {
      "chief_of_the_defence_staff" => RoleType.new(MilitaryRole.name, false, false, true),
      "chief_of_staff" => RoleType.new(MilitaryRole.name, false, false, false)
    }
  }.freeze

  NAMES_VS_TYPES = RoleTypePresenter::GROUPS_VS_NAMES_VS_TYPES.values.inject(:merge)

  DEFAULT_NAME, DEFAULT_TYPE = NAMES_VS_TYPES.first

  class << self
    def options
      GROUPS_VS_NAMES_VS_TYPES.collect do |group, names_vs_types|
        [group, names_vs_types.collect { |name, type| [name.humanize, name] }]
      end
    end

    def option_value_for(role, role_type)
      role_type = RoleType.new(role_type, role.cabinet_member?, role.permanent_secretary?, role.chief_of_the_defence_staff?)
      NAMES_VS_TYPES.invert[role_type] || DEFAULT_NAME
    end

    def role_attributes_from(params)
      role_type = NAMES_VS_TYPES[params[:type]] || DEFAULT_TYPE
      params.merge(role_type.attributes)
    end
  end
end
