Pod::Spec.new do |s|
  s.name             = 'native_ios_color_picker'
  s.version          = '0.0.1'
  s.summary          = 'A native iOS color picker plugin for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides access to the native iOS 14+ color picker.
                       DESC
  s.homepage         = 'https://github.com/yourusername/native_ios_color_picker'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '10.15'
  s.dependency 'Flutter'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end