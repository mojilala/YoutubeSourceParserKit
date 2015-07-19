#
# Be sure to run `pod lib lint youtube-parser.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "youtube-parser"
  s.version          = "0.1.5"
  s.summary          = "YouTube parser for swift"
  s.homepage         = "https://github.com/toygard/youtube-parser"
  s.license          = 'MIT'
  s.author           = { "Toygar Dündaralp" => "tdundaralp@gmail.com" }
  s.source           = { :git => "https://github.com/toygard/youtube-parser.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'youtube-parser/*.swift'
end
