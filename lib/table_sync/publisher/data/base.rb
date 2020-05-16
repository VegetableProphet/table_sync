# frozen_string_literal: true

module TableSync::Publisher::Data
  class Base
    include Memery
    include Tainbox

    attribute :model
    attribute :original_attributes
    attribute :confirm
    attribute :event

    def call
      params.compact
    end

    def params
      {
        event: :table_sync,
        data: publishing_data,
        confirm_select: confirm,
        routing_key: resolve_routing_key,
        realtime: true,
        headers: resolve_headers,
        exchange_name: exchange_name, # can send exchange_name = nil?
      }
    end

    private

    def publishing_data
      {
        model: model,
        attributes: attributes_for_sync,
        version: current_epoch_time,
        event: event.type,
      }
    end

    # Routing Key

    def resolve_routing_key
      routing_key_callable.call(model_name, attrs_for_routing_key)
    end

    def routing_key_callable
      return TableSync.routing_key_callable if TableSync.routing_key_callable
      raise "Can't publish, set TableSync.routing_key_callable"
    end

    def attrs_for_routing_key
      raise NotImplementedError
    end

    # Metadata

    def resolve_metadata
      TableSync.routing_metadata_callable&.call(model_name, attrs_for_metadata)
    end

    def resolve_headers
      raise NotImplementedError
    end

    def attrs_for_metadata
      raise NotImplementedError
    end

    # Misc

    memoize def current_epoch_time
      Time.current.to_f
    end

    memoize def model_name
      model.try(:table_sync_model_name) || model.name,
    end

    def attributes_for_sync
      raise NotImplementedError
    end

    def valid?
      raise NotImplementedError
    end

    def exchange_name
      TableSync.exchange_name
    end
  end
end
