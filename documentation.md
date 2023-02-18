# Getting Started with PiVR

In this seminar, we leverage two big software systems:
1. Godot and its 3D and VR rendering capabilities
2. Squeak/Smalltalk and its excellent support for hot-code reloading.
Together, they form the basis of our VR Programming Environment. All code is written in Squeak and translates to calls for rendering in Godot.

To both make UI programming and the communication between Squeak and Godot easier, we will be using a framework that is similar to ReactJS. In the following, we will be walking through the basic concepts of GReaSe (GodotREActSquEak), most of which have the exact same semantics as in ReactJS. If semantics differ, we will point it out specifically, otherwise you can assume that words mean the same and behavior is identical.

> The tutorial follows a similar structure to https://beta.reactjs.org/learn

## Shortcuts
Save shortcut: edit PasteUpMorph>>tryInvokeKeyboardShortcut:
Pref: Open Tools Attached to Mouse Cursor


| Keyboard Shortcut | Action |
| -------- | -------- |
| Cmd+w | close window
| Cmd+n/m | senders/implementors
| Cmd+b | browse/duplicate browser
| Cmd+f | auf der klassenliste
| Cmd+shift+N | references to it
| Cmd+0 | search (case sensitive!)
| Cmd+shift+Q | save image
| Cmd+d | do-it
| Alt+. | interrupt stuck process
| Cmd+shift+I | explore object

Tools>Recover Changes

enclose brackets via open/close bracket
double click inside brackets to select

Pref: Destructive Back-Word

stdlibrary:
* OrderedCollection
* putVariantOn:

## Installation
* Download the pivr-bundle.zip and extract it: https://tmbe.me/c/pivr-bundle.zip
* Setup the VR environment, see below.
* Run `GRExampleVR start` in Squeak to verify that everything worked (it may ask for the full path to the Godot executable)

For **SteamVR**, make sure that you have SteamVR installed and running. Godot will automatically connect to it.

For **standalone headsets**, such as the Quest, you need `adb` and manually install the Godot core once; afterwards you can just start the game each time.
1. Install `adb`, either by downloading Android Studio or just the Commandline Tools: https://developer.android.com/studio#downloads
2. Connect your Headset and allow file transfer.
3. Open the `pivr/project` in Godot 3.5; download the Export Templates; press the Android button in the top-right to install the project to the headset.

## Godot
Godot is a game engine that, like many other engines, uses a tree of nodes to describe its 3D scenes and logic. Specific Godot nodes for example can display 3D Cubes, mark shapes for collisions, or detect when other nodes intersect them. Godot nodes have a list of child nodes, a set of properties that influence their behavior or appearance, and a set of signals. Godots API is best explored in the engine itself, by pressing F1 and searching for any node, method, or property name. The documentation is also available [online](https://docs.godotengine.org/en/3.5/).

## Components
All code in GReaSe is structured in components. Components group other components and Godot nodes. In GReaSe you create a component by creating a subclass of GRComponent that had a render method:
```smalltalk
MyHelloComponent >> render: props

    ^ GDLabel new text: 'Hello world'
```
> ReactJS: careful, even though we are creating classes, GReaSe components are strictly functional components in terms of ReactJS with no overlap to class components at all! It's better to think of a class as a grouping of the render function and its related functions and components. Instance variables will not work as you expect.

Here, we define a render method that receives a dictionary of properties and returns a Godot label node on which we set the text property. Simply run `MyHelloComponent start` in a workspace and you should see a window with the hello world label opening.

Components can nest. For example, create another component with the following render method:
```smalltalk
MyMultiLabel >> render: props

    ^ GDVBoxContainer new children: {
        MyHelloComponent new.
        MyHelloComponent new.
   }
```
and run `MyMultiLabel start`.

## Displaying Data
Let's make the HelloComponent parametrized and display the property that is passed into it instead:
```smalltalk
MyHelloComponent >> render: props

    ^ GDLabel new
        text: (props at: #myLabel ifAbsent: ['Hello world'])
```
Note that we are accessing the `props` dictionary and are even providing a default value.

Now, in our parent component, we can set the new property:
```smalltalk
MyMultiLabel >> render: props

    ^ GDVBoxContainer new children: {
        MyHelloComponent new myLabel: 'a'.
        MyHelloComponent new myLabel: 'b'
   }
```

## Conditional Rendering 

You can use Squeak's ifTrue:ifFalse: to make a component alternate or only appear sometimes.

```smalltalk
MyMultiLabel >> render: props

    ^ GDVBoxContainer new children: {
        cond1 ifTrue: [MyHelloComponent new].
        cond2
            ifTrue: [MyHelloComponent new]
            ifFalse: [GDButton new]
   }
```

## Rendering Lists

We can render lists by creating arrays of nodes and components, like in the below case where we define our data in a local variable and the collect: over the list and return a label each.
```smalltalk
MyMultiLabel >> render: props

    | list |
    list := {
        {'a'. 10@10. GRReact nextGodotId}.
        {'b'. 30@50. GRReact nextGodotId}.
        {'c'. 70@10. GRReact nextGodotId}.
    }.

    ^ GDVBoxContainer new
        children: (list collect: [:pair |
            GDLabel new
                rectPosition: pair second;
                text: pair first;
                key: pair third])
```
Two things to note: first, the cascades are a convenient way to set multiple properties. You do not need to use #yourself, all setters always return the node.
Second, whenever you create elements based on a list, assign the special `key:` property (which is not passed to Godot). It helps the React reconciliation logic to figure out what happened if items are deleted or moved in your list. `GRReact nextGodotId` is a helper that generates a unique id as a simple integer.

## Responding to Events
Signals or events from Godot are handled the same way as properties. You pass smalltalk block closures that will be called when the event is triggered. For example:

```smalltalk
MyButton >> render: props

     ^ GDButton new
         label: 'click';
         pressed: [Transcript showln: 'pressed!']
```

## Updating the Scene

So far, our applications were entirely static, so there was no reason to update the screen. Only once we add state that can be changed, there is reason for us to worry about updates.

In React, so called hooks are used to manage state:

```smalltalk
MyButton >> render: props

    | count |
    count := self useState: 0.
    
    ^ GDButton new
        label: 'click ', count get asString;
        pressed: [count set: [:c | c + 1]]
```

Hooks are identified by the `use` prefix at the start of the method. Here, we are using the `useState` hook that initializes a piece of state with its parameter. So, in this case, we creating a piece of state and initialize it to the number 0. The hook returns a wrapper that we can call `get` on to read the current state value. In addition, we can call `set:` to change it.

We can either just set a new value, e.g. `count set: 7`, or update the current value, in which case we pass a Smalltalk block as shown above. As such, every time we click the button, the label on the button increments.

> ReactJS: unlike in ReactJS, we don't return a pair, as Smalltalk does not have array destructuring, making this a lot less ergonomic. A nice boon, however, is that closures that capture the `count` variable don't become stale; calling `get` will always return the current value.

## Where to go from here
You have now seen all essential syntax/constructs of GReaSe. All ReactJS tutorials you can find on state management etc are also applicable to the largest extent to GReaSe. For example, if you want to better understand how to structure state in React applications, one good entry point would be the official documentation: https://beta.reactjs.org/learn/describing-the-ui

Below, is a more comprehensive overview of the GReaSe API, also with regards to the conveniences we prepared for use in a VR context, as well as some other concerns.

## Multiple Components per Class
As a convenience, you can use `self methodAsComponent: #renderHelper:` to create a component from another component from a different method on a component class. This is useful, in particular, if you want to group a set of hooks or make them conditional, as with each new component you can start a new list of hooks without violating the rules of hooks (https://reactjs.org/docs/hooks-rules.html). For example:
```smalltalk
MyComponent >> render: props

    ^ GDVBoxContainer new children: {
        (self methodAsComponent: #renderChild:) label: 'A'.
        (self methodAsComponent: #renderChild:) label: 'B'.
    }

MyComponent >>renderChild: props

    myState := self useState: 0.
    ^ GDLabel new text: (props at: #label), myState get asString
```

## Testing in GReaSe
Testing is comparitively simple, as long as you don't need to rely on side effects from the Godot engine. Our test framework provides with the tree of nodes that would be created in Godot, without actually having to run the engine each time. To get started, subclass GRTestCase and create a test method.

Use either `self openComponent: MyComponent` or the convenience method `self openComponentBlock: [GDLabel new]` to "open" your top-level component. Then trigger signals or subscriptions on the nodes to advance the state and assert against the tree. For example:

```smalltalk
testConditionalReplace

  self openComponentBlock: [:props | | active |
    active := CMFReact useState: false.
    {
      GDButton new pressed: [active set: [:b | b not]].
      active get
        ifTrue: [GDLabel new]
        ifFalse: [GDSpatial new]}].
  
  self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
  self should: [godotTree firstNodeOfType: #Spatial] raise: Error.
  
  self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
  self shouldnt: [godotTree firstNodeOfType: #Spatial] raise: Error.
```
Note the use of `CMFReact useState:` instead of `self useState:`. The latter is just a convenience that forwards the call to `CMFReact`, which is not available in the tests.

Check out `GRMockNode`'s `accessing` and `updates` category for a full list of methods you can use on `godotTree` and its children to update and assert against the state.

> It is recommended to always use the `firstNode*` methods again instead of saving nodes in variables. As React may replace Godot nodes you may be holding on to obsolete nodes otherwise. Exception is when you know for sure that the nodes will persist, for example the VR controller nodes.

## Context vs `GRProvider`
GReaSe supports Contexts as seen in ReactJS. As an alternative, you can use GRProvider, which incurs slightly less boilerplate.
```smalltalk
ComponentAtTheTop >> render: props

    count := self useState: 0.
    ^ GRProvider values: {
        #count -> count.
        #constant -> 123.
    } children: {ComponentChild new}

ComponentChild >> render: props

    count := self useProvided: #count.
    ^ GDLabel new text: count get
```

## How to access assets/images?
Place them in a `pivr/pivr-tools-assets/YOUR_TOPIC` folder of the pivr-tools-assets repo. Then, you can simply reference them by path via `res://pivr-tools-assets/YOUR_TOPIC/my-file.png`. You may have to open the project in the Godot Engine once for the asset to be imported.
For **standalone headsets**, you have to re-export the game once for the files to be bundled.

## Elegantly defining properties

To make accessing properties easier and to make it clearer to users of your component what properties you expect, you can use the Dictionary>>extract: method.

```smalltalk
render: props

	| areaRef |
	^ props extract: [:side :children :touch :point :rest |
		^ GDArea new
			setAll: rest;
			collisionMask: ...;
			children: children]
```

Missing properties are set to nil. Note in particular the `rest` argument. Any property that was passed and that you didn't extract will land in this Dictionary.
Feel free to use this everywhere if you see value in it; it may become the default in future versions of ReactS.

## Refs / Obtaining references or identifying to Godot objects
Due to an implementation quirk there are two distinct use cases for ReactJS's refs:
1. For Portals, use the form `self useRef: nil`
2. To get a reference to a Godot object use `self useGodotRef`

For **portals**, you can then invoke:
```smalltalk
containerRef := self useRef: nil.
GDContainer new ref: containerRef.

" elsewhere: "
^ CMFReactPortal child: GDLabel new in: containerRef get
```

For **refs to Godot objects** you can then invoke methods (see below) or compare them in callbacks for e.g. collisions:
```smalltalk
areaRef := self useGodotRef.
GDArea new ref: areaRef.

" elsewhere: "
GDArea new
    onAreaEntered: [:other | other = areaRef get ifTrue: [...]].
```

If you have multiple Godot objects you want to identify, the easiest means is to set a custom id field (also see below text on calling methods):
```smalltalk
render: props

    ^ myObjects collect: [:obj | GDArea new meta: #id set: obj id]

" elsewhere: "
GDArea new
    onAreaEntered: [:other | | id |
        id := other getMetaName: 'id'].
```

## How to interface with Godot Objects directly
If you find yourself needing to call a method on Godot objects, first try using the declarative means if possible:
1. Via `subscribeTo:do:` and `subscribeCall:with:do:` you can be informed of changes to a value:
```smalltalk
GDARVRController new
    subscribeTo: #transform do: [:transform | ...];
    subscribeCall: #get_joystick_axis with: {4} do: [:value | ...]
```
2. Via `call:arguments:` you can perform a call whenever the arguments you passed in changed:
```smalltalk
GDImageTexture new
    call: #load arguments: {'res://icon.png'}
```
3. Lastly, you can get a ref and perform calls directly (incurs a synchronous roundtrip to Godot and back each time, so use only if called sparsely and not per frame):
```smalltalk
curveRef := self useGodotRef.
someCallback := [:point | curveRef get addPointPosition: point].

GDPath new
    curve: (GDCurve3D new
        ref: curveRef;
        bakeInterval: 0.01).
```
Alternatively, get and set properties:
```smalltalk
" need to convert root because it is returned as GDNode
  but we know it is a GDViewport "
viewport := sceneTree root grAsClass: #GDViewport.
viewport hdr: false
```

You can also call methods on a global singleton via the instance method:
```smalltalk
sceneTree := GDEngine instance getMainLoop.
```
...or create new instances that are not in the tree:
```smalltalk
image := self useRef: nil.
self
    useEffect: [
        image set: GDImage externalNew: 
        image get createFromData: bits.
        [image get unreference. image set: nil]]
    dependencies: {}
```
NOTE: Godot resources are reference counted. When creating new instances outside the tree, we reference the resource once. If you no longer need the instance (or reference it from another Godot object which should now take care of its lifetime) you **must call unreference**. In the above example, we use a cleanup handler of the effect.

Alternatively, you can use `externalNewDuring:` to automatically unreference instances that go out of scope:
```smalltalk
GDInputEventKey externalNewDuring: [:inputEvent |
    inputEvent
        scancode: keyCode;
        pressed: true;
        shift: shiftPressed get.
    GDInput instance parseInputEvent: inputEvent]
```

## Node Paths
If a Godot node **requires** a NodePath (in other case, use Godot refs), you can set the `name` of a Node and refer to it. This will only work with relative paths. For example:
```smalltalk
GDSpatial new children: {
    " create a Path node (sorry, bad example, not related to NodePaths) "
    GDPath new
        curve: (GDCurve3D new ref: curveRef);
        name: 'path'.
    " set the path node of the polygon to a NodePath to that path "
    GDCSGPolygon new
        pathNode: (GRNodePath path: '../path');
        polygon: (GRPoolVector2Array new
            add: (Vector2 x: -0.005 y: -0.005);
            add: (Vector2 x: -0.005 y: 0.005);
            add: (Vector2 x: 0.005 y: 0.005);
            add: (Vector2 x: 0.005 y: -0.005);
            yourself);
        mode: GDCSGPolygon modePath
}
```

## Using Godot Code
> NOTE: out of date, please ask for an update.

You can inject Godot code as seen in the following example:
```smalltalk
render: props

	| script |
	script := self useState: nil.
	self
		useEffect: [
			script set: (GDGDScript externalNew
				sourceCode: self gdSource withUnixLineEndings;
				reload;
				yourself).
			[script get unreference]]
		dependencies: {}.
	^ script get ifNotNil: [
		GDSpatial new
            set: 'my_prop' to: 1232;
			call: 'set_script' arguments: {script get};
			call: 'set_process' arguments: {true}]
```
```smalltalk
gdSource

    ^ 'extends Spatial

var my_prop

func _process(d):
    print("Hello")'
```

**Four things to watch our for:**
1. Note the call to `set_process`, which is required if you have a `_process` method in your GDScript.
2. Make sure that the extends field matches the Node you're attaching the script to.
3. Setting custom properties does not work via the usual setters, instead you use `set:to:` (see above)
4. The `_ready` function will not be called when used this way. Instead, run your init code e.g. the first time a setter is called. (This is because during GReaSe syncing, the node will already be in the tree before the script with the _ready function is attached,)

## Custom Godot Classes

To use a custom class, do as follows:
```smalltalk
^ (self godot: #CustomClassName)
    my_prop: 5;
    my_signal: [:arg1 | Transcript showln: arg1]
```

Which would correspond to a Godot class:
```python
extends Node
class_name CustomClassName

signal my_signal(arg1)

var myProp
```

## Convenience functions/hooks

## Performance Tips
- every method call is expensive; avoid imperative-style programming
- (to be extended)

## Debugging Tips
* Via the Godot remote debugger, you can inspect all Godot nodes that were spawned and their properties. Start the component once in Squeak via `MyComponent startListener`, and open `pivr/project` in Godot and press F5.


## Why do we have to use GReaSe?
[note: technically, we don't **have** to use it, it's just very convenient :)]
- message passing between godot and squeak very slow, but size of individual messages not as important
- send as few messages as possible: reconciliation, batching

# Dworphic
"3D Morphic", "Dworphic" is a framework for creating VR applications on top of GReaSe. It provides facilities to ensure that interactions are uniform across applications and, though the "Dworphs" implemented in it, forms what one may call a VR desktop environment. Below, we describe its core concepts.

## Applications

All functionality in Dworphic is bundled in applications. Applications can be opened and closed inside the central WorldDworph and may add to or alter functionality of the core system.

For example, a game may be a single application. But, an alternative hand tracking system that replaces the default is also considered an application in Dworphic.

Applications are defined via a `DworphApplicationDescription`. Here, you can set what should be displayed when the application is opened and what functionality it may replace.

```smalltalk
DworphicApplicationDescription new
    " the main render function, returns a component "
    render: [AppBarDworph new];
    " optionally, we can replace the default hand with a different component "
    renderHand: [MyCustomHandDworph new];
    " we set a name for the app launcher to display "
    name: 'App Bar'
```

The easiest way to define and open an application is to create a component for your application, create a class-side method called appDescription that returns the DworphApplicationDescription and finally tag that method with the `<home>` pragma. Now, when you open the HomeDworph, your application will appear in its launcher.

```smalltalk
MyApplicationDworph class>>appDescription
    
    <home>
    " super appDescription gives us an AppDescription with the name and
      render: fields already filled "
    ^ super appDescription
```

If you're looking for a manual way to open applications, check out the `useApplication:dependencies:` hook.


### GRInteractiveArea

The InteractiveArea wraps Godot's Area node to automatically interoperate with the VR controllers. As such, this or a higher-level component that uses the InteractiveArea should be your first go-to solution for any interactions with the user.

Steps to use it:
* add a collision shape as a direct child
* decide whether you want point and/or touch interactions
* subscribe to the events of relevance to you: onHover, onBlur, onButtonPress, onButtonRelease (the button events are only sent to this Area while it's being hovered)

All subscriptions receive an event object. For button events it contains the button number. All events contain a transform property, describing the controller's transform at the moment of the event triggering.

All properties of Area are also available in InteractiveArea.

```smalltalk
hovered := self useState: false.
GRInteractiveArea new
    touch: true;
    point: true;
    onHover: [hovered set: true];
    onBlur: [hovered set: false];
    onButtonPress: [:event | event isTrigger ifTrue: [...]];
    children: {
        self
            cubeOfSize: 0.02
            color: (hovered get ifTrue: [color muchLighter] ifFalse: [color])}
```

## Grabbables

The GrabbableArea uses the InteractiveArea to allow objects to be picked up by the user. To use it:
* add a collision shape as a direct child
* subscribe to the events of relevance to you: onGrab, onRelease, onHover, onBlur, onButtonPress, onButtonRelease (the button events are sent to this area while it is hovered or held in a hand)
* optionally, set its transform property: if not set, the GrabbableArea will stay where it was released, you don't have any control. If set, the GrabbableArea will always return to the set transform, so if you sometimes want it to stay, make sure to update the set transform in onRelease

```smalltalk
grabbed := self useState: false.
pressed := self useState: false.

GRGrabbableArea new
    children: {GDCollisionShape new shape: self collisionShape};
    onButtonPress: [:e | e isTrigger ifTrue: [pressed set: true]];
    onButtonRelease: [:e | e isTrigger ifTrue: [pressed set: false]];
    onGrab: [grabbed set: true];
    onRelease: [grabbed set: false]
```

Here is an example with a controller transform:
```smalltalk
transform := self useState: (Matrix4x4 withOffset: 0 @ 1 @ 0).

GRGrabbableArea new
    children: {GDCollisionShape new shape: self collisionShape};
    transform: transform get;
    onRelease: [:e | transform set: e transform]
```

## Global State

You should always default to storing all state inside your application. If you do need persistent (while Godot is running), global state, for example if you want to provide a log utility to all apps, you can define an extension method on WorldDworph and tag it with the `<provider>` pragma. Here, you can use the useState hook and whatever else you may need and finally return a collection of associations that are made globally available via a GRProvider.

```smalltalk
" category: *Dworphic-Log "
WorldDworph >> provideLogEntries

    <provider>
    logEntries := self useState: {}.
    ^ {#logEntries -> logEntries}
```

## Simulator

To aid with debugging or allow developing when no headset is available, Dworphic can be set to start in a simulator via the preferences. The simulator activates automatically if no OpenXR interface can be found (careful: the absence of a headset might still mean that an interface is available, it's just not usable, which we can't detect reliably).

Use WSAD for moving on the horizontal plane and QE for moving up and down. Use right-click to move the view.

Similarly, hold Alt for the right controller or Ctrl for the left controller and use the same shortcuts to move them. In addition, you can left-click any collisionshape in the scene while holding either modifier to snap the controller to that position.

## Importing Meshes with Textures
Easiest procedure:
1. Find a GLTF or create a MeshInstance in the Godot editor that has the texture assigned
2. Once the mesh with the texture is visible in the viewport, go to the inspector on the right in Godot with the MeshInstance selected
3. In the inspector, there is a small dropdown arrow next to the MeshInstance's mesh. Click that and choose "Save". Name the file e.g. `cow.mesh`.
4. In Squeak, use the following to load the textured mesh and use it:
```smalltalk
render: props

    mesh := self
        useMemo: [GDResourceLoader instance loadPath: 'res://cow.mesh']
        dependencies: {}.

    ^ GDMeshInstance new mesh: mesh
```

