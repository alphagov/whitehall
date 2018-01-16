module Whitehall::Authority::Rules
  MiscellaneousRules = Struct.new(:actor, :subject) do
    def can?(action)
      if respond_to?("can_for_#{subject}?")
        __send__("can_for_#{subject}?", action)
      else
        false
      end
    end

    def can_for_get_involved_section?(_)
      actor.gds_editor?
    end

    def can_for_sitewide_settings_section?(_)
      actor.gds_editor?
    end
  end
end
