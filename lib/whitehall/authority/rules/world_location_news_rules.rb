module Whitehall::Authority::Rules
  WorldLocationNewsRules = Struct.new(:actor, :subject) do
    def can?(action)
      case action
      when :manage_features
        true
      else
        false
      end
    end
  end
end
