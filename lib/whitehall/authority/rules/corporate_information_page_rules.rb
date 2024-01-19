module Whitehall::Authority::Rules
  CorporateInformationPageRules = Struct.new(:actor, :subject) do
    def can?(_action)
      return true unless !subject.is_a?(Class) && subject.editionable_worldwide_organisation.present?

      Flipflop.editionable_worldwide_organisations?
    end
  end
end
