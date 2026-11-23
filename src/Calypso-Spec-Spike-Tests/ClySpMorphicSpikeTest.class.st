"
I find out what a test can drive in the Morphic browser through its API: selection, pane contents, tabs, context menus and shortcuts. I am a spike, to be removed once the browser drivers exist.
"
Class {
	#name : 'ClySpMorphicSpikeTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'browser',
		'factory',
		'class'
	],
	#category : 'Calypso-Spec-Spike-Tests',
	#package : 'Calypso-Spec-Spike-Tests'
}

{ #category : 'private' }
ClySpMorphicSpikeTest >> entryLabelled: aString in: aMenu [

	^ aMenu items detect: [ :each | each contents asString = aString ]
]

{ #category : 'private' }
ClySpMorphicSpikeTest >> methodNames [

	^ browser methodView dataSource allElements collect: [ :each | each browserItem name ]
]

{ #category : 'private' }
ClySpMorphicSpikeTest >> press: aCharacter alt: aBoolean in: aMorph [

	| event |
	event := KeyboardEvent new
		         setType: #keyDown
		         buttons: (aBoolean
			          ifTrue: [ 2r00100000 ]
			          ifFalse: [ 0 ])
		         position: aMorph center
		         keyValue: aCharacter asInteger
		         charCode: aCharacter asInteger
		         hand: self currentWorld activeHand
		         stamp: Time millisecondClockValue.
	event key: (KeyboardKey fromCharacter: aCharacter).
	event sentTo: aMorph
]

{ #category : 'running' }
ClySpMorphicSpikeTest >> setUp [

	super setUp.
	factory := ClassFactoryForTestCase environment: Smalltalk globals.
	class := factory newClass.
	class compile: 'foo ^ 1'.
	class compile: 'bar ^ 2'.
	browser := ClyFullBrowserMorph openOnClass: class
]

{ #category : 'running' }
ClySpMorphicSpikeTest >> tearDown [

	browser window close.
	factory cleanUp.
	super tearDown
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testBrowseInTheMenuOfAMethodOpensABrowserOnIt [

	| menu browseEntry newWindows newBrowser |
	browser selectMethod: class >> #foo.

	"Simulate a right click on the 'foo' method in the method pane and selects the option 'Browse'."
	menu := browser methodView menuColumn: nil row: (self methodNames indexOf: 'foo').
	browseEntry := self entryLabelled: 'Browse' in: menu.

	newWindows := self windowsOpenedBy: [ browseEntry doButtonAction ].

	self assert: newWindows size equals: 1.
	newBrowser := newWindows first model.
	self assert: newBrowser methodSelection actualObjects equals: { (class >> #foo) }.
	newWindows first close
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testReadsPaneContents [

	self assert: self methodNames asSet equals: #( 'foo' 'bar' ) asSet
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testReadsTabs [

	browser selectMethod: class >> #foo.
	self assert: ((browser tabManager tools collect: [ :each | each class ]) includes: ClyMethodCodeEditorToolMorph)
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testRunsAShortcut [

	browser selectMethod: class >> #foo.
	browser selectMethod: class >> #bar.
	self press: Character arrowLeft alt: true in: browser methodView table.
	self assert: browser methodSelection actualObjects equals: { (class >> #foo) }
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testSeesSystemChangesWithoutWaiting [

	class compile: 'baz ^ 3'.
	self assert: (self methodNames includes: 'baz')
]

{ #category : 'tests' }
ClySpMorphicSpikeTest >> testSelectsInEachPane [

	browser selectMethod: class >> #foo.
	self assert: browser packageSelection actualObjects equals: { class package }.
	self assert: browser classSelection actualObjects equals: { class }.
	self assert: browser methodSelection actualObjects equals: { (class >> #foo) }
]

{ #category : 'private' }
ClySpMorphicSpikeTest >> windowsOpenedBy: aBlock [

	| windowsBeforeBlock |
	windowsBeforeBlock := self currentWorld systemWindows.
	aBlock value.
	^ self currentWorld systemWindows copyWithoutAll: windowsBeforeBlock
]
