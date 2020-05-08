# frozen_string_literal: true

# @api private
# @since 2.3.0
class TableSync::Plugins::Tracker < TableSync::Plugins::Abstract
    # @return [void]
    #
    # @api private
    # @since 2.3.0
  def install!
    # TableSync.extend(TableSync::Plugins::Tracker::Extensions::TableSync)
    # Rabbit.extend(TableSync::Plugins::Tracker::Extensions::Rabbit)
  end
end

TableSync.register_plugin(:tracker, TableSync::Plugins::Tracker)
