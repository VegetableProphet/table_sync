# frozen_string_literal: true

class TableSync::Publisher::Job::Time
  include Tainbox

  DEBOUNCE_TIME = 60

  attribute :model
  attribute :original_attributes
  attribute :event
  attribute :debounce_time, default: DEBOUNCE_TIME

  def initialize(args)
    super(args)

    self.event = ::TableSync::Publisher::Data::Event.new(type: event)
  end

  # perform_at returns time to enqueue job at
  # the goal is to sync an object only once in debounce_time

  # Returns current time if (job will be enqueued right now):
  # - event -> destroy
  # - no debounce_time
  # - time for next sync has already passed (it's in the past or right now)

  # Returns next_sync_time (time previous job for this object was synced + debounce_time):
  # - next_sync_time hast not happened yet, it's in the future

  def perform_at
    enqueue_now? ? current_time : next_sync_time
  end
  
  def before_sync_time?
    sync_time > current_time
  end

  private

  def next_sync_time_passed?
    next_sync_time <= current_time
  end

  def enqueue_now?
    event.destroy? || debounce_time.zero? || next_sync_time_passed?
  end

  # Time Getters

  memoize def current_time
    Time.current
  end

  memoize def sync_time
    cached_sync_time || current_time - debounce_time - 1.second
  end

  def next_sync_time
    sync_time + debounce_time
  end

  def debounce_time
    super.seconds
  end

  # Cache

  memoize def cache_key
    ::TableSync::Publisher::Data::Object.new(
      model: model,
      attrs: original_attributes,
      event: event,
    ).cache_key
  end

  def cache_perform_at_time
    Rails.cache.write(cache_key, perform_at)
  end

  def cached_sync_time
    Rails.cache.read(cache_key)
  end
end