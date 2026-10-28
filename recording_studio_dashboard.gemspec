# frozen_string_literal: true

require_relative "lib/recording_studio_dashboard/version"

Gem::Specification.new do |spec|
  spec.name        = "recording_studio_dashboard"
  spec.version     = RecordingStudioDashboard::VERSION
  spec.authors     = ["Bowerbird"]
  spec.homepage    = "https://github.com/bowerbird-app/RecordingStudio_dashboard"
  spec.summary     = "Configurable dashboards for Recording Studio applications"
  spec.description = "A reusable dashboard framework for Recording Studio. Host applications " \
                     "register dashboards, rows, and widgets. Each widget owns the content it renders."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bowerbird-app/RecordingStudio_dashboard"
  spec.metadata["changelog_uri"] = "https://github.com/bowerbird-app/RecordingStudio_dashboard/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"].reject do |path|
      path == ".cursor" || path.start_with?(".cursor/")
    end
  end

  spec.add_dependency "flat_pack", ">= 0.1.327", "< 0.2"
  spec.add_dependency "rails", "~> 8.1.0"
  spec.add_dependency "recording_studio", "~> 6.2"
end
