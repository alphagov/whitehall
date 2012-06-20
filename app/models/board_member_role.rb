class BoardMemberRole < Role
  def cabinet_member
    false
  end

  def cabinet_member?
    cabinet_member
  end

  def chief_of_the_defence_staff
    false
  end

  def chief_of_the_defence_staff?
    chief_of_the_defence_staff
  end
end
