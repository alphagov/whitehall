class Admin::Editions::HistoryModeFormControls < ViewComponent::Base
  def initialize(edition, current_user)
    @edition = edition
    @enforcer = Whitehall::Authority::Enforcer.new(current_user, edition)
  end

  def render?
    @edition.document&.live? && @edition.can_be_marked_political? && @enforcer.can?(:mark_political)
  end

  def renders_government_selector?
    Flipflop.override_government? && @enforcer.can?(:select_government_for_history_mode)
  end

  # noinspection RubyMismatchedArgumentType
  def options
    [
      {
        text: "Associate with default government",
        value: "",
      },
    ].tap do |options|
      Government.newest_first.find_each do |government|
        options << {
          text: government.name,
          value: government.id,
          selected: government.id == @edition.government_id,
        }
      end
    end
  end
end
