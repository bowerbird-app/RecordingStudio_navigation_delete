# frozen_string_literal: true

require "rails/generators"

module RecordingStudioNavigation
  module Generators
    class MigrationsGenerator < Rails::Generators::Base
      desc "Explain that RecordingStudioNavigation ships without migrations"

      def copy_migrations
        say "RecordingStudioNavigation does not add tables to the host app.", :green
        say "No migrations were copied.", :green
      end
    end
  end
end
