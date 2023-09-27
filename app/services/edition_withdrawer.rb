class EditionWithdrawer < EditionUnpublisher
  attr_reader :user

  def initialize(edition, options = {})
    super
    @user = options[:user]
    @previous_withdrawal = options[:previous_withdrawal]
    use_previous_withdrawal if @previous_withdrawal.present?
  end

  def failure_reason
    @failure_reason ||= if !can_transition?
                          "An edition that is #{edition.current_state} cannot be #{past_participle}"
                        elsif (other_edition = edition.other_editions.in_pre_publication_state.first)
                          "There is already a #{other_edition.state} edition of this document. You must discard it before you can #{verb} this edition."
                        elsif edition.unpublishing.blank?
                          "The reason for unpublishing must be present"
                        elsif !edition.unpublishing.valid?
                          edition.unpublishing.errors.full_messages.to_sentence
                        end
  end

  def verb
    "withdraw"
  end

  def past_participle
    "withdrawn"
  end

private

  def use_previous_withdrawal
    @edition.unpublishing.explanation = @previous_withdrawal.explanation
    @edition.unpublishing.unpublished_at = @previous_withdrawal.unpublished_at
  end

  def fire_transition!
    edition.authors << user if user
    super
  end

  def prepare_edition
    edition.force_published = false
  end
end
