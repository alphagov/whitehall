class CreateAssetRelationshipForFeaturedImageDataWorker < WorkerBase
  def perform(start_id, end_id)
    return if start_id > end_id

    logger.info("CreateAssetRelationshipForFeaturedImageDataWorker start!")
    Array(start_id..end_id).each do |id|
      org = Organisation.find(id)
      unless org.default_news_organisation_image_data_id.nil? && org.featured_image_data_id
        carrierwave_image_from_default_news_organisation_image_data = DefaultNewsOrganisationImageData.find(org.default_news_organisation_image_data_id).carrierwave_image
        logger.info("Create feature image data for \n org: #{id} \n default_news_organisation_image_data: #{org.default_news_organisation_image_data_id} \n carrierwave_image: #{carrierwave_image_from_default_news_organisation_image_data}")

        featured_image_data = FeaturedImageData.new(carrierwave_image: carrierwave_image_from_default_news_organisation_image_data)
        featured_image_data.save!

        logger.info("featured_image_data #{featured_image_data.id} has been saved")
        org.update_column(:featured_image_data_id, featured_image_data.id)
      end
    rescue StandardError => e
      logger.info(e)
    end
  end
end
