module Whitehall::Authority::Rules
  EditionableTopicalEventRules = Struct.new(:actor, :subject) do
    def can?(_action)
      Flipflop.editionable_topical_events?
    end
  end
end
