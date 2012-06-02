module Ply
  module BoardServer
    class Board

      attr_accessor :main_block, :supporting_services, :template_name, 
      :name, :priority, :views, :update_every, :show_for, :auth_required, :groups_allowed,
      :show

      def initialize(args = {})
        self.supporting_services = {}
        self.views = {}
        self.update_every = 0
        self.show_for = 30.seconds
        self.auth_required = false
        self.groups_allowed = []
        self.show = true

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
        target = "#{Ply::BoardServer::Base.ply_root}/board_templates/#{self.name}"
        Dir.glob("#{target}/*.mustache").each do |template|
          extract = template.match(%r{#{target}/(.*)[.]mustache})
          unless extract[1].nil?
            template_name = extract[1].to_sym
            self.views[template_name] = File.open(template) { |file| file.read }
          end
        end
      end

      def requires_auth?
        self.auth_required.eql?(true) || self.groups_allowed.length > 0
      end

      def finish_off!
        standardise_groups!
      end

      def standardise_groups!
        self.groups_allowed = self.groups_allowed.map {|g| g.to_sym}
      end

      def can_view?(user_obj)
        return true if self.auth_required.eql?(false) || self.groups_allowed.empty?

        return false if user_obj.nil?

        self.groups_allowed.each {|g| return true if user_obj.groups.include?(g)}
        false
      end

    end
  end
end