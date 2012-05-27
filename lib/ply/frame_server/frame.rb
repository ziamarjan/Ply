module Ply
  module FrameServer
    class Frame

      attr_accessor :main_block, :supporting_services, :template_name, :name, :priority, :views, :update_every, :show_for

      def initialize(args = {})
        self.supporting_services = {}
        self.views = {}
        self.update_every = 0
        self.show_for = 30.seconds

        self.name = args[:name] unless args[:name].nil?
        self.template_name = (args[:name].nil? ? args[:template_name] : args[:name])
        self.priority = args[:priority].respond_to?(:to_i) ? args[:priority].to_i : 1

        self.cache_views!
      end

      def index(&block)
        self.main_block = block
      end

      def web_service(service_name, &block)
        self.supporting_services[service_name.to_sym] = block
      end

      def cache_views!
        target = "#{Rails.root}/app/frame_templates/#{self.name}"
        Dir.glob("#{target}/*.mustache").each do |template|
          extract = template.match(%r{#{target}/(.*)[.]mustache})
          unless extract[1].nil?
            template_name = extract[1].to_sym
            self.views[template_name] = File.open(template) { |file| file.read }
          end
        end
      end

    end
  end
end