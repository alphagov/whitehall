module Whitehall::Authority::Rules
  MiscellaneousRules = Struct.new(:actor, :subject) do
    def can?(action)
      if respond_to?("can_for_#{subject}?")
        __send__("can_for_#{subject}?", action)
      else
        false
      end
    end

    def can_for_republish_content?(_action)
      actor.gds_admin?
    end

    def can_for_retag_content?(_action)
      actor.gds_admin?
    end

    def can_for_emergency_banner?(_action)
      actor.gds_admin?
    end

    def can_for_get_involved_section?(_action)
      actor.gds_editor?
    end

    def can_for_sitewide_settings_section?(_action)
      actor.gds_editor?
    end
  end
end
