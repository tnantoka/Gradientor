target 'Gradientor' do
  use_frameworks!

  pod 'ChameleonFramework/Swift', git: 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'Eureka'
  pod 'IGColorPicker'
  pod "IoniconsKit"
  pod 'PKHUD'
  pod 'ReSwift'
  pod 'RFAboutView-Swift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'SwiftLint'

  target 'GradientorTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r 'Pods/Target Support Files/Pods-Gradientor/Pods-Gradientor-acknowledgements.plist', 'Gradientor/Acknowledgements.plist', remove_destination: true
end
