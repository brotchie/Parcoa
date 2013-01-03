#
# Be sure to run `pod spec lint Parcoa.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "Parcoa"
  s.version      = "0.0.1"
  s.summary      = "Objective-C Parser Combinators."
  s.homepage     = "https://github.com/brotchie/Parcoa"
  s.license      = 'MIT'
  s.author       = { "James Brotchie" => "brotchie@gmail.com" }
  s.source       = { :git => "https://github.com/brotchie/Parcoa.git", :tag => "v#{s.version}"}
  s.source_files = 'Parcoa/**/*.{h,m}'
  s.requires_arc = true
end
