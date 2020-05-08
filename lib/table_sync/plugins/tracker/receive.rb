# frozen_string_literal: true

module TableSync
  module Plugins
    module MessageTracker
      class Receive
        def initialize(message)
        end

        def call
          ReceivedMessage.safe_insert(message_params)
        end

        def checksum
          Checksum.new(checksum_params)
        end

        def checksum_params
          {
            model: model,
            routing_key: routing_key,
            headers: headers,
            event: event,
            payload: payload,
          }
          # sync time
        end

        def message_params
          {
            project_id: project_id,
            project_group_id: project_group_id,
            model: model,
            event: event,
            routing_key: routing_key,
            headers: headers,
            checksum: checksum,
            received: true,
            reported: false,
            sync_time: sync_time,
          }
          # report_time
          # pk by checksum?
        end
      end
    end
  end
end
