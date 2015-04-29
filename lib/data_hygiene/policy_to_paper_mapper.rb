require 'csv'

module DataHygiene
  # Used to identify the corresponding Policy Publication for a given policy.
  # Based on the CSV file generated when the publications were first generated.
  #
  # Note: Can be removed after the migration to new policies has been complete.
  class PolicyToPaperMapper
    CSV_PATH = Rails.root.join('lib/data_hygiene/policy_to_paper_mappings.csv')

    def initialize
      @id_mapping = generate_mapping_hash
    end

    def publication_for(policy)
      Publication.find id_mapping[policy.id]
    end

  private
    attr_reader :id_mapping

    def generate_mapping_hash
      {}.tap do |hash|
        CSV.foreach(CSV_PATH, headers: true) do |row|
          hash[row["policy_id"].to_i] = row["policy_paper_id"].to_i
        end
      end
    end
  end
end
