# Programming in Virtual Reality

A prototypical programming environment using Godot's Virtual Reality and the Squeak Live Programming System.

## Setup
* Install the dependencies:
```smalltalk
Metacello new
	baseline: 'GReaSe';
	onConflict: [:ex | ex allow];
	repository: 'github://hpi-swa-lab/pivr:master/squeak';
	get; load.
```
* Clone this repo and add it via the GitBrowser, checkout the most recent commit
* In Squeak, run in a workspace:
```smalltalk
GRExample2D inGodot
```
* Open the Godot project in the `project/` subfolder and run the game

## Use
* **After a code change:** focus the Godot window and press Esc to reload
* **To launch a different root component**: start the listener again with the right component, then restart the Godot game

## Known Issues
* `print` in Godot are not printed right away. You may have some success by placing a `yield(get_tree(), "idle_frame")` just after your print to get it to show (still not 100% reliable)
* `get` and `set` of properties from Squeak leads to a deadlock
* Component API is not final; in particular the godot nodes and ReactS component APIs are very different at the moment
* refs are updated one frame too late (trigger a re-render) and generally a bit awkward still
* putVariantOn: and readVariant is not implemented for all classes yet. Refer to the [Godot source code](https://github.com/godotengine/godot/blob/3.5/core/io/marshalls.cpp) to add those you need.

## VR
* Run `GRExampleVR inGodot` for the test scene
* For the Quest, either:
	- change the IP address in `GSRoot/GSRoot.gd` to that of the computer where Squeak is running (no better ideas for this just yet)
	- map your laptop's port to the device's port if you are connected via cable: `adb reverse tcp:8292 tcp:8292`
