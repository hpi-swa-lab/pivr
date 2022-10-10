Class {
	#name : #InteractiveArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
InteractiveArea >> render: props [

	| getHandAreas isHand hasGrabRelease addGrabReleaseCallbacks grabReleaseCallbacks removeGrabReleaseCallbacks |
	getHandAreas := self useProvided: #getHandAreas.
	addGrabReleaseCallbacks := self useProvided: #addGrabReleaseCallbacks.
	removeGrabReleaseCallbacks := self useProvided: #removeGrabReleaseCallbacks.
	
	isHand := [:node | getHandAreas value includes: node].
	hasGrabRelease := (props includesKey: #onGrab) or: [props includesKey: #onRelease].
	grabReleaseCallbacks := #(onGrab onRelease)
		collect: [:symbol | symbol -> (props at: symbol ifAbsent: nil)]
		as: Dictionary.

	^ GDArea new
		onAreaEntered: [:node | (isHand value: node) ifTrue: [
			props at: #onHover ifPresent: [:block | block cull: node].
			hasGrabRelease ifTrue: [
				addGrabReleaseCallbacks value: grabReleaseCallbacks]]];
		onAreaExited: [:node | (isHand value: node) ifTrue: [
			props at: #onBlur ifPresent: [:block | block cull: node].
			hasGrabRelease ifTrue: [
				removeGrabReleaseCallbacks value: grabReleaseCallbacks]]];
		children: (props at: #children)
]
