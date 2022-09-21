# Programming in Virtual Reality

A prototypical programming environment using Godot's Virtual Reality and the Squeak Live Programming System.

## Setup
* Install the dependencies:
```smalltalk
Metacello new
	baseline: 'SBTreeSitter';
	onConflict: [:ex | ex allow]; repository: 'github://hpi-swa-lab/sb-tree-sitter:master/packages';
	load.
Metacello new
	baseline: 'CmfcmfReact';
	repository: 'github://tom95/ReactS:alternative-renderers/packages';
	load: #default.
```
* Clone this repo and add it via the GitBrowser, checkout the most recent commit
* In Squeak, run in a workspace:
```smalltalk
g := GDSocketListener start: SBTSGodotExample2D.
" g destroyListener. "
```
* Open the Godot project in the `project/` subfolder and run the game

## Use
* **After a code change:** focus the Godot window and press Esc to reload
* **To launch a different root component**: destroy the listener and start a new one with the right component, then restart the Godot game

## Known Issues
* `print` in Godot are not printed right away. You may have some success by placing a `yield(get_tree(), "idle_frame")` just after your print to get it to show (still not 100% reliable)
* `get` and `set` of properties from Squeak leads to a deadlock
* Component API is not final

