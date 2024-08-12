class Admin::Editions::HistoryModeFormControl < ViewComponent::Base
  def initialize(edition:, current_user:)
    @edition = edition
    @enforcer = Whitehall::Authority::Enforcer.new(current_user, edition)
  end

  def render?
    @edition.document.live? && @edition.can_be_marked_political? && @enforcer.can?(:mark_political)
  end

  def can_select_government?
    @enforcer.can?(:select_government)
  end

  def government_options_for_select
    [
      {
        text: "Not associated with any government",
        value: "",
      },
    ].concat(
      Government.order(start_date: :desc).all.map { |government| { text: government.name, value: government.id, selected: government == @edition.government } },
    )
  end
end
