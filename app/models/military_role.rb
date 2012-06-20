class MilitaryRole < Role
  def permanent_secretary
    false
  end

  def permanent_secretary?
    permanent_secretary
  end

  def cabinet_member
    false
  end

  def cabinet_member?
    cabinet_member
  end
end