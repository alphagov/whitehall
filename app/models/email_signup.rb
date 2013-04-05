class EmailSignup
  # pull in enough of active model to be able to use this in a form
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def persisted?
    false
  end
end
