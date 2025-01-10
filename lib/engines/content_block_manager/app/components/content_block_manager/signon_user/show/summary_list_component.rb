class ContentBlockManager::SignonUser::Show::SummaryListComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

private

  def items
    [
      name_item,
      email_item,
      organisation_item,
    ].compact
  end

  def name_item
    {
      field: "Name",
      value: @user.name,
    }
  end

  def email_item
    {
      field: "Email",
      value: @user.email,
    }
  end

  def organisation_item
    {
      field: "Organisation",
      value: @user.organisation.name,
    }
  end
end
