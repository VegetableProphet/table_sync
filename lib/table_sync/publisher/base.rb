# frozen_string_literal: true

class TableSync::Publisher::Base
  include Tainbox
  include Memery

  attribute :model,   String
  attribute :confirm, Boolean, default: true
  attribute :event,   Symbol,  default: :update

  attribute :original_attributes

  def initialize(args)
    super(args)

    self.model               = model.constantize
    self.original_attributes = symbolyzed_original_attributes
  end

  def call
    return unless publish?

    Rabbit.publish(data.call)

    call_after_hooks
  end

  private

  memoize def data
    TableSync::Publisher::Data.new(data_params)
  end

  def call_after_hooks
    TableSync::Publisher::Hooks::Notify.new(notify_params).call
  end

  # Params for services

  def data_params
    {
      model: model,
      original_attributes: original_attributes,
      confirm: confirm,
      event: event,
    }
  end

  def notify_params
    {
      model: model,
      event: event,
    }
  end

  # Misc

  # need to symbolyze?
  def symbolized_original_attributes
    raise NotImplementedError
  end

  def publish?
    data.valid?
  end
end