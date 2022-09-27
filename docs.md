# Getting Start with PiVR

In this seminar, we leverage two big software systems:
1. Godot and its 3D and VR rendering capabilities
2. Squeak/Smalltalk and its excellent support for hot-code reloading.
Together, they form the basis of our VR Programming Environment. All code is written in Squeak and translates to calls for rendering in Godot.

To both make UI programming and the communication between Squeak and Godot easier, we will be using a framework that is similar to ReactJS. In the following, we will be walking through the basic concepts of GReaSe (GodotREActSquEak), most of which have the exact same semantics as in ReactJS. If semantics differ, we will point it out specifically, otherwise you can assume that words mean the same and behavior is identical.

> The tutorial follows a similar structure to https://beta.reactjs.org/learn

## Godot
Godot is a game engine that, like many other engines, uses a tree of nodes to describe its 3D scenes and logic. Specific Godot nodes for example can display 3D Cubes, mark shapes for collisions, or detect when other nodes intersect them. Godot nodes have a list of child nodes, a set of properties that influence their behavior or appearance, and a set of signals. Godots API is best explorer in the engine itself, by pressing F1 and searching for any node or property name.

## Components
All code in GReaSe is structured in components. Components group other components and Godot nodes. In GReaSe you create a component by creating a subclass of GRComponent that had a render method:
```
MyHelloComponent >> render: props

    ^ (self godot: Label) text: 'Hello world'
```

> ReactJS: careful, even though we are creating classes, GReaSe components are strictly functional components in terms of ReactJS with no overlap to class components at all!

Here, we define a render method that receives a dictionary of properties and returns a Godot label node on which we set the text property. Simply run `MyHelloComponent start` in a workspace and you should see a window with the hello world label opening.

Components can nest. For example, create another component with the following render method:
```
MyMultiLabel >> render: props

    ^ (self godot: #VBoxContainer) children: {
        MyHelloComponent new.
        MyHelloComponent new.
   }
```
and run `MyMultiLabel start`.

## Displaying Data
Let's make the HelloComponent parametrized and display the property that is passed into it instead:
```
MyHelloComponent >> render: props

    ^ (self godot: Label)
        text: (props at: #myLabel ifAbsent: ['Hello world'])
```
Note that we are accessing the `props` dictionary and are even providing a default value.

Now, in our parent component, we can set the new property:
```
MyMultiLabel >> render: props

    ^ (self godot: #VBoxContainer) children: {
        MyHelloComponent new myLabel: 'a'.
        MyHelloComponent new myLabel: 'b'
   }
```

## Conditional Rendering 

You can use Squeak's ifTrue:ifFalse: to make a component alternate or only appear sometimes.

```
MyMultiLabel >> render: props

    ^ (self godot: #VBoxContainer) children: {
        cond1 ifTrue: [MyHelloComponent new].
        cond2
            ifTrue: [MyHelloComponent new]
            ifFalse: [self godot: #Button]
   }
```

## Rendering Lists

We can render lists by creating arrays of nodes and components, like in the below case where we define our data in a local variable and the collect: over the list and return a label each.
```
MyMultiLabel >> render: props

    | list |
    list := {
        {'a'. 10@10. GRReact nextGodotId}.
        {'b'. 30@50. GRReact nextGodotId}.
        {'c'. 70@10. GRReact nextGodotId}.
    }.

    ^ (self godot: #VBoxContainer)
        children: (list collect: [:pair |
            (self godot: #Label)
                rect_position: pair second;
                text: pair first;
                key: pair third])
```
Two things to note: first, the cascades are a convenient way to set multiple properties. You do not need to use #yourself, all setters always return the node.
Second, whenever you create elements based on a list, assign the special `key:` property (which is not passed to Godot). It helps the React reconciliation logic to figure out what happened if items are deleted or moved in your list. `GRReact nextGodotId` is a helper that generates a unique id as a simple integer.

## Responding to Events
Signals or events from Godot are handled the same way as properties. You pass smalltalk block closures that will be called when the event is triggered. For example:

```
MyButton >> render: props

     ^ (self godot: #Button)
         label: 'click';
         pressed: [Transcript showln: 'pressed!']
```

## Updating the Scene

So far, our applications were entirely static, so there was no reason to update the screen. Only once we add state that can be changed, there is reason for us to worry about updates.

In React, so called hooks are used to manage state:

```
MyButton >> render: props

    | count |
    count := self useState: 0.
    
    ^ (self godot: #Button)
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
```
MyComponent >> render: props

    ^ (self godot: VBoxContainer) children: {
        (self methodAsComponent: #renderChild:) label: 'A'.
        (self methodAsComponent: #renderChild:) label: 'B'.
    }

MyComponent >>renderChild: props

    myState := self useState: 0.
    ^ (self godot: #Label) text: (props at: #label), myState get asString
```

## Testing in GReaSe
Testing is comparitively simple, as long as you don't need to rely on side effects from the Godot engine. Our test framework provides with the tree of nodes that would be created in Godot, without actually having to run the engine each time. To get started, subclass GRTestCase and create a test method.

Use either `self openComponent: MyComponent` or the convenience method `self openComponentBlock: [self godot: #Label]` to "open" your top-level component. Then trigger signals or subscriptions on the nodes to advance the state and assert against the tree. For example:

```
testConditionalReplace

  self openComponentBlock: [:props | | active |
    active := CMFReact useState: false.
    {
      (self godot: #Button) pressed: [active set: [:b | b not]].
      active get
        ifTrue: [self godot: #Label]
        ifFalse: [self godot: #Spatial]}].
  
  self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
  self should: [godotTree firstNodeOfType: #Spatial] raise: Error.
  
  self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
  self shouldnt: [godotTree firstNodeOfType: #Spatial] raise: Error.
```
Note the use of `CMFReact useState:` instead of `self useState:`. The latter is just a convenience that forwards the call to `CMFReact`, which is not available in the tests.

Check out `GRMockNode`'s `accessing` and `updates` category for a full list of methods you can use on `godotTree` and its children to update and assert against the state.

> It is recommended to always use the `firstNode*` methods again instead of saving nodes in variables. As React may replace Godot nodes you may be holding on to obsolete nodes otherwise. Exception is when you know for sure that the nodes will persist, for example the VR controller nodes.

## Context vs Provider
GReaSe supports Contexts as seen in ReactJS. As an alternative, you can use GRProvider, which incurs slightly less boilerplate.
TODO example

# Reference

...
