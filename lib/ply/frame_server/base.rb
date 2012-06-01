require 'ply/frame_server/frame'

module Ply
  module FrameServer
    module Base
      def self.ply_root
        defined?(@ply_root).nil? ? File.absolute_path("#{Rails.root}/ply_root") : @ply_root
      end

      def self.load_frames
        target = "#{ply_root}/frames"
        Dir.glob("#{target}/*.rb").each do |file|
          load file
        end
      end

      def self.attach_to_rails
        ActionController::Base.prepend_view_path "#{ply_root}/frame_views"
        asset_names = ['images', 'stylesheets', 'javascripts'];

        asset_names.each { |asset_folder| Rails.configuration.assets.paths <<  "#{ply_root}/frame_assets/#{asset_folder}" }

        Rails.configuration.assets.paths << Rails.root.join('app', 'frame_assets', 'javascripts')
        Rails.configuration.assets.paths << Rails.root.join('app', 'frame_assets', 'stylesheets')
        Rails.configuration.assets.precompile += %w( frame_assets.js )
        Rails.configuration.assets.precompile += %w( frame_assets.css )
        self.frames.each do |frame_name, frame_obj|
          asset_names.each { |asset_folder| Rails.configuration.assets.paths << "#{ply_root}/frame_assets/#{asset_folder}/#{frame_name.to_s}" }
        end
      end

      def self.frame(sym_name, opts = {}, &block)
        sym_name = sym_name.to_sym
        new_frame = Frame.new(:name => sym_name)
        new_frame.instance_eval(&block)
        frames[sym_name] = new_frame

        calculate_frame_order!
      end

      def self.frames
        @frames = {} if defined?(@frames).nil?
        @frames
      end

      def self.calculate_frame_order!
        @ordered_frames  = frames.values.sort{|a,b| b.priority <=> a.priority}.map(&:name)
      end

      def self.ordered_frames
        @ordered_frames rescue []
      end

      def self.next_frame(current)
        cur_index = 0
        if current.respond_to?(:to_sym)
          current = current.to_sym
          cur_index = ordered_frames.index(current)
        end

        if cur_index.nil? || cur_index.eql?(ordered_frames.length - 1)
          ordered_frames[0]
        else
          ordered_frames[cur_index + 1]
        end
      end

      def self.next_frame_obj
        name = next_frame
        frames[name]
      end
    end
  end
end

def frame(sym_name, opts = {}, &block)
  Ply::FrameServer::Base.frame(sym_name, opts, &block)
end