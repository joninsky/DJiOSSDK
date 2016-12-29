


Pod::Spec.new do |s|

s.name = 'DJiOSSDK'
s.version = '0.0.1'
s.summary = 'SDK For interacting with the #1 DJ Server on iOS'
s.description = <<-DESC
iOS SDK written in swift that will let you interact with the #1 DJ Server
                DESC
s.homepage = 'https://github.com/joninsky/DJiOSSDK.git'
s.license = 'MIT'
s.author = {'Jon Vogel' => 'http://joninsky.com'}
s.source = {:git => 'https://github.com/joninsky/DJiOSSDK.git'}

s.platform = :ios, '10.0'
s.requires_arc = true
s.source_files = 'DJiOSSDK/**/*'
s.dependency 'RealmSwift'
end