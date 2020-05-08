# frozen_string_literal: true

# add Tainbox? It's used in rabbit anyway

class TableSync::Plugins::MessageTracker::Receive
  class Params
    include Tainbox

    attribute :message

    def call
      {
        project_id: message.project_id,
        group_id: message.group_id,
        event: message.event,
        payload: data[:attributes],
        model: data[:model],
        routing_key: data[:routing_key],
        headers: data[:headers],
        sync_time: data[:sync_time],
      }
    end
  end
end


module Convert
  class Currency
    include Tainbox
    include Memery

    NoExchangeRateFound = Class.new(StandardError)
    NoCurrencyRateFound = Class.new(StandardError)

    attribute :current,     String
    attribute :target,      String
    attribute :amount,      Float
    attribute :exchange_at, Time, default: -> { Time.current }

    def call
      raise NoExchangeRateFound, no_exchange_rate_msg unless exchange_rate
      raise NoCurrencyRateFound, no_currency_rate_msg unless currency_rate

      amount * target_rate.to_f
    end

    private

    memoize def exchange_rate
      ExchangeRate.find_for(current, at: exchange_at)
    end

    def currency_rate
      exchange_rate.rates.fetch(target)
    end

    def no_exchange_rate_msg
      "#{current} -> #{target} at #{exchange_at}"
    end

    def no_currency_rate_msg
      exchange_rate.values.merge(target: target).inspect
    end
  end
end
