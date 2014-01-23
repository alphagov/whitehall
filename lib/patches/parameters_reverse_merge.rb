# Calling #reverse_merge on an ActionController::Parameters object builds a new
# object which doesn't have the same value for the permitted instance variable.
# This monkey patches #reverse_merge to set the value of permitted to match the
# original, on the basis that if you're reverse_merging into an already
# permitted hash you are probably happy with the new keys
class ActionController::Parameters
  def reverse_merge(other_hash)
    super.tap do |hash|
      hash.permitted = permitted
    end
  end
end
