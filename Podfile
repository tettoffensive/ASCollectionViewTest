source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "8.0"

inhibit_all_warnings!
use_frameworks!

workspace 'ASCollectionViewTest'
xcodeproj 'ASCollectionViewTest/ASCollectionViewTest'

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

target :ASCollectionViewTest do
  xcodeproj 'ASCollectionViewTest/ASCollectionViewTest'
  import_pods
  # Core
  pod 'Mantle'
  pod 'DateTools'

  # Animation/Layout/UI
  pod 'pop'
  pod 'AsyncDisplayKit', :git => 'https://github.com/facebook/AsyncDisplayKit.git', :branch => 'master'

  # Core
  pod "AFNetworking", "~> 2.5.1"
  pod "AFNetworkActivityLogger"
  pod "SDWebImage"
end
