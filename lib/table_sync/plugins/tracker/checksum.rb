# frozen_string_literal: true

module TableSync
  module Plugins
    module MessageTracker
      class Checksum
        attr_reader :model, :routing_key, :headers, :event, :payload

        def initialize(params)
          @model       = params[:model]
          @routing_key = params[:routing_key]
          @headers     = params[:headers]
          @event       = params[:event]
          @payload     = params[:payload]
        end

        def call
          Digest::MD5.hexdigest(hashed_data)
        end

        private

        def hashed_data
          [payload, model, routing_key, headers, event].map(&:to_s).join
        end

        # headers only sorted keys?
        # {}.to_s ?
        # add sync_tyme
        # payload, model, sync_time
      end
    end
  end
end