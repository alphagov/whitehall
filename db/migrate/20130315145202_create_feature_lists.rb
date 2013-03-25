class CreateFeatureLists < ActiveRecord::Migration
  class ::Feature < ActiveRecord::Base; end
  class ::FeatureList < ActiveRecord::Base
    has_many :features, dependent: :destroy
    belongs_to :featurable, polymorphic: true
  end
  class ::EditionWorldLocationImageData < ActiveRecord::Base
  end
  class ::Edition < ActiveRecord::Base
  end
  class ::EditionWorldLocation < ActiveRecord::Base
    belongs_to :edition
    belongs_to :image, class_name: 'EditionWorldLocationImageData', foreign_key: :edition_world_location_image_data_id
  end
  class ::WorldLocation < ActiveRecord::Base
    has_many :edition_world_locations
    has_many :editions,
              through: :edition_world_locations

    has_many :featured_edition_world_locations,
              class_name: "EditionWorldLocation",
              include: :edition,
              conditions: { edition_world_locations: { featured: true },
                            editions: { state: "published" } },
              order: "edition_world_locations.ordering ASC"
    has_one :feature_list, as: :featurable, dependent: :destroy
  end

  def up
    create_table :features do |t|
      t.references :document
      t.references :feature_list
      t.string     :carrierwave_image
      t.string     :alt_text
      t.integer    :ordering
      t.datetime   :started_at
      t.datetime   :ended_at
    end
    add_index :features, :feature_list_id
    add_index :features, :ordering
    add_index :features, [:feature_list_id, :ordering], unique: true
    add_index :features, :document_id

    create_table :feature_lists do |t|
      t.references :featurable, polymorphic: true
      t.string :locale

      t.timestamps
    end
    add_index :feature_lists, [:featurable_id, :featurable_type, :locale], name: "featurable_lists_unique_locale_per_featurable", unique: true

    WorldLocation.find_each do |wl|
      wl.feature_list = ::FeatureList.create!
      wl.featured_edition_world_locations.each do |ewl|
        next if wl.feature_list.features.where(document_id: ewl.edition.document_id).any?
        new_feature = wl.feature_list.features.create!(
          document_id: ewl.edition.document_id,
          carrierwave_image: ewl.image.carrierwave_image,
          alt_text: ewl.alt_text,
          ordering: ewl.ordering
        )
        copy_attachments(ewl.image.id, new_feature.id)
      end
    end
  end

  def down
    drop_table :feature_lists
    drop_table :features
  end

  def copy_files(old_id, new_id, path)
    old_dir = "#{path}/edition_world_location_image_data/file/#{old_id}"
    new_dir = "#{path}/feature/file/#{new_id}"
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
