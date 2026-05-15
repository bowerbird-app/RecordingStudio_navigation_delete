# frozen_string_literal: true

require_relative "lib/recording_studio_navigation/version"

Gem::Specification.new do |spec|
  spec.name        = "recording_studio_navigation"
  spec.version     = RecordingStudioNavigation::VERSION
  spec.authors     = ["Bowerbird"]
  spec.homepage    = "https://github.com/bowerbird-app/RecordingStudio_navigation"
  spec.summary     = "Access-aware navigation registry and composition for Recording Studio"
  spec.description = "A Rails engine gem that composes Recording Studio navigation from runtime " \
                     "items, groups, sections, and root-aware tree links."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bowerbird-app/RecordingStudio_navigation"
  spec.metadata["changelog_uri"] = "https://github.com/bowerbird-app/RecordingStudio_navigation/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 8.1.0"
  spec.add_dependency "flat_pack"
end
