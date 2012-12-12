module Lims::Api
  module Resources
    module Order

      def order_uuid
        "6a9ff110-2678-0130-810c-282066132de2"
      end

      def item
        @order_item ||= @context.store.with_session do |s|
          order = s[order_uuid]
          lambda {
            order.keys.each do |key|
              if order[key].uuid == self.uuid
                return OpenStruct.new(:role => key.to_s, :status => order[key].status.to_s)
              end
            end
            return OpenStruct.new(:role => "mocked", :status => "mocked")
          }
        end.call
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
