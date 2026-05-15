# frozen_string_literal: true

require "test_helper"
require "generators/recording_studio_navigation/migrations/migrations_generator"

class MigrationsGeneratorTest < Minitest::Test
  def test_copy_migrations_reports_noop
    generator = RecordingStudioNavigation::Generators::MigrationsGenerator.new
    messages = []

    generator.stub(:say, ->(message, color = nil) { messages << [message, color] }) do
      generator.copy_migrations
    end

    assert_includes messages, ["RecordingStudioNavigation does not add tables to the host app.", :green]
    assert_includes messages, ["No migrations were copied.", :green]
  end
end
