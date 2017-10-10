class EditionWithdrawer < EditionUnpublisher
  attr_reader :user

  def initialize(edition, options = {})
    super
    @user = options[:user]
  end

  def verb
    'withdraw'
  end

  def past_participle
    'withdrawn'
  end

private

  def fire_transition!
    edition.authors << user if user
    super
  end

  def prepare_edition
    edition.force_published = false
  end
end
