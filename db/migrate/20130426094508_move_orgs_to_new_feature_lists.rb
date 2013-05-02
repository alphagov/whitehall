class MoveOrgsToNewFeatureLists < ActiveRecord::Migration
  class Feature < ActiveRecord::Base; end

  class FeatureList < ActiveRecord::Base
    has_many :features, dependent: :destroy
    belongs_to :featurable, polymorphic: true
  end

  class EditionOrganisationImageData < ActiveRecord::Base
  end

  class Edition < ActiveRecord::Base
  end

  class EditionOrganisation < ActiveRecord::Base
    belongs_to :edition
    belongs_to :image, class_name: 'EditionOrganisationImageData', foreign_key: :edition_organisation_image_data_id
  end

  class Organisation < ActiveRecord::Base
    has_many :edition_organisations
    has_many :editions,
              through: :edition_organisations

    has_many :featured_edition_organisations,
              class_name: "EditionOrganisation",
              include: :edition,
              conditions: { edition_organisations: { featured: true },
                            editions: { state: "published" } },
              order: "edition_organisations.ordering ASC"
    has_many :feature_lists, as: :featurable, dependent: :destroy
    include TranslatableModel
    translates :name, :logo_formatted_name, :acronym, :description, :about_us
  end


  def up
    Organisation.find_each do |organisation|
      organisation.translations.each do |translation|
        feature_list = organisation.feature_lists.create(locale: translation.locale)
        organisation.featured_edition_organisations.order(:ordering).each.with_index do |feo, idx|
          next if feature_list.features.where(document_id: feo.edition.document_id).any?
          new_feature = feature_list.features.create!(
            document_id: feo.edition.document_id,
            carrierwave_image: feo.image.carrierwave_image,
            alt_text: feo.alt_text,
            ordering: idx
          )
          copy_attachments(feo.image.id, new_feature.id)
        end
        # Otherwise we end up with featurable_type = 'MoveOrgsToNewFeatureLists::Organisation'
        feature_list.update_column(:featurable_type, 'Organisation')
      end
    end
  end

  def down
    ActiveRecord::Base.connection.execute "DELETE FROM feature_lists WHERE featurable_type = 'Organisation'"
    ActiveRecord::Base.connection.execute "DELETE FROM features WHERE NOT EXISTS (SELECT 1 FROM feature_lists WHERE feature_lists.id = features.feature_list_id)"
  end

  def copy_files(old_id, new_id, path)
    old_dir = "#{path}/edition_organisation_image_data/file/#{old_id}"
    new_dir = "#{path}/feature/image/#{new_id}"
    puts "copy #{old_dir}/* to #{new_dir}"
    cmd = "[ -e #{old_dir} ] && mkdir -p #{new_dir} && cp -f #{old_dir}/* #{new_dir}/"
    system cmd
  end

  def copy_attachments(old_id, new_id)
    if (Rails.env.production?)
      copy_files(old_id, new_id, Rails.root.join('clean-uploads/system/uploads'))
      copy_files(old_id, new_id, Rails.root.join('incoming-uploads/system/uploads'))
    else
      copy_files(old_id, new_id, Rails.root.join('public/system/uploads'))
    end
  end
end
