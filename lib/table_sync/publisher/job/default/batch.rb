# frozen_string_literal: true

class TableSync::Publisher::Job::Default::Batch < ActiveJob::Base
  def perform(options)
    ::TableSync::Publisher::Batch.new(options).call
  end
end
