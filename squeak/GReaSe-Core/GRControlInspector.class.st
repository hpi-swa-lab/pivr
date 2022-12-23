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

	| eventRef selected properties className |
	eventRef := self useGodotRef.
	
	selected := self useState: nil.
	properties := self useState: OrderedDictionary new.
	
	self
		useEffect: [
			properties set: (selected get ifNil: [OrderedDictionary new] ifNotNil: [
				selected get getPropertyList
					collect: [:property | (property at: 'name') -> (selected get getProperty: (property at: 'name'))]
					as: OrderedDictionary])]
		dependencies: {selected get ifNotNil: #objectId}.
	className := self
		useMemo: [selected get ifNotNil: [:s | s getClass]]
		dependencies: {selected get ifNotNil: #objectId}.
	
	GRReact enableCodeMapping ifFalse: [^ nil].
	
	^ {
		GRExternalEvents new
			onButton: [:pressed :button :position |
				(pressed and: [button = GDGlobalConstants buttonMiddle]) ifTrue: [
					((eventRef get grAsClass: #GRExternalEvents) controlsAtPosition: position)
						ifNotEmpty: [:objects | selected set: objects last autoCast]
						ifEmpty: [selected set: nil]]];
			ref: eventRef.
		selected get ifNotNil: [
			{
				(self methodAsComponent: #renderHalo:)
					selected: selected get;
					setProperties: properties setter.
				(self methodAsComponent: #renderPopup:)
					className: className;
					properties: properties get;
					onChangeProperty: [:prop :code | | value |
						value := self saveProperty: prop of: selected get withString: code.
						properties set: [:old | old copyAt: prop put: value]];
					selected: selected get;
					onDeselect: [selected set: nil]}]}
]

{ #category : #'as yet unclassified' }
GRControlInspector >> renderHalo: props [

	^ props extract: [:selected :setProperties | | rect dragging |
		rect := self useMemo: [selected getGlobalRect] dependencies: {selected objectId}.
		dragging := self useState: false.
		{
			GDButton new
				rectPosition: rect topLeft;
				onButtonDown: [dragging set: true];
				onButtonUp: [dragging set: false].
			dragging get ifTrue: [
				GRExternalEvents new subscribeToRelativeMouseMotion: [:delta | | newValue |
					setProperties value: [:old |
						newValue := (old at: #'rect_position') + delta.
						old copyAt: #'rect_position' put: newValue].
					self saveProperty: #'rect_position' of: selected withString: newValue storeString]]}]
]

{ #category : #'as yet unclassified' }
GRControlInspector >> renderPopup: props [

	^ props extract: [:className :selected :onDeselect :properties :onChangeProperty | | popup |
		popup := self useGodotRef.
		self
			useEffect: [
				selected ifNotNil: [
					popup get
						rectPosition: 100 @ 100;
						show.
					popup get getCloseButton hide]]
			dependencies: {selected}.
		
		GDWindowDialog new
			ref: popup;
			windowTitle: className;
			rectMinSize: 400 @ 200;
			visible: true;
			popupExclusive: false;
			onPopupHide: [onDeselect value];
			children: (GDScrollContainer new
				anchorRight: 1;
				anchorBottom: 1;
				children: (GDGridContainer new
					columns: 2;
					children: (properties associations gather: [:pair |
						{
							GDLabel new text: pair key.
							(pair value isKindOf: GDBaseObject)
								ifTrue: [GDLabel new text: pair value printString]
								ifFalse: [
									GDLineEdit new
										text: pair value storeString;
										onTextEntered: [:text | onChangeProperty value: pair key value: text]]}])))]
]

{ #category : #'as yet unclassified' }
GRControlInspector >> saveProperty: aSymbol of: anObject withString: aString [

	^ SBToggledCode comment: '' active: 1 do: {
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
			method saveTryFixing: false quick: false.
			Compiler evaluate: aString].
		[anObject setProperty: aSymbol value: (Compiler evaluate: aString)]}
]
