module TextHelper
  def with_this_determiner(string)
    string == string.singularize ? "this #{string}" : "these #{string}"
  end
end
