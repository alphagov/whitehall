module Whitehall::Authority::Rules
  class ObjectRules
    def initialize(_actor, _subject); end

    def can?(_action); false; end
  end
end
