class AccessLimitationSerializer < ActiveModel::Serializer
  attribute :access_limited, if: -> { access_limited? }

  def access_limited
    users = User.where(organisation: object.organisations)

    { users: users.map(&:uid).compact }
  end

private

  def access_limited?
    object.access_limited? && !object.publicly_visible?
  end
end
