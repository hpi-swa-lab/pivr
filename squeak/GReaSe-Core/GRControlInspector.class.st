Class {
	#name : #GRControlInspector,
	#superclass : #GRComponent,
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRControlInspector >> getMessageSendAt: aBlock for: aSymbol [

	| send |
	send := SBStMessageSend new.
	
	aBlock parentSandblock isCascade ifTrue: [
		aBlock parentSandblock childSandblocks do: [:s | s selector = aSymbol ifTrue: [^ s]].
		aBlock parentSandblock addMorphBack: send.
		^ send].
	
	aBlock parentSandblock isMessageSend ifTrue: [ | otherSend cascade |
		aBlock parentSandblock selector = aSymbol ifTrue: [^ aBlock parentSandblock].
		
		cascade := SBStCascade new.
		otherSend := aBlock parentSandblock.
		otherSend replaceBy: cascade.
		cascade receiver: aBlock messages: {otherSend. send}.
		^ send].
	
	send := SBStMessageSend new.
	aBlock replaceBy: send.
	^ send
]

{ #category : #'as yet unclassified' }
GRControlInspector >> render: props [

	| eventRef selected properties className popup update |
	eventRef := self useGodotRef.
	selected := self useState: nil.
	popup := self useGodotRef.
	update := self useForceUpdate.
	
	properties := self
		useMemo: [
			selected get
				ifNil: [{}]
				ifNotNil: [selected get getPropertyList collect: [:property | (property at: 'name') -> (selected get getProperty: (property at: 'name'))]]]
		dependencies: {selected get}.
	className := self useMemo: [selected get ifNotNil: [:s | s getClass]] dependencies: {selected get}.
	self
		useEffect: [
			selected get ifNotNil: [
				popup get
					rectPosition: 100 @ 100;
					show]]
		dependencies: {selected get}.
	
	GRReact enableCodeMapping ifFalse: [^ nil].
	
	^ {
		GRExternalEvents new
			onButton: [:pressed :button :position |
				(pressed and: [button = GDGlobalConstants buttonMiddle]) ifTrue: [
					((eventRef get grAsClass: #GRExternalEvents) controlsAtPosition: position) ifNotEmpty: [:objects | | object |
						object := objects last.
						selected set: object autoCast]]];
			ref: eventRef.
		selected get ifNotNil: [:o |
			GDWindowDialog new
				ref: popup;
				windowTitle: className;
				rectMinSize: 400 @ 200;
				visible: true;
				popupExclusive: false;
				onPopupHide: [selected set: nil];
				children: (GDScrollContainer new
					anchorRight: 1;
					anchorBottom: 1;
					children: (GDGridContainer new
						columns: 2;
						children: (properties gather: [:pair |
							{
								GDLabel new text: pair key.
								(pair value isKindOf: GDBaseObject)
									ifTrue: [GDLabel new text: pair value printString]
									ifFalse: [
										GDLineEdit new
											text: pair value storeString;
											onTextEntered: [:text |
												self saveProperty: pair key of: selected get withString: text.
												update value]]}])))]}
]

{ #category : #'as yet unclassified' }
GRControlInspector >> saveProperty: aSymbol of: anObject withString: aString [

	SBToggledCode comment: '' active: 1 do: {
		[ | location method constructor send selector |
			selector := GDApiObjectsGenerator squeakIdentifierName: aSymbol.
			location := CMFCurrentReact value codeLocationForNode: anObject.
			method := location second asSandblock.
			constructor := method blockForPC: location first.
			
			send := self getMessageSendAt: constructor for: selector asSimpleSetter.
			send
				receiver: (send isInCascade ifTrue: [nil] ifFalse: [constructor])
				selector: selector asSimpleSetter
				arguments: {aString parseAsSandblock}.
			method saveTryFixing: false quick: false].
		[anObject setProperty: aSymbol value: (Compiler evaluate: aString)]}
]
