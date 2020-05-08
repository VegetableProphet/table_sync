# frozen_string_literal: true

module TableSync
  module Plugins
    module MessageTracker
      class Publish
        def initialize(data)
          @payload     = data[:payload]
          @model       = data[:model]
          @routing_key = data[:routing_key]
          @headers     = data[:headers]
          @event       = data[:event]
        end

        def call
          Message::Published.create(message_params) # need something more complex than create?
        end

        private

        attr_reader :model, :event, :routing_key, :headers, :payload

        def checksum
          Checksum.new(checksum_params)
        end

        def message_params
          {
            model: model,
            event: event,
            routing_key: routing_key, # + reports
            headers: headers,
            checksum: checksum,
            published: true,
            reported: false,
          }
        end

        def checksum_params
          {
            model: model,
            routing_key: routing_key,
            headers: headers,
            event: event,
            payload: payload,
          }
        end

        # PK:
        # model
        # event
        # routing_key
        # headers
        # checksum
        # time?
        
        # sent two times in a row?
        # rules for tracking set in Model
        # sync_time
      end
    end
  end
end
