class RoleTypePresenter

  class RoleType < Struct.new(:type, :cabinet_member, :permanent_secretary)
    def attributes
      { type: type, cabinet_member: cabinet_member, permanent_secretary: permanent_secretary }
    end
  end

  NAMES_VS_TYPES = {
    "cabinet_minister" => RoleType.new(MinisterialRole.name, true, false),
    "other_minister" => RoleType.new(MinisterialRole.name, false, false),
    "permanent_secretary" => RoleType.new(BoardMemberRole.name, false, true),
    "other_board_member" => RoleType.new(BoardMemberRole.name, false, false)
  }.freeze

  DEFAULT_NAME, DEFAULT_TYPE = NAMES_VS_TYPES.first

  class << self
    def options
      NAMES_VS_TYPES.keys.map { |type| [type, type.humanize] }
    end

    def option_value_for(role)
      role_type = RoleType.new(role.type, role.cabinet_member?, role.permanent_secretary?)
      NAMES_VS_TYPES.invert[role_type] || DEFAULT_NAME
    end

    def role_attributes_from(params)
      role_type = NAMES_VS_TYPES[params[:type]] || DEFAULT_TYPE
      params.merge(role_type.attributes)
    end
  end
end
