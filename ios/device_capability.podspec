Pod::Spec.new do |s|
  s.name             = 'device_capability'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for device capability detection.'
  s.description      = <<-DESC
A Flutter plugin that detects device capabilities, calculates performance scores and tiers.
                       DESC
  s.homepage         = 'https://github.com/nrlngrsh/device_capability'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nurlan' => 'nrlngrsh@github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
