Class {
	#name : #GRControlInspector,
	#superclass : #GRComponent,
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRControlInspector >> render: props [

	| eventRef selected properties className popup |
	eventRef := self useGodotRef.
	selected := self useState: nil.
	popup := self useGodotRef.
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
					((eventRef get grAsClass: #GRExternalEvents) controlsAtPosition: position) ifNotEmpty: [:objects | | path hostConfig object |
						object := objects last.
						selected set: object autoCast.
						path := (object grAsClass: #GDControl) getPath.
						hostConfig := CMFCurrentReact value hostConfig.
						
						CMFCurrentReact value codeLocations associations
							detect: [:location | '/root/GRRoot', (hostConfig fullPathFor: location key) = path]
							ifFound: [:location | location value]
							ifNone: [nil]]]];
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
						children: (properties gather: [:pair | {GDLabel new text: pair key. GDLabel new text: pair value printString}])))]}
]
