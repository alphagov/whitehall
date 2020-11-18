module Whitehall::Authority::Rules
  StatisticsAnnouncementRules = Struct.new(:actor, :subject) do
    def can?(action)
      case action
      when :unpublish
        actor.gds_editor? || actor.managing_editor?
      else
        true
      end
    end
  end
end
