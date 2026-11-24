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

{ #category : 'accessing' }
CosCommandCatalogue class >> committedFile [

	^ CosCheckout root / 'docs' / 'features' / 'command-catalogue.md'
]

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

	^ (entries select: [ :each | each anchor = anAnchor ]) asArray sorted: [ :first :second | self entry: first comesBefore: second ]
]

{ #category : 'private' }
CosCommandCatalogue >> entry: anEntry comesBefore: anotherEntry [
	"The order of the menus: by group, then by the order within the group, then by name"

	| keys otherKeys |
	keys := self sortKeysOf: anEntry.
	otherKeys := self sortKeysOf: anotherEntry.
	keys with: otherKeys do: [ :key :otherKey | key = otherKey ifFalse: [ ^ key < otherKey ] ].
	^ true
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
CosCommandCatalogue >> sortKeysOf: anEntry [

	^ {
		  anEntry interaction name.
		  anEntry menuGroup name.
		  (anEntry order ifNil: [ 0 ]).
		  anEntry commandClass name.
		  anEntry declaringMethod printString }
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
		lf;
		nextPutAll: '## `';
		nextPutAll: anAnchor name;
		nextPutAll: '`';
		lf;
		lf;
		nextPutAll: '| Interaction | Command / tool | Group | Order | Label | Trigger | Declared in |';
		lf;
		nextPutAll: '|---|---|---|---|---|---|---|';
		lf.
	(self entriesOf: anAnchor) do: [ :each | self writeEntry: each on: aStream ]
]

{ #category : 'private' }
CosCommandCatalogue >> writeCountsOn: aStream [

	| counts |
	counts := (entries collect: [ :each | each interaction name ]) asBag.
	aStream
		nextPutAll: '| Interaction | Entries |';
		lf;
		nextPutAll: '|---|---|';
		lf.
	(counts asSet asArray sorted: [ :first :second |
		 (counts occurrencesOf: first) > (counts occurrencesOf: second) or: [
			 (counts occurrencesOf: first) = (counts occurrencesOf: second) and: [ first <= second ] ] ]) do: [ :each |
			aStream
				nextPutAll: '| `';
				nextPutAll: each;
				nextPutAll: '` | ';
				print: (counts occurrencesOf: each);
				nextPutAll: ' |';
				lf ].
	aStream
		lf;
		nextPutAll:
			'Columns: **Interaction** (how the entry is reached), **Command / tool**, **Group** (menu or toolbar group), **Order**, **Label** (as shown; `—` when the label is computed from the context at run time), **Trigger** (key combination, mouse button or drop target), **Declared in**.';
		lf
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
		lf
]

{ #category : 'private' }
CosCommandCatalogue >> writeHeaderOn: aStream [

	aStream
		nextPutAll: '# Calypso command catalogue (generated)';
		lf;
		lf;
		nextPutAll:
			'Generated by `CosCommandCatalogue` from every `<calypsoCommands>` declaration of the image (`ClyCommandMap forAnchor:`), except those of test packages. **Do not edit by hand**: regenerate it (see the bottom of this file).';
		lf;
		lf;
		print: entries size;
		nextPutAll: ' entries, ';
		print: self anchors size;
		nextPutAll: ' anchors.';
		lf;
		lf
]

{ #category : 'private' }
CosCommandCatalogue >> writeRegeneratingOn: aStream [

	aStream
		lf;
		nextPutAll: '## Regenerating this file';
		lf;
		lf;
		nextPutAll: 'In the development image, with the `dev` group of `BaselineOfCalypsoOnSteroids` loaded:';
		lf;
		lf;
		nextPutAll: '```smalltalk';
		lf;
		nextPutAll: 'CosCommandCatalogue ofImage writeTo: CosCommandCatalogue committedFile';
		lf;
		nextPutAll: '```';
		lf;
		lf;
		nextPutAll:
			'Every week, the CI workflow "Command catalogue" runs `CosCommandCatalogueCheck`, which fails and lists the changed lines when this file no longer matches the latest Pharo 15. The build does not depend on it.';
		lf
]

{ #category : 'writing' }
CosCommandCatalogue >> writeTo: aFileReference [

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream | stream nextPutAll: self markdown ]
]
