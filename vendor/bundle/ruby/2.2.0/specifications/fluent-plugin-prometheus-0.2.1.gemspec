# -*- encoding: utf-8 -*-
# stub: fluent-plugin-prometheus 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent-plugin-prometheus"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Masahiro Sano"]
  s.date = "2016-09-11"
  s.description = "A fluent plugin that collects metrics and exposes for Prometheus."
  s.email = ["sabottenda@gmail.com"]
  s.homepage = "https://github.com/kazegusuri/fluent-plugin-prometheus"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "A fluent plugin that collects metrics and exposes for Prometheus."

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fluentd>, [">= 0"])
      s.add_runtime_dependency(%q<prometheus-client>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
    else
      s.add_dependency(%q<fluentd>, [">= 0"])
      s.add_dependency(%q<prometheus-client>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
    end
  else
    s.add_dependency(%q<fluentd>, [">= 0"])
    s.add_dependency(%q<prometheus-client>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
  end
end
