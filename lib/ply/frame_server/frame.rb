module Ply
  module FrameServer
    class Frame

      attr_accessor :main_block, :supporting_services, :template_name, :name, :priority

      def initialize(args = {})
        self.supporting_services = {}

        self.name = args[:name] unless args[:name].nil?
        self.template_name = (args[:name].nil? ? args[:template_name] : args[:name])
        self.priority = args[:priority].respond_to?(:to_i) ? args[:priority].to_i : 1
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