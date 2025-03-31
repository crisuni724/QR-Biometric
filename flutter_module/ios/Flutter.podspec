Pod::Spec.new do |s|
  s.name                  = 'Flutter'
  s.version               = '1.0.0'
  s.summary               = 'Flutter Engine Framework'
  s.description           = <<-DESC
Flutter is Google's SDK for building beautiful, native applications for iOS, Android, and Web from a single codebase.
DESC
  s.homepage              = 'https://flutter.dev'
  s.license               = { :type => 'MIT' }
  s.author                = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source                = { :git => 'https://github.com/flutter/engine', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.vendored_frameworks   = 'Flutter.framework'
  s.pod_target_xcconfig   = { 'DEFINES_MODULE' => 'YES' }
end 