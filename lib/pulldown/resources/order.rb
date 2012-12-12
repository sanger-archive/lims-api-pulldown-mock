module Lims::Api
  module Resources
    module Order

      def order_uuid
        uuid_resources = @context.store.with_session do |session|
          criteria = {:item => {:uuid => self.uuid}}
          filter = Lims::Core::Persistence::MultiCriteriaFilter.new(:criteria => criteria)
          search = Lims::Core::Persistence::Search.new(:description => 'search order',
                                                       :model => session.send('order').model,
                                                       :filter => filter)
          search.call(session).slice(0,9).inject([]) do |m,o| 
            order_id = session.id_for(o)
            m << session.uuid_resource[:model_class => 'Order', :key => order_id]
          end
        end
        uuid_resources.empty? ? nil : uuid_resources.first.uuid
      end

      def item
        @order_item ||= OpenStruct.new(:role => "mocked", :status => "mocked")
        begin
          @order_item = @context.store.with_session do |s|
            order = s[order_uuid]
            lambda {
              order.keys.each do |key|
                if order[key].uuid == self.uuid
                  return OpenStruct.new(:role => key.to_s, :status => order[key].status.to_s)
                end
              end
            }
          end.call
        rescue
        end
        @order_item
      end

      def purpose_uuid
        item.role
      end

      def sequencescape_state_mapper(state)
        case state
        when "in_progress" then "started"
        when "done" then "passed"
        else state
        end
      end

      def state
        sequencescape_state_mapper(item.status)
      end
    end
  end
end
