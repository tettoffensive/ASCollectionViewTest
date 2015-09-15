source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "8.0"

inhibit_all_warnings!
use_frameworks!

workspace 'Channels'
xcodeproj 'Channels/Channels'
#xcodeproj 'POLYFoundation/POLYFoundation'

# Allows per-dev overrides
local_podfile = "Podfile.local"
eval(File.open(local_podfile).read) if File.exist? local_podfile

def import_pods
  # Language Nicities
  pod 'KVOController'
  pod 'ObjectiveSugar'
  pod 'Bolts'

  # libextobjc
  pod 'libextobjc/EXTScope'
end

target :Channels do
  xcodeproj 'Channels/Channels'
  import_pods
  # Core
  pod 'Mantle'
  pod 'DateTools'

  # Analytics
  pod 'Mixpanel'

  # Animation/Layout/UI
  pod 'pop'
  pod 'FLKAutoLayout'
  pod 'PBJVision'
  pod 'PBJVideoPlayer'
  pod 'AsyncDisplayKit'
  pod 'FXBlurView'

  # Core
  pod "AFNetworking", "~> 2.5.1"
  pod "AFNetworkActivityLogger"
  pod "SDWebImage"

  # AWS - https://github.com/aws/aws-sdk-ios for avail packages
  pod 'AWSCore'
  pod 'AWSS3'
  pod 'AWSCognito'
  
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  
end

target 'ChannelsTests', :exclusive => true do
  xcodeproj 'Channels/Channels'
  pod 'OHHTTPStubs'
end

#target :POLYFoundation do
#  xcodeproj 'POLYFoundation/POLYFoundation'
#  import_pods
#  # Core
#  pod "AFNetworking", "~> 2.5.1"
#  pod "AFNetworkActivityLogger"
#  pod "SDWebImage"
#
#  # AWS - https://github.com/aws/aws-sdk-ios for avail packages
#  pod 'AWSCore'
#  pod 'AWSS3'
#end
#
#target 'POLYFoundationTests', :exclusive => true do
#  xcodeproj 'POLYFoundation/POLYFoundation'
#  pod 'OHHTTPStubs'
#end
