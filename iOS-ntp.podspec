Pod::Spec.new do |s|
  s.name = 'iOS-ntp'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'This project is a mirror of the iOS-ntp project hosted on [Google code](http://code.google.com/p/ios-ntp/) by Gavin Eadie'
  s.homepage = 'http://code.google.com/p/ios-ntp/'
  s.author = { 'Gavin Eadie' => '' }
  s.source = { :git => 'https://github.com/tomaszrybakiewicz/iOS-ntp.git' }
  s.ios.deployment_target = "5.0"
  s.dependency 'CocoaAsyncSocket'
  s.requires_arc = true
  s.source_files = 'Classes/NetAssociation.{h,m}', 'Classes/NetworkClock.{h,m}'
  s.resource_bundle = { 'Res' => ['LICENSE','ntp.hosts'] }
  s.public_header_files = 'Classes/NetAssociation.h', 'Classes/NetworkClock.h'
  s.prefix_header_file = 'ntpA_Prefix.pch'
  s.frameworks = 'CFNetwork'
end
