#frozen_string_literal: true

module TableSync::Plugins::MessageTracker::Extensions::Rabbit::Receiving
  class Worker
    # will need to require table_sync?
    def process_message(message, arguments)
      super

      track_received_message(tracker_params(message, arguments)) if track_received_messages?
    end

    def  track_received_message(params)
      ::TableSync::Plugins::MessageTracker::Receive.new(params).track
    end

    def tracker_params(message, arguments)
      ::TableSync::Plugins::MessageTracker::Receive::Params.new(
        build_message(message, arguments)
      ).call
    end

    def track_received_messages?
      TableSync.track_received_messages
    end
  end
end
