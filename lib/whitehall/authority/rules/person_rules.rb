module Whitehall::Authority::Rules
  PersonRules = Struct.new(:actor, :subject) do
    def can?(action)
      if subject.slug == "boris-johnson"
        actor.vip_editor? || actor.gds_admin?
      elsif action == :perform_administrative_tasks
        actor.gds_admin?
      else
        true
      end
    end
  end
end
