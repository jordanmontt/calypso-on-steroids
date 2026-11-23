Class {
	#name : 'CosCommandCatalogueTest',
	#superclass : 'TestCase',
	#category : 'CalypsoOnSteroids-Inventory-Tests',
	#package : 'CalypsoOnSteroids-Inventory-Tests'
}

{ #category : 'running' }
CosCommandCatalogueTest >> markdown [

	^ (CosCommandCatalogue entries: (ClyCommandMap forAnchor: CosCatalogueTestAnchor) allEntries) markdown
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testATabHasNoLabel [

	self assert: (self markdown includesSubstring: '| tabs | `ClyMethodCodeEditorToolMorph` |  |  | — |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testCatalogueOfTheImageLeavesOutTestPackages [

	| markdown |
	markdown := CosCommandCatalogue ofImage markdown.
	self assert: (markdown includesSubstring: '`ClySpawnFullBrowserCommand`').
	self deny: (markdown includesSubstring: 'CosCatalogueTestAnchor')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testCommittedCatalogueMatchesTheImage [

	self
		assert: CosCommandCatalogue committedFile contents = CosCommandCatalogue ofImage markdown
		description:
		'The commands of Calypso changed: regenerate docs/features/command-catalogue.md as its last section says, and commit it'
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testCountsEntriesByInteraction [

	self assert: (self markdown includesSubstring: '8 entries, 1 anchors.').
	self assert: (self markdown includesSubstring: '| `shortcuts` | 1 |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testEndsLinesWithLineFeeds [

	self deny: (self markdown includes: Character cr)
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testGroupsEntriesByAnchor [

	self assert: (self markdown includesSubstring: '## `CosCatalogueTestAnchor`')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testRowOfAMenuEntry [

	self assert: (self markdown includesSubstring:
		 '| contextMenu | `ClySpawnFullBrowserCommand` | `ClyQueryMenuGroup` | 10 | Browse |  | `CosCatalogueTestAnchor class>>#inventoryTestCommandsIn:` |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testSortsEntriesByInteractionGroupOrderAndCommand [

	| rows |
	rows := (self markdown lines select: [ :each | each beginsWith: '| contextMenu |' ]) collect: [ :each |
		        (each substrings: '|') second trimBoth ].
	self
		assert: rows asArray
		equals: #( '`ClySpawnFullBrowserCommand`' '`ClyCloseBrowserCommand`' '`SycCopyClassNameCommand`' '`SycFileOutClassCommand`' )
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testTheDefaultGroupIsLeftBlank [

	self assert: (self markdown includesSubstring: '| shortcuts | `ClyCloseBrowserCommand` |  |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testTriggerOfAClickIsItsButton [

	self assert: (self markdown includesSubstring: '| button #red |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testTriggerOfADropIsWhereItDrops [

	self assert: (self markdown includesSubstring: '| drop on ClyNoTagClassGroup |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testTriggerOfAShortcutIsItsKeyCombination [

	self assert: (self markdown includesSubstring: '| Meta + W |')
]

{ #category : 'tests' }
CosCommandCatalogueTest >> testWritesTheMarkdownToAFile [

	| file catalogue |
	file := FileSystem memory / 'catalogue.md'.
	catalogue := CosCommandCatalogue entries: (ClyCommandMap forAnchor: CosCatalogueTestAnchor) allEntries.
	catalogue writeTo: file.
	self assert: file contents equals: catalogue markdown
]
