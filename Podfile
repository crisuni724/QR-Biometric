platform :ios, '15.0'

# Deshabilitar la recolección de estadísticas de CocoaPods
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

target 'QR Biometrico' do
  use_frameworks!
  
  # Dependencias para el escáner QR
  pod 'ZXingObjC', '~> 3.6.9'
end

target 'QR BiometricoTests' do
  inherit! :search_paths
end

target 'QR BiometricoUITests' do
  inherit! :search_paths
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end 