# frozen_string_literal: true

class TableSync::Publisher::Job::Default::Single < ActiveJob::Base
  def perform(options)
    ::TableSync::Publisher::Single.new(options).call
  end
end
