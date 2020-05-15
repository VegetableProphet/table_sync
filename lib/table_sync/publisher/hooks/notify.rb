# frozen_string_literal: true

class TableSync::Publisher::Hooks::Notify
  include Tainbox

  attribute :object_class
  attribute :event
  attribute :count
  attribute :direction, default: :publish

  def call
    TableSync::Instrument.notify(params)
  end

  private

  def model_naming
    TableSync.orm.model_naming(object_class)
  end

  def params
    { 
      table: model_naming.table,
      schema: model_naming.schema,
      event: event,
      count: count, # can just send count with nil or 1?
      direction: direction,
    }.compact
  end
end
