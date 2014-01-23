# This can be removed once we've got a version of the GDS SSO gem that doesn't
# call attr_accessible for our user model
module AttrAccessibleNoop
  def attr_accessible(*args)
    # noop
  end
end
