class String
  # Returns the possessive form of a string.
  # For example, "Bill".possessive returns "Bill’s", whereas "Years".possessive
  # returns "Years’"
  def possessive
    return self if empty?

    if self.ends_with?("s")
      self + "’"
    else
      self + "’s"
    end
  end
end
