Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers |
	"getHandAreas := self useProvided: #getHandAreas.
	addGrabReleaseCallbacks := self useProvided: #addGrabReleaseCallbacks.
	 := self useProvided: #removeGrabReleaseCallbacks."
	
	"isHand := [:node | value includes: node]."
	"isHand := self useProvided: #isHand."
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	"hasGrabRelease := (props includesKey: #onGrab) or: [props includesKey: #onRelease].
	grabReleaseCallbacks := #(onGrab onRelease)
		collect: [:symbol | symbol -> (props at: symbol ifAbsent: nil)]
		as: Dictionary."
	eventHandlers := (#(onHover onBlur onGrab onRelease)
		select: [:symbol | props includesKey: symbol]
		thenCollect: [:symbol | symbol -> (props at: symbol)])
		as: Dictionary.

	^ GDArea new
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers.
			"props at: #onHover ifPresent: [:block | block cull: node]."
			"hasGrabRelease ifTrue: [
				 value: grabReleaseCallbacks]"];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers
			"props at: #onBlur ifPresent: [:block | block cull: node]."
			"hasGrabRelease ifTrue: [
				removeGrabReleaseCallbacks value: grabReleaseCallbacks]"];
		children: (props at: #children)
]
