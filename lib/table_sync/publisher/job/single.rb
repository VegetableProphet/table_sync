# frozen_string_literal: true

class TableSync::Publisher::Job::Single
  include Tainbox

  DEBOUNCE_TIME = 60

  attribute :object_class
  attribute :original_attributes
  attribute :confirm
  attribute :state
  attribute :debounce_time

  def enqueue
    return unless enqueue?

    next_sync_time <= current_time ? enqueue_job : enqueue_job(next_sync_time)
  end

  def job_class
    return TableSync.publishing_job_class_callable.call if TableSync.publishing_job_class_callable
    raise "Can't publish, set TableSync.publishing_job_class_callable"
  end

  def debounce_time
    super.seconds
  end

  def enqueue_job(perform_at = current_time)
    job = job_class.set(wait_until: perform_at)
    job.perform_later(object_class.name, original_attributes, state: state.to_s, confirm: confirm?)
    Rails.cache.write(cache_key, perform_at)
  end

  def enqueue?
    # return enqueue_job if destroyed? || debounce_time.zero?
    return if sync_time > current_time
  end

  def lock_with_sync_time!
    Rails.cache.write(data.cache_key, perform_at)
  end

  def cached_sync_time
    Rails.cache.read(cache_key)
  end

  memoize def current_time
  end

  memoize def sync_time
    cached_sync_time || current_time - debounce_time - 1.second
  end

  def next_sync_time
    sync_time + debounce_time
  end
end
