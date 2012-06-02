require 'ply/board_server/board'

module Ply
  module BoardServer
    module Base
      def self.ply_root
        @ply_root = ENV['PLY_ROOT'] if ENV['PLY_ROOT'].present?
        defined?(@ply_root).nil? ? File.absolute_path("#{Rails.root}/ply_root") : @ply_root
      end

      def self.load_boards
        target = "#{ply_root}/boards"
        Dir.glob("#{target}/*.rb").each do |file|
          load file
        end
      end

      def self.attach_to_rails
        ActionController::Base.prepend_view_path "#{ply_root}/board_views"
        asset_names = ['images', 'stylesheets', 'javascripts'];

        asset_names.each { |asset_folder| Rails.configuration.assets.paths <<  "#{ply_root}/board_assets/#{asset_folder}" }

        Rails.configuration.assets.paths << Rails.root.join('app', 'board_assets', 'javascripts')
        Rails.configuration.assets.paths << Rails.root.join('app', 'board_assets', 'stylesheets')
        Rails.configuration.assets.precompile += %w( board_assets.js )
        Rails.configuration.assets.precompile += %w( board_assets.css )
        self.boards.each do |board_name, board_obj|
          asset_names.each { |asset_folder| Rails.configuration.assets.paths << "#{ply_root}/board_assets/#{asset_folder}/#{board_name.to_s}" }
        end
      end

      def self.board(sym_name, opts = {}, &block)
        sym_name = sym_name.to_sym
        new_board = Board.new(:name => sym_name)
        new_board.instance_eval(&block)
        new_board.finish_off!
        boards[sym_name] = new_board
      end

      def self.boards
        @boards = {} if defined?(@boards).nil?
        @boards
      end

      def self.next_board(current, opts = {})
        user_obj = opts[:user]
        allow_boards = boards.values.select {|b| b.can_view?(user_obj) && b.show.eql?(true)}
        ordered_boards = allow_boards.sort{|a,b| b.priority <=> a.priority}.map(&:name)

        cur_index = 0
        if current.respond_to?(:to_sym)
          current = current.to_sym
          cur_index = ordered_boards.index(current)
        end

        if cur_index.nil? || cur_index.eql?(ordered_boards.length - 1)
          ordered_boards[0]
        else
          ordered_boards[cur_index + 1]
        end
      end

      def self.next_board_obj
        name = next_board
        boards[name]
      end
    end
  end
end

def board(sym_name, opts = {}, &block)
  Ply::BoardServer::Base.board(sym_name, opts, &block)
end