require 'ply/frame_server/frame'

module Ply
  module FrameServer
    module Base
      def self.load_frames
        target = "#{Rails.root}/app/frames"
        Dir.glob("#{target}/*.rb").each do |file|
          load file
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