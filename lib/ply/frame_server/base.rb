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
        new_frame = Frame.new
        new_frame.instance_eval(&block)
        frames[sym_name.to_sym] = new_frame
      end

      def self.frames
        @frames = {} if defined?(@frames).nil?
        @frames
      end
    end
  end
end

def frame(sym_name, opts = {}, &block)
  Ply::FrameServer::Base.frame(sym_name, opts, &block)
end