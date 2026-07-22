class EditionAuthBypassRevoker
  attr_reader :edition, :current_user, :updater

  def initialize(edition:, current_user:, updater:)
    @edition = edition
    @current_user = current_user
    @updater = updater
  end

  def call
    @edition.auth_bypass_id = nil
    @edition.save_as(@current_user)
    @updater.perform!

    EditionAuthBypassAssetPropagator.new(@edition).propagate
  end
end
