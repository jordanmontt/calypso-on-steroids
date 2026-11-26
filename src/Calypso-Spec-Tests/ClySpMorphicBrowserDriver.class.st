"
I drive the Morphic browser (ClyFullBrowserMorph) in the terms of a user, for the acceptance tests. I act as a user does: in the UI process, clicking the rows and tabs shown.

I hold the browser's window rather than the browser: going back to a closed browser reopens its window with a new browser in it.
"
Class {
	#name : 'ClySpMorphicBrowserDriver',
	#superclass : 'Object',
	#instVars : [
		'window'
	],
	#category : 'Calypso-Spec-Tests-Morphic driver',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Morphic driver'
}

{ #category : 'instance creation' }
ClySpMorphicBrowserDriver class >> onWindow: aWindow [

	^ self new setWindow: aWindow
]

{ #category : 'private' }
ClySpMorphicBrowserDriver >> answerConfirm: aBoolean [
	"Answers whether a confirm dialog was open"

	| dialog label |
	dialog := self currentWorld systemWindows detect: [ :each | each label = 'Please confirm' ] ifNone: [ ^ false ].
	label := aBoolean
		         ifTrue: [ SpConfirmDialog defaultAcceptLabel ]
		         ifFalse: [ SpConfirmDialog defaultCancelLabel ].
	(dialog model buttons detect: [ :each | each label = label ]) click.
	^ true
]

{ #category : 'running' }
ClySpMorphicBrowserDriver >> applyPendingUpdates [
	"A system change reaches the panes through Calypso's own update process, which may not have run yet. A user only acts once it has."

	| shownBrowser |
	shownBrowser := window ifNotNil: [ window model ].
	shownBrowser ifNil: [ ^ self ].
	shownBrowser navigationViews do: [ :each | each dataSource itemCursor ]
]

{ #category : 'accessing' }
ClySpMorphicBrowserDriver >> browser [
	"The browser shown in my window: going back to a closed browser reopens its window with a new browser"

	^ window model
]

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> close [
	"Discards unaccepted edits without asking: a test that leaves an editor dirty still closes its window"

	window ifNotNil: [ self inUIProcess: [ window deleteDiscardingChanges ] ]
]

{ #category : 'editing' }
ClySpMorphicBrowserDriver >> closeTabTitled: aString answeringDiscard: aBoolean [
	"Clicks the tab's close button, then Yes or No in the dialog asking to discard its edits. The dialog is modal: its own UI loop runs the click queued before it opened."

	self inUIProcess: [
		| tab answered |
		tab := (self toolTitled: aString) containerTab.
		answered := false.
		self currentWorld defer: [ answered := self answerConfirm: aBoolean ].
		self browser tabManager closeTab: tab.
		answered ifFalse: [ self error: 'Closing the tab asked nothing' ] ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> deselectProtocol [
	"As a cmd-click on the selected protocol: the table selection becomes empty."

	self inUIProcess: [ self browser methodGroupSelection beEmpty ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> editedMethod [
	"The method of the selected tab, which must be a method editor"

	^ self inUIProcess: [ self browser tabManager selectedTools first editingMethod ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> editorText [
	"The text of the selected tab's editor, accepted or not"

	^ self inUIProcess: [ self browser tabManager selectedTools first pendingText asString ]
]

{ #category : 'navigating' }
ClySpMorphicBrowserDriver >> goBack [

	self inUIProcess: [ self browser navigateBack ]
]

{ #category : 'navigating' }
ClySpMorphicBrowserDriver >> goForward [

	self inUIProcess: [ self browser navigateForward ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> highlightedProtocolNames [
	"The group pane keeps no readable highlighting: it is only in its table."

	^ self inUIProcess: [
		  | view |
		  view := self browser methodGroupView.
		  view table highlightedIndexes collect: [ :each | (view itemAt: each) name ] ]
]

{ #category : 'running' }
ClySpMorphicBrowserDriver >> inUIProcess: aBlock [
	"A click runs in the UI process, and Calypso updates its browsers there too. So aBlock runs there, and I wait until it is done. Run from the test's own process, it would clash with those updates."

	| call |
	self isInUIProcess ifTrue: [ ^ aBlock value ].
	call := ClySpUIProcessCall of: [
		        self applyPendingUpdates.
		        aBlock value ].
	self currentWorld defer: [ call run ].
	^ call waitForResult
]

{ #category : 'running' }
ClySpMorphicBrowserDriver >> isInUIProcess [

	^ Processor activeProcess == MorphicUIManager uiProcess
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> isOpen [

	^ self inUIProcess: [ window isInWorld ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> isTabOutOfContext: aString [
	"The tab shows the ! icon: its tool no longer matches the selection"

	^ self inUIProcess: [ (self toolTitled: aString) containerTab icon == (self iconNamed: #uncommentedClass) ]
]

{ #category : 'private' }
ClySpMorphicBrowserDriver >> keystroke: aCharacter at: aMorph [

	^ KeyboardEvent new
		  setType: #keystroke
		  buttons: 0
		  position: aMorph center
		  keyValue: aCharacter asInteger
		  charCode: aCharacter asInteger
		  hand: self currentWorld activeHand
		  stamp: Time millisecondClockValue
]

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> openOnClass: aClass [

	self inUIProcess: [ window := (ClyFullBrowserMorph openOnClass: aClass) window ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectClass: aClass [
	"Clicks the class in the class pane: the table selection changes first, as for a click. The browser's own selectClass: navigates instead: it may change the package and leave hierarchy mode."

	self inUIProcess: [
		| items |
		items := self browser classView findItemsWith: { aClass }.
		items ifEmpty: [ self error: aClass name , ' is not shown in the class pane' ].
		self browser classView table selectIndexes: (items collect: [ :each | each globalPosition ] as: Array) ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectMethod: aMethod [

	self inUIProcess: [ self browser selectMethod: aMethod ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectMethods: aCollection [
	"Clicks the methods in the method pane, the first then the others with cmd"

	self inUIProcess: [
		| items |
		items := self browser methodView findItemsWith: aCollection.
		items size = aCollection size ifFalse: [ self error: 'Not all the methods are shown in the method pane' ].
		self browser methodView table selectIndexes: (items collect: [ :each | each globalPosition ] as: Array) ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectPackage: aPackage [

	self inUIProcess: [ self browser selectPackage: aPackage ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectProtocolNamed: aString [

	self inUIProcess: [ self browser selectMethodGroupNamed: aString ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectTabTitled: aString [
	"Clicks the tab: its selector changes first, as for a click"

	self inUIProcess: [
		| notebook index |
		notebook := self browser tabManager tabMorph.
		index := notebook pages findFirst: [ :each | each label = aString ].
		index = 0 ifTrue: [ self error: 'No tab titled ' , aString ].
		notebook tabSelectorMorph selectedIndex: index ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedClasses [

	^ self inUIProcess: [ self browser classSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedMethods [

	^ self inUIProcess: [ self browser methodSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedPackages [

	^ self inUIProcess: [ self browser packageSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedProtocolNames [

	^ self inUIProcess: [ self browser methodGroupSelection items collect: [ :each | each name ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedTabTitle [
	"The tab of the tool shown: after going back, the tab selector's index is not kept up to date"

	^ self inUIProcess: [ self browser tabManager tabMorph page containerTab label ]
]

{ #category : 'initialization' }
ClySpMorphicBrowserDriver >> setWindow: aWindow [

	window := aWindow
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownClasses [

	^ self inUIProcess: [ self browser classView dataSource allElements collect: [ :each | each actualObject ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownMethods [

	^ self inUIProcess: [ self browser methodView dataSource allElements collect: [ :each | each actualObject ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownProtocolNames [

	^ self inUIProcess: [ self browser methodGroupView dataSource allElements collect: [ :each | each name ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> showsClassSide [

	^ self inUIProcess: [ self browser metaLevelScope = ClyClassSideScope ]
]

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> spawnBrowser [
	"As a double click on the selected class: a new browser on it, which can go back to this one"

	^ self class onWindow: (self inUIProcess: [ self browser spawnFullBrowser window ])
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToClassSide [

	self inUIProcess: [ self browser switchToMetaLevelScope: ClyClassSideScope ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToFullHierarchy [

	self inUIProcess: [ self browser switchToFullClassHierarchy ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToInstanceSide [

	self inUIProcess: [ self browser switchToMetaLevelScope: ClyInstanceSideScope ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToPackages [

	self inUIProcess: [ self browser switchToPackages ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToProjects [

	self inUIProcess: [ self browser switchToProjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> tabTitles [

	^ self inUIProcess: [ self browser tabManager tabMorph pages collect: [ :each | each label ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> toolTitled: aString [
	"The tool behind the tab, to check whether it is kept or rebuilt"

	^ self inUIProcess: [ self browser tabManager tools detect: [ :each | each containerTab label = aString ] ]
]

{ #category : 'editing' }
ClySpMorphicBrowserDriver >> type: aString [
	"Types in the selected tab's editor, one key at a time, without accepting"

	self inUIProcess: [
		| textArea |
		textArea := self browser tabManager selectedTools first textMorph textArea.
		aString do: [ :each | (self keystroke: each at: textArea) sentTo: textArea ] ]
]
