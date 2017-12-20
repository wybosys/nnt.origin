plugins=("XcodeColors")
for plugin in ${plugins[@]} ; do
	source=$PROJECT_FILE_PATH/../$PROJECT_NAME/ThirdLibs/Xcode/$plugin.xcplugin	
	target=~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins
	if [ ! -d "$target" ]; then
	    mkdir -p "$target"
	fi
	target=$target/$plugin.xcplugin
	if [ ! -d "$target" ]; then	
		echo $target
		echo $source
		cp -r "$source" "$target"
	fi
done
