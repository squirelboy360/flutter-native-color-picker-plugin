Pod::Spec.new do |s|
  s.name             = 'native_ios_color_picker'
  s.version          = '0.0.2'
  s.summary          = 'A native iOS color picker plugin for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides access to the native iOS 14+ color picker.
                       DESC
  s.homepage         = 'https://github.com/squirelboy360/flutter-iOS-color-picker-plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tahiru' => 'squirelwares@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '14.0'
  s.dependency 'Flutter'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end