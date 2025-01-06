class Document::PaginatedTimeline::VersionDecorator < SimpleDelegator
  def initialize(version, is_first_edition: false, previous_version: nil)
    @is_first_edition = is_first_edition
    @preloaded_previous_version = previous_version
    super(version)
  end

  def ==(other)
    self.class == other.class &&
      id == other.id &&
      action == other.action
  end

  def actor
    user
  end

  def action
    case event
    when "create"
      @is_first_edition ? "created" : "editioned"
    else
      previous_version&.state != state ? state : "updated"
    end
  end

  def is_for_newer_edition?(edition)
    item_id > edition.id
  end

  def is_for_current_edition?(edition)
    item_id == edition.id
  end

  def is_for_older_edition?(edition)
    item_id < edition.id
  end

private

  def previous_version
    # we can avoid n+1 queries by using our preloaded_prev_version
    @previous_version ||= @preloaded_previous_version || previous
  end
end
