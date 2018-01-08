class CollectionDataReporter
  HEADERS = [
    'Collection',
    'Public URL',
    'Admin URL',
    'Documents',
    'History-mode Documents',
    'Withdrawn Documents'
  ].freeze

  def initialize(output_dir)
    @output_dir = output_dir
  end

  def report
    organisations_with_collections.each do |org|
      collections = collections_for_organisation(org)
      next if collections.to_a.empty?

      CSV.open(csv_path(org), 'wb') do |csv|
        csv << HEADERS
        collections.map do |collection|
          csv << [
            collection.title,
            public_link(collection.search_link),
            admin_link(admin_path_for_collection(collection)),
            collection.editions.publicly_visible.size,
            collection.num_political,
            collection.num_withdrawn,
          ]
        end
      end
    end
  end

private

  def organisations_with_collections
    Organisation.find(
      DocumentCollection.publicly_visible.joins(:organisations).pluck(:organisation_id).uniq
    )
  end

  def collections_for_organisation(organisation)
    DocumentCollection
      .publicly_visible
      .joins(:organisations)
      .select(
        'editions.*',
        'COUNT(editions_editions.political = 1 OR NULL) AS num_political',
        'COUNT(editions_editions.state = "withdrawn" OR NULL) AS num_withdrawn'
      )
      .in_default_locale
      .includes(:document)
      .joins(:editions)
      .where(:organisations => {id: organisation.id})
      .where('editions_editions.state IN (?)', Edition::PUBLICLY_VISIBLE_STATES)
      .having('num_withdrawn > 0 OR num_political > 0')
      .group(:id)
  end

  def csv_path(organisation)
    File.join(@output_dir, "#{organisation.slug}.csv")
  end

  def admin_path_for_collection(collection)
    Rails.application.routes.url_helpers.admin_document_collection_path(collection)
  end

  def public_link(path)
    "https://www.gov.uk" + path
  end

  def admin_link(path)
    "https://whitehall-admin.publishing.service.gov.uk" + path
  end
end
