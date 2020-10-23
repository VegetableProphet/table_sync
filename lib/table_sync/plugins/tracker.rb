# frozen_string_literal: true

module TableSync::Plugins::Tracker
end

class TableSync::Plugins::Tracker::Message
  attr_reader :table, :message_data

  def initialize(params)
    @message_data = params.slice(:routing_key, :headers, :message_id)
    # .merge(
    #   model:   params[:data][:model],
    #   event:   params[:data][:event],
    #   version: params[:data][:version],
    #   rows:    Array.wrap(params[:data][:attributes]).count,
    # )
  end

  def track!
    # when received - destroy if already exists
    # what if message requeued?
    DB[table].insert(message_data)
  end

  def published # from config
    @table = :ts_published_messages and return self
  end

  def received
    @table = :ts_received_messages and return self
  end
end

module TableSync::Plugins::Tracker::Publisher
  attr_reader :message_id

  def initialize(object_class, attrs, **options)
    super(object_class, attrs, **options)

    @message_id = SecureRandom.uuid
  end

  def publish_now
    super

    track!
  end

  # message_id is an inbuilt bunny header
  def params
    super.merge(message_id: message_id)
  end

  def track!
    TableSync::Plugins::Tracker::Message.new(params).published.track!
  end

  def kek
    puts "kek!"
  end
end

# подумать!
module TableSync::Plugins::Tracker::Worker
  def work_with_params(message, delivery_info, arguments)
    message = message.dup.force_encoding("UTF-8")
    self.class.logger.debug([message, delivery_info, arguments].join(" / "))
    job_class.set(queue: queue(message, arguments)).perform_later(message, arguments.to_h)
    ack!

    track!(
      routing_key: delivery_info[:routing_key],
      headers: arguments[:headers],
      message_id: arguments[:message_id],
    )
  rescue => error
    raise if Rabbit.config.environment == :test
    Rabbit.config.exception_notifier.call(error)
    requeue!
  end

  def track!(**params)
    return unless params[:message_id]
    TableSync::Plugins::Tracker::Message.new(params).received.track!
  end
end

TableSync::BatchPublisher  .prepend(TableSync::Plugins::Tracker::Publisher)
TableSync::Publisher       .prepend(TableSync::Plugins::Tracker::Publisher)
Rabbit::Receiving::Worker  .include(TableSync::Plugins::Tracker::Worker)
