class EditionWithdrawer < EditionUnpublisher
  attr_reader :user

  def initialize(edition, options = {})
    super
    @user = options[:user]
    @previous_withdrawal = options[:previous_withdrawal]
    use_previous_withdrawal if @previous_withdrawal.present?
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
