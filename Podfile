# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'ATB' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ATB
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
	
	pod 'FacebookCore'  
	pod 'FacebookLogin'
	pod 'IQKeyboardManagerSwift'
	pod 'Alamofire'
  pod 'SwiftyJSON'
	pod 'Kingfisher'
	pod 'NVActivityIndicatorView'
	pod 'SideMenu'
	pod 'RAMAnimatedTabBarController'
	pod 'ReadMoreTextView'
	pod 'Cosmos'
	pod 'LinearProgressBar'
	pod 'CHIPageControl'
	pod 'DropDown'
	pod 'KWVerificationCodeView'
	pod 'CardIO'
	pod 'Stripe'
	pod 'PDFReader'
	pod 'Lightbox'
#	pod 'CropViewController'
  pod 'BMPlayer'
  pod 'ImageSlideshow'
  pod 'ImageSlideshow/Kingfisher'
	pod 'Applozic', '~> 7.14.0'
  pod 'AlertTransition'
  pod 'Player'
	pod 'NotificationBannerSwift'
	pod 'Braintree'
  pod 'BraintreeDropIn', '~> 8.1.2'
  pod 'MessageKit', '~> 3.1.1'
  pod 'LocationPickerViewController'
  pod 'OpalImagePicker'
  pod 'PopupDialog'
  pod 'Mixpanel-swift'
  
  pod 'InputBarAccessoryView'
  pod 'SwiftHEXColors'
  pod 'CarbonKit'
  pod 'YLProgressBar'
  pod 'TTGTagCollectionView', '~>1.11.2'
  #pod 'UITextView+Placeholder'
  pod 'WSTagsField'
  pod 'SemiModalViewController'
#  pod 'PopupController', :git => 'https://github.com/ahmedsafadii/PopupController.git'
  pod 'MaterialComponents/Buttons'
  pod 'VisualEffectView'
  pod 'BetterSegmentedControl'
  pod 'Panels'
#  pod 'SwiftMessages'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'EasyTipView'
  pod 'NBBottomSheet'
  pod "MonthYearPicker"
  
  pod 'NVActivityIndicatorView'
  pod 'ARNTransitionAnimator'
  
  pod 'FSCalendar'
  pod 'Branch', '~> 1.38.0'
  
  pod 'BadgeHub'
  pod 'SkeletonView'
  
  pod 'ActionSheetPicker-3.0'
  pod 'SwiftCSVExport' , '= 2.3.0'
  pod 'CHIOTPField/Two'
  
  pod 'TOWebViewController'
  
#  pod 'SDWebImagePDFCoder'

  target 'ATBTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ATBUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
