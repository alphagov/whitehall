module Whitehall::Authority::Rules
  class MiscellaneousRules < Struct.new(:actor, :subject)
    def can?(action)
      if respond_to?("can_for_#{subject}?")
        __send__("can_for_#{subject}?", action)
      else
        false
      end
    end
    def can_for_get_involved_section?(action)
      actor.gds_editor?
    end
  end
end
