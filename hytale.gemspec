# frozen_string_literal: true

require_relative "lib/hytale/version"

Gem::Specification.new do |spec|
  spec.name = "hytale"
  spec.version = Hytale::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@intergga.ch"]

  spec.summary = "Ruby gem for reading Hytale game data"
  spec.description = "A Ruby gem for reading and parsing Hytale game data including settings, player data, world saves, and launcher logs."
  spec.homepage = "https://github.com/marcoroth/hytale-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{lib,exe}/**/*") + ["LICENSE.txt", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["hytale"]
  spec.require_paths = ["lib"]

  spec.add_dependency "base64", "~> 0.3"
  spec.add_dependency "chunky_png", "~> 1.4"
  spec.add_dependency "rubyzip", "~> 2.3"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "zstd-ruby", "~> 2.0"
end
