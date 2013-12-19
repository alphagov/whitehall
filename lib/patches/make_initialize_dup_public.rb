# Because initialize_dup is private in Ruby 2, we need to make it public again
# so that we can reset errors in the Edition#errors_as_draft method.
module ActiveModel
  class Errors
    public :initialize_dup
  end
end
