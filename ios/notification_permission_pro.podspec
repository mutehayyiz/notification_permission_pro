#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint notification_permission_pro.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'notification_permission_pro'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight, production-ready Flutter package providing unified notification permission state across iOS and Android.'
  s.description      = <<-DESC
notification_permission_pro provides a unified and reliable abstraction layer for
notification permission status across iOS and Android platforms.
                       DESC
  s.homepage         = 'https://github.com/mutehayyiz/notification_permission_pro'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ahmet Şenharputlu' => 'ahmet.senharputlu@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
