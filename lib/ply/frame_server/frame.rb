module Ply
  module FrameServer
    class Frame

      attr_accessor :main_block, :supporting_services

      def initialize(args = {})
        self.supporting_services = {}
      end

      def index(&block)
        self.main_block = block
      end

      def web_service(service_name, &block)
        self.supporting_services[service_name.to_sym] = block
      end

    end
  end
end