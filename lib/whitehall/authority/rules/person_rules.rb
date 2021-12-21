module Whitehall::Authority::Rules
  PersonRules = Struct.new(:actor, :subject) do
    def can?(_action)
      if subject.slug == "boris-johnson"
        actor.vip_editor? || actor.gds_admin?
      else
        true
      end
    end
  end
end
