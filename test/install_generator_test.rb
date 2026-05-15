# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"
require "generators/recording_studio_navigation/install/install_generator"

class InstallGeneratorTest < Minitest::Test
  INSTALL_TEMPLATE_PATH = File.expand_path(
    "../lib/generators/recording_studio_navigation/install/templates/INSTALL.md",
    __dir__
  )

  def with_temp_app
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "app/assets/tailwind"))
      yield dir
    end
  end

  def build_generator(destination_root)
    RecordingStudioNavigation::Generators::InstallGenerator.new(
      [],
      {},
      destination_root: destination_root
    )
  end

  def test_add_tailwind_source_injects_engine_and_flatpack_sources
    with_temp_app do |dir|
      css_path = File.join(dir, "app/assets/tailwind/application.css")
      File.write(css_path, "@import \"tailwindcss\";\n")

      generator = build_generator(dir)

      Rails.stub(:root, Pathname.new(dir)) do
        generator.stub(:say, nil) do
          generator.add_tailwind_source
        end
      end

      css = File.read(css_path)
      assert_tailwind_sources_present(css)
    end
  end

  def test_copy_initializer_creates_host_app_initializer
    with_temp_app do |dir|
      generator = build_generator(dir)

      generator.copy_initializer

      initializer_path = File.join(dir, "config/initializers/recording_studio_navigation.rb")
      assert File.exist?(initializer_path)
      assert_includes File.read(initializer_path), "RecordingStudioNavigation.configure"
    end
  end

  def test_add_tailwind_source_does_not_duplicate_existing_entries
    with_temp_app do |dir|
      css_path = File.join(dir, "app/assets/tailwind/application.css")
      File.write(css_path, <<~CSS)
        @import "tailwindcss";
        @source "../../vendor/bundle/**/recording_studio_navigation/app/views/**/*.erb";
        @source "../../../../../../usr/local/bundle/ruby/**/bundler/gems/recording_studio_navigation-*/app/views/**/*.erb";
        @source "../../vendor/bundle/**/flatpack/app/components/**/*.{rb,erb}";
        @source "../../../../../../usr/local/bundle/ruby/**/bundler/gems/flatpack-*/app/components/**/*.{rb,erb}";
      CSS

      generator = build_generator(dir)

      Rails.stub(:root, Pathname.new(dir)) do
        generator.stub(:say, nil) do
          generator.add_tailwind_source
        end
      end

      css = File.read(css_path)
      assert_tailwind_sources_present(css)
      assert_tailwind_sources_count(css, 1)
    end
  end

  def test_install_guide_mentions_context_and_host_app_auth
    install_guide = File.read(INSTALL_TEMPLATE_PATH)

    assert_includes install_guide, "RecordingStudioNavigation.context"
    assert_includes install_guide, "current actor integration"
  end

  private

  def assert_tailwind_sources_present(css)
    tailwind_source_lines.each do |line|
      assert_includes css, line
    end
  end

  def assert_tailwind_sources_count(css, count)
    tailwind_source_lines.each do |line|
      assert_equal count, css.scan(line).size
    end
  end

  def tailwind_source_lines
    [
      '@source "../../vendor/bundle/**/recording_studio_navigation/app/views/**/*.erb";',
      '@source "../../../../../../usr/local/bundle/ruby/**/bundler/gems/recording_studio_navigation-*/app/views/**/*.erb";',
      '@source "../../vendor/bundle/**/flatpack/app/components/**/*.{rb,erb}";',
      '@source "../../../../../../usr/local/bundle/ruby/**/bundler/gems/flatpack-*/app/components/**/*.{rb,erb}";'
    ]
  end
end
