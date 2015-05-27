module DataHygiene
  class EditionUnarchiver
    attr_reader :edition, :user, :logger

    GDS_INSIDE_GOV_USER_ID = 406

    def initialize(edition_id, logger=Rails.logger)
      @edition = Edition.find(edition_id)
      raise "Cannot unarchive an edition with state '#{@edition.state}'" unless @edition.withdrawn?
      @user = User.find(GDS_INSIDE_GOV_USER_ID)
      @logger = logger
    end

    def unarchive
      Edition.transaction do
        # The archived edition have state 'published' to create a draft.
        edition.update_attribute(:state, :published)
        edition.reload
        draft = edition.create_draft(user)
        draft.minor_change = true
        draft.editorial_remarks << EditorialRemark.create(author: @user, edition: @edition, body: "Unarchived")

        Edition::AuditTrail.acting_as(user) do
          EditionForcePublisher.new(draft).perform!
        end

        draft.reload
        logger.info("Unarchived Edition #{edition.id}, this has now been superseded.")
        logger.info("Created and published draft #{draft.id}.")
        draft
      end
    end
  end
end
