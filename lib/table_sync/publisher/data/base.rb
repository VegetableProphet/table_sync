# frozen_string_literal: true

module TableSync::Publisher::Data
  class Base
    include Memery
    include Tainbox

    attribute :object_class
    attribute :original_attributes
    attribute :confirm, default: true
    attribute :state

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
        attributes: safe_attributes,
        version: epoch_current_time,
        event: event.type,
      }
    end

    def event
      TableSync::Publisher::Data::Event.new(state)
    end

    def safe_attributes
      ::TableSync::Publisher::Data::Filter.filter_for_serialization(attributes_for_sync)
    end

    # Routing Key

    def resolve_routing_key
      routing_key_callable.call(object_class.name, attrs_for_routing_key)
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
      TableSync.routing_metadata_callable&.call(object_class.name, attrs_for_metadata)
    end

    def resolve_headers
      raise NotImplementedError
    end

    def attrs_for_metadata
      raise NotImplementedError
    end

    # Misc

    memoize def epoch_current_time
      Time.current.to_f
    end

    def model_name
      object_class.try(:table_sync_model_name) || object_class.name,
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

    def event_type
      event.type
    end
  end
end
