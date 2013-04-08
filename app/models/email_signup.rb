class EmailSignup
  # pull in enough of active model to be able to use this in a form
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def persisted?
    false
  end

  validates :alerts, length: { minimum: 1 }
  validate :all_alerts_are_valid

  def alerts=(new_alerts)
    @alerts = Array.wrap(new_alerts).map { |new_alert| build_alert(new_alert) }
  end

  def alerts
    @alerts || []
  end

  def build_alert(args = {})
    case args
    when EmailSignup::Alert
      args
    when Hash
      EmailSignup::Alert.new(args)
    else
      raise ArgumentError, "can't construct an Alert out of #{args.inspect}"
    end
  end

  protected
  def all_alerts_are_valid
    # [].all? is always true, so we won't get double validation errors
    # about length and validity of contents
    errors.add(:alerts, 'are invalid') unless alerts.all? { |a| a.valid? }
  end

  public
  class Alert
    include ActiveModel::Validations
    attr_accessor :content_type, :topic, :organisation, :info_for_local
    def initialize(args = {})
      args.symbolize_keys.each do |attr, value|
        self.__send__("#{attr}=", args[attr])
      end
    end

    def info_for_local
      # note this is mostly from ActiveRecord::ConnectionAdapters::Column
      if @info_for_local.nil? || (@info_for_local.is_a?(String) && @info_for_local.blank?)
        nil
      else
        [true, 1, '1', 't', 'T', 'true', 'TRUE'].include?(@info_for_local)
      end
    end
    alias :info_for_local? :info_for_local
  end
end
