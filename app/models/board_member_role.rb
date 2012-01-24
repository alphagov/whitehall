class BoardMemberRole < Role
  def cabinet_member
    false
  end
  def cabinet_member?
    cabinet_member
  end
end
