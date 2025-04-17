Pod::Spec.new do |s|
  s.name             = 'native_ios_color_picker'
  s.version          = '0.0.2'
  s.summary          = 'A native macOS color picker plugin for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides access to the native macOS 10.15+ color picker.
                       DESC
  s.homepage         = 'https://github.com/squirelboy360/flutter-iOS-color-picker-plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tahiru' => 'squirelwares@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :osx, '10.15'
  s.dependency 'FlutterMacOS'
  s.swift_version    = '5.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'ENABLE_BITCODE' => 'NO' }
  s.xcconfig = { 'MACOSX_DEPLOYMENT_TARGET' => '10.15' }
  s.framework = 'AppKit'
end