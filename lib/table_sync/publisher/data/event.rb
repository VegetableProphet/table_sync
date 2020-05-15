if opts[:destroyed].nil?
  @state = opts.fetch(:state, :updated).to_sym
  validate_state
else
  # TODO Legacy job support, remove
  @state = opts[:destroyed] ? :destroyed : :updated
end


def event
  destroyed? ? :destroy : :update
end

def needle
  original_attributes.slice(*primary_keys)
end

def destroyed?
  state == :destroyed
end

def created?
  state == :created
end

def validate_state
  raise "Unknown state: #{state.inspect}" unless %i[created updated destroyed].include?(state)
end