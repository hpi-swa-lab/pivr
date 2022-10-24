# Getting Started with PiVR

In this seminar, we leverage two big software systems:
1. Godot and its 3D and VR rendering capabilities
2. Squeak/Smalltalk and its excellent support for hot-code reloading.
Together, they form the basis of our VR Programming Environment. All code is written in Squeak and translates to calls for rendering in Godot.

To both make UI programming and the communication between Squeak and Godot easier, we will be using a framework that is similar to ReactJS. In the following, we will be walking through the basic concepts of GReaSe (GodotREActSquEak), most of which have the exact same semantics as in ReactJS. If semantics differ, we will point it out specifically, otherwise you can assume that words mean the same and behavior is identical.

> The tutorial follows a similar structure to https://beta.reactjs.org/learn

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

## Convenience functions/hooks

## Performance Tips
- every method call is expensive; avoid imperative-style programming
- (to be extended)

## Debugging Tips
* Via the Godot remote debugger, you can inspect all Godot nodes that were spawned and their properties. Start the component once in Squeak via `MyComponent startListener`, and open `pivr/project` in Godot and press F5.

## Dworphic
- interaction system that builds on top of grease
- ensures that interactions are somewhat uniform
- provides convenience/boilerplate

## Why do we have to use GReaSe?
[note: technically, we don't **have** to use it, it's just very convenient :)]
- message passing between godot and squeak very slow, but size of individual messages not as important
- send as few messages as possible: reconciliation, batching

## Random todos
* controll vs hand terminology
* UseNamespace

