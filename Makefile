all:
	xcodebuild build -target XcodeSPM 
	ln -fs `pwd`/build/Release/XcodeSPM /usr/local/bin/xpm
