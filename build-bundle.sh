#!/bin/bash

rm -rf build
mkdir build
cd build

unzip ~/Downloads/Squeak6.1alpha-22185-64bit-All-in-One.zip
git clone git@github.com:hpi-swa-lab/pivr.git # --filter=blob:limit=1k 
git clone git@github.com:hpi-swa-lab/pivr-tools.git
mkdir godot
cd godot
unzip ~/Downloads/Godot_v3.5.1-stable_win64.exe.zip
unzip ~/Downloads/Godot_v3.5.1-stable_x11.64.zip
cd ..

cat << EOF
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
	baseline: 'GReaSe';
	repository: 'github://hpi-swa-lab/pivr:master/squeak';
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
" 3. run the below: "
GRExample2D start.

"later, you can update the GReaSe framework via:"
GRReact update.'.
Smalltalk snapshot: true andQuit: true.
EOF
./squeak.sh
rm -r Squeak6.1alpha-22185-64bit-All-in-One.app/Contents/Resources/github-cache
rm -r Squeak6.1alpha-22185-64bit-All-in-One.app/Contents/Resources/package-cache
zip -r pivr-bundle.zip .
