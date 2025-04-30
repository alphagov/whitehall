module Whitehall::Authority::Rules
  SocialMediaAccountRules = Struct.new(:actor, :subject) do
    def can?(action)
      case action
      when :create
        actor.departmental_editor? || actor.managing_editor? || actor.gds_editor? || actor.gds_admin?
      when :update
        actor.departmental_editor? || actor.managing_editor? || actor.gds_editor? || actor.gds_admin?
      when :delete
        actor.departmental_editor? || actor.managing_editor? || actor.gds_editor? || actor.gds_admin?
      else
        false
      end
    end
  end
end
