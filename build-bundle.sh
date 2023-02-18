#!/bin/bash

mkdir -p deps
cd deps
wget -nc http://files.squeak.org/trunk/Squeak6.1alpha-22446-64bit/Squeak6.1alpha-22446-64bit-All-in-One.zip
wget -nc https://downloads.tuxfamily.org/godotengine/3.5.1/Godot_v3.5.1-stable_x11.64.zip
wget -nc https://downloads.tuxfamily.org/godotengine/3.5.1/Godot_v3.5.1-stable_win64.exe.zip
cd ..

rm -rf build
mkdir build
cd build

unzip ../deps/Squeak6.1alpha-22446-64bit-All-in-One.zip
git clone git@github.com:hpi-swa-lab/pivr.git # --filter=blob:limit=1k 
git clone git@github.com:hpi-swa-lab/pivr-tools.git

pushd pivr
git clone git@github.com:hpi-swa-lab/pivr-tools-assets.git
popd

mkdir godot
cd godot
unzip ../../deps/Godot_v3.5.1-stable_win64.exe.zip
unzip ../../deps/Godot_v3.5.1-stable_x11.64.zip
cd ..

cat << EOF
=*=*=*=*=*=*=*=*=*= COPY AND RUN THIS =*=*=*=*=*=*=*=*=*=



"general setup that would happen in the wizard"
Utilities setAuthorInitials: 'generated'.
MCConfiguration ensureOpenTranscript: false.
[MCMcmUpdater default doUpdate: false] ensure: [MCConfiguration ensureOpenTranscript: true].
Metacello new
	repository: 'github://LeonMatthes/Autocompletion:master/packages';
	baseline: 'Autocompletion';
	get;
	load.

"git browser, custom branch with external tools"
Installer ss
	project: 'OSProcess';
	install: 'OSProcess'.
Installer ss
	project: 'CommandShell';
	install: 'CommandShell'.
Installer installGitInfrastructure.
(Smalltalk at: #SquitBrowser) selfUpdateBranch: 'external-git-fetch-push'; selfUpdate.
(Smalltalk at: #GitFeatureFlags) externalFetchAndPush: true.

"grease"
Metacello new
	baseline: 'ReactMidi';
	repository: 'github://hpi-swa-lab/react-midi:main/packages';
	load: #all.

"modifications to standard settings and adding shortcuts"
UIManager openToolsAttachedToMouseCursor: true.
Preferences setPreference: #mouseOverForKeyboardFocus toValue: true.
Workspace shouldStyle: true.
PasteUpMorph compile: 'tryInvokeKeyboardShortcut: aKeyboardEvent

	aKeyboardEvent commandKeyPressed ifFalse: [^ self].
	
	aKeyboardEvent keyCharacter caseOf: {
		[\$R] -> [Utilities browseRecentSubmissions].
		[\$L] -> [self findAFileList: aKeyboardEvent].
		[\$O] -> [self findAMonticelloBrowser].
		[\$P] -> [self findAPreferencesPanel: aKeyboardEvent].
		"[\$Z] -> [ChangeList browseRecentLog]."
		[\$Q] -> [Smalltalk snapshot: true andQuit: false].
	} otherwise: [^ self "no hit"].
	
	aKeyboardEvent ignore "hit!".'.
SystemWindow compile: 'filterEvent: aKeyboardEvent for: anObject
	"Provide keyboard shortcuts."

	aKeyboardEvent isKeystroke
		ifFalse: [^ aKeyboardEvent].

	aKeyboardEvent hand halo ifNotNil: [ : halo | halo target isSystemWindow ifTrue: [ aKeyboardEvent hand removeHalo ] ].
	
	aKeyboardEvent commandKeyPressed ifTrue: [
		aKeyboardEvent keyCharacter caseOf: { 
			[\$\] -> [self class sendTopWindowToBack].
			[\$w] -> [self class deleteTopWindow].
			[\$/] -> [self class bringWindowUnderHandToFront].
		} otherwise: [^ aKeyboardEvent "no hit"].
		^ aKeyboardEvent ignore "hit!"].
	
	aKeyboardEvent controlKeyPressed ifTrue: [
		aKeyboardEvent keyCharacter caseOf: {
			[Character escape] -> [self world findWindow: aKeyboardEvent].
		} otherwise: [^ aKeyboardEvent "no hit"].
		^ aKeyboardEvent ignore "hit!"].

	^ aKeyboardEvent "no hit"'.
SystemWindow compile: 'openAsTool
	"Open this window as a tool, that is, honor the preferences such as #reuseWindows and #openToolsAttachedToMouseCursor."
	
	| meOrSimilarWindow |
	meOrSimilarWindow := self openInWorldExtent: self extent.
	Project uiManager openToolsAttachedToMouseCursor ifTrue: [
		meOrSimilarWindow setProperty: #initialDrop toValue: true.
		meOrSimilarWindow hasDropShadow: false.
		self currentHand attachMorph: meOrSimilarWindow].
	^ meOrSimilarWindow'.

"cleanup windows and open default workspace"
(SystemWindow windowsIn: World) do: [:w | w delete].
Workspace open contents: '" 1. Run: "
GRReact findRepos.
" 2. if on mac, download Godot: https://godotengine.org/download/osx and extract to the pivr-bundle/godot folder "
" 3. let''s go! "

" run the (simulated) midi vr world "
GRReact autoStartApplications: ''AppControl,MidiWorld''.
HomeDworph start.

" start the MIDIExample without VR and assign some channels to the instruments "
" you can change the channel assignment at any time via do-it "
channels := Dictionary new.
m := MIDIExample start channelMapping: channels.
channels at: #renderBass: put: 1.
channels at: #renderArpeggio: put: 2.
channels at: #renderDrums: put: 10.

" stop the midi output. always do this before starting a new instance "
m stop.

'.
Smalltalk snapshot: true andQuit: true.



=*=*=*=*=*=*=*=*=*= COPY AND RUN THE ABOVE =*=*=*=*=*=*=*=*=*=
EOF
./squeak.sh
rm -r Squeak6.1alpha-22185-64bit-All-in-One.app/Contents/Resources/github-cache
rm -r Squeak6.1alpha-22185-64bit-All-in-One.app/Contents/Resources/package-cache
zip -r pivr-bundle.zip .
