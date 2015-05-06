module Election
  class PolicyPaperPublisher
    def initialize(policy_paper_ids)
      @policy_paper_ids = policy_paper_ids
    end

    def run!
      @policy_paper_ids.each do |policy_paper_id|
        if policy_paper = Publication.find_by(id: policy_paper_id)
          if policy_paper.published?
            Rails.logger.warn("WARNING: Policy paper ##{policy_paper_id} already published")
          else
            Rails.logger.info("Force publishing policy paper ##{policy_paper_id} as a minor change")
            policy_paper.minor_change = true
            policy_paper.major_change_published_at = policy_paper.first_published_at
            policy_paper.force_publish!
            policy_paper.update_column(:public_timestamp, 1.day.ago)
          end
        else
          Rails.logger.warn("WARNING: Couldn't find policy paper ##{policy_paper_id}")
        end
      end
    end
  end
end
