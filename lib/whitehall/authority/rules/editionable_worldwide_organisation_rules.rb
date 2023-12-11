module Whitehall::Authority::Rules
  EditionableWorldwideOrganisationRules = Struct.new(:actor, :subject) do
    def can?(_action)
      Flipflop.editionable_worldwide_organisations?
    end
  end
end
