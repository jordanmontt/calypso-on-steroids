"
I list every command of the Calypso browser and where it appears (menus, shortcuts, toolbar, tabs, clicks, drag and drop), as a Markdown page. I read the command maps of ClyCommandRegistry, so the page shows what the image really offers. I am a development tool of the Spec Calypso project and never ship with it.
"
Class {
	#name : 'CosCommandCatalogue',
	#superclass : 'Object',
	#instVars : [
		'entries'
	],
	#category : 'CalypsoOnSteroids-Inventory',
	#package : 'CalypsoOnSteroids-Inventory'
}

{ #category : 'instance creation' }
CosCommandCatalogue class >> entries: aCollection [

	^ self new setEntries: aCollection
]

{ #category : 'instance creation' }
CosCommandCatalogue class >> ofImage [

	| allEntries |
	allEntries := ClyCommandRegistry declaredAnchors
		              flatCollect: [ :anchor | (ClyCommandMap forAnchor: anchor) allEntries ]
		              as: OrderedCollection.
	"Test packages declare mock commands that the browser never shows"
	^ self entries: (allEntries reject: [ :each | each declaringMethod package name includesSubstring: 'Tests' ])
]

{ #category : 'private' }
CosCommandCatalogue >> anchors [

	^ (entries collect: [ :each | each anchor ] as: Set) asArray sorted: [ :first :second | first name <= second name ]
]

{ #category : 'private' }
CosCommandCatalogue >> entriesOf: anAnchor [

	^ (entries select: [ :each | each anchor = anAnchor ]) asArray sorted: [ :first :second |
		  first interaction name < second interaction name or: [
			  first interaction name = second interaction name and: [ first commandClass name <= second commandClass name ] ] ]
]

{ #category : 'private' }
CosCommandCatalogue >> groupOf: anEntry [

	^ anEntry menuGroup = ClyRootMenuGroup
		  ifTrue: [ '' ]
		  ifFalse: [ '`' , anEntry menuGroup name , '`' ]
]

{ #category : 'private' }
CosCommandCatalogue >> labelOf: anEntry [

	anEntry label ifNotNil: [ :label | ^ label ].
	"Tabs and table decorators are tools, not commands: they have no label"
	(anEntry commandClass inheritsFrom: CmCommand) ifFalse: [ ^ '—' ].
	"Some commands compute their label from the browser's selection, and a catalogue has no browser"
	^ [ anEntry menuItemNameFor: anEntry commandClass new ]
		  on: Error
		  do: [ '—' ]
]

{ #category : 'writing' }
CosCommandCatalogue >> markdown [

	^ String streamContents: [ :stream |
		  self writeHeaderOn: stream.
		  self writeCountsOn: stream.
		  self anchors do: [ :each | self writeAnchor: each on: stream ].
		  self writeRegeneratingOn: stream ]
]

{ #category : 'initialization' }
CosCommandCatalogue >> setEntries: aCollection [

	entries := aCollection
]

{ #category : 'private' }
CosCommandCatalogue >> triggerOf: anEntry [
	"Only these kinds of entries have a trigger, each of its own kind"

	(anEntry isKindOf: ClyShortcutCommandEntry) ifTrue: [ ^ anEntry keyCombination printString ].
	(anEntry isKindOf: ClyDropCommandEntry) ifTrue: [ ^ 'drop on ' , anEntry dropAnchor name ].
	(anEntry isKindOf: ClyMouseCommandEntry) ifTrue: [ ^ 'button ' , anEntry mouseButton printString ].
	^ ''
]

{ #category : 'private' }
CosCommandCatalogue >> writeAnchor: anAnchor on: aStream [

	aStream
		cr;
		nextPutAll: '## `';
		nextPutAll: anAnchor name;
		nextPutAll: '`';
		cr;
		cr;
		nextPutAll: '| Interaction | Command / tool | Group | Order | Label | Trigger | Declared in |';
		cr;
		nextPutAll: '|---|---|---|---|---|---|---|';
		cr.
	(self entriesOf: anAnchor) do: [ :each | self writeEntry: each on: aStream ]
]

{ #category : 'private' }
CosCommandCatalogue >> writeCountsOn: aStream [

	| counts |
	counts := (entries collect: [ :each | each interaction name ]) asBag.
	aStream
		nextPutAll: '| Interaction | Entries |';
		cr;
		nextPutAll: '|---|---|';
		cr.
	(counts asSet asArray sorted: [ :first :second |
		 (counts occurrencesOf: first) > (counts occurrencesOf: second) or: [
			 (counts occurrencesOf: first) = (counts occurrencesOf: second) and: [ first <= second ] ] ]) do: [ :each |
			aStream
				nextPutAll: '| `';
				nextPutAll: each;
				nextPutAll: '` | ';
				print: (counts occurrencesOf: each);
				nextPutAll: ' |';
				cr ].
	aStream
		cr;
		nextPutAll:
			'Columns: **Interaction** (how the entry is reached), **Command / tool**, **Group** (menu or toolbar group), **Order**, **Label** (as shown; `—` when the label is computed from the context at run time), **Trigger** (key combination, mouse button or drop target), **Declared in**.';
		cr
]

{ #category : 'private' }
CosCommandCatalogue >> writeEntry: anEntry on: aStream [

	aStream
		nextPutAll: '| ';
		nextPutAll: anEntry interaction name;
		nextPutAll: ' | `';
		nextPutAll: anEntry commandClass name;
		nextPutAll: '` | ';
		nextPutAll: (self groupOf: anEntry);
		nextPutAll: ' | ';
		nextPutAll: (anEntry order ifNil: [ '' ] ifNotNil: [ :order | order printString ]);
		nextPutAll: ' | ';
		nextPutAll: (self labelOf: anEntry);
		nextPutAll: ' | ';
		nextPutAll: (self triggerOf: anEntry);
		nextPutAll: ' | `';
		nextPutAll: anEntry declaringMethod printString;
		nextPutAll: '` |';
		cr
]

{ #category : 'private' }
CosCommandCatalogue >> writeHeaderOn: aStream [

	aStream
		nextPutAll: '# Calypso command catalogue (generated)';
		cr;
		cr;
		nextPutAll:
			'Generated by `CosCommandCatalogue` from every `<calypsoCommands>` declaration of the image (`ClyCommandMap forAnchor:`), except those of test packages. **Do not edit by hand**: regenerate it (see the bottom of this file).';
		cr;
		cr;
		print: entries size;
		nextPutAll: ' entries, ';
		print: self anchors size;
		nextPutAll: ' anchors.';
		cr;
		cr
]

{ #category : 'private' }
CosCommandCatalogue >> writeRegeneratingOn: aStream [

	aStream
		cr;
		nextPutAll: '## Regenerating this file';
		cr;
		cr;
		nextPutAll: 'In the development image, with the `dev` group of `BaselineOfCalypsoOnSteroids` loaded:';
		cr;
		cr;
		nextPutAll: '```smalltalk';
		cr;
		nextPutAll: 'CosCommandCatalogue ofImage writeTo: ''docs/features/command-catalogue.md'' asFileReference';
		cr;
		nextPutAll: '```';
		cr
]

{ #category : 'writing' }
CosCommandCatalogue >> writeTo: aFileReference [

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream | stream nextPutAll: self markdown ]
]
