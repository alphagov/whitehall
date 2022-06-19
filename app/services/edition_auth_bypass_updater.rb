class EditionAuthBypassUpdater
  attr_reader :edition, :current_user, :updater

  def initialize(edition:, current_user:, updater:)
    @edition = edition
    @current_user = current_user
    @updater = updater
  end

  def call
    @edition.set_auth_bypass_id
    @edition.save_as(@current_user)
    @updater.perform!
  end
end
