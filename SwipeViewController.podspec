#
# Be sure to run `pod lib lint SwipeViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwipeViewController"
  s.version          = "1.0"
  s.summary          = "Subclass of UIPageViewController and UINavigation for easy navigation"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "SwipeViewController is an easy and quick way to implement PageViewController with addition of buttons at the top of the view."

  s.homepage         = "https://github.com/fortmarek/SwipeViewController"
  s.license          = 'MIT'
  s.author           = { "fortmarek" => "marekfort@me.com" }
  s.source           = { :git => "https://github.com/fortmarek/SwipeViewController.git", :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  # s.resource_bundles = {
  #  'SwipeViewController' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end


