# -*- encoding: utf-8 -*-
# stub: prometheus-client 0.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "prometheus-client"
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tobias Schmidt"]
  s.date = "2016-08-08"
  s.email = ["ts@soundcloud.com"]
  s.homepage = "https://github.com/prometheus/client_ruby"
  s.licenses = ["Apache 2.0"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "A suite of instrumentation metric primitivesthat can be exposed through a web services interface."

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<quantile>, ["~> 0.2.0"])
    else
      s.add_dependency(%q<quantile>, ["~> 0.2.0"])
    end
  else
    s.add_dependency(%q<quantile>, ["~> 0.2.0"])
  end
end
