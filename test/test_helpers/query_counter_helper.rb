module QueryCounterHelper
  def count_queries(&block)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include QueryCounterHelper
end
