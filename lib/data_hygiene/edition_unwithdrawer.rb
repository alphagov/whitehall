module DataHygiene
  class EditionUnwithdrawer
    attr_reader :edition, :user, :logger

    GDS_INSIDE_GOV_USER_ID = 406

    def initialize(edition_id, logger = Rails.logger)
      @edition = Edition.find(edition_id)
      raise "Cannot unwithdraw an edition with state '#{@edition.state}'" unless @edition.withdrawn?
      @user = User.find(GDS_INSIDE_GOV_USER_ID)
      @logger = logger
    end

    def unwithdraw!
      Edition.transaction do
        # The withdrawn edition have state 'published' to create a draft.
        edition.update_attribute(:state, :published)
        edition.reload
        draft = edition.create_draft(user)
        draft.minor_change = true
        draft.editorial_remarks << EditorialRemark.create(author: @user, edition: @edition, body: "Unwithdrawn")

        Edition::AuditTrail.acting_as(user) do
          Whitehall.edition_services.force_publisher(draft).perform!
        end

        draft.reload
        logger.info("Unwithdrawn Edition #{edition.id}, this has now been superseded.")
        logger.info("Created and published draft #{draft.id}.")
        draft
      end
    end
  end
end
