
Pod::Spec.new do |s|
	s.name          = "Chronos-Swift"
	s.version       = "0.2.2"
	s.summary       = "Grand Central Dispatch Utilities"
	s.homepage      = "https://github.com/comyarzaheri/Chronos-Swift"
	s.license       = { :type => "MIT", :file => "LICENSE" }
	s.author        = { "Comyar Zaheri, Andrew Chun" => "Zero223@gmail.com" }
	s.ios.deployment_target = "8.0"
	s.osx.deployment_target = "10.9"
	s.tvos.deployment_target = "9.0"
	s.source        = { :git => "https://github.com/comyarzaheri/Chronos-Swift.git", :tag => s.version.to_s }
	s.source_files  = "Chronos/*.swift"
	s.requires_arc  = true
	s.module_name	= "Chronos"
end
