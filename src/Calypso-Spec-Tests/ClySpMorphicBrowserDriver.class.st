"
I drive the Morphic browser (ClyFullBrowserMorph) in the terms of a user, for the acceptance tests. I go through the browser API, which selects like a click does: a selection I make counts as the user's.
"
Class {
	#name : 'ClySpMorphicBrowserDriver',
	#superclass : 'Object',
	#instVars : [
		'browser'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> close [

	browser ifNotNil: [ self inUIProcess: [ browser window close ] ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> deselectProtocol [
	"As a cmd-click on the selected protocol: the table selection becomes empty."

	self inUIProcess: [ browser methodGroupSelection beEmpty ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> editedMethod [
	"The method of the selected tab, which must be a method editor"

	^ self inUIProcess: [ browser tabManager selectedTools first editingMethod ]
]

{ #category : 'navigating' }
ClySpMorphicBrowserDriver >> goBack [

	self inUIProcess: [ browser navigateBack ]
]

{ #category : 'navigating' }
ClySpMorphicBrowserDriver >> goForward [

	self inUIProcess: [ browser navigateForward ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> highlightedProtocolNames [
	"The group pane keeps no readable highlighting: it is only in its table."

	^ self inUIProcess: [
		  | view |
		  view := browser methodGroupView.
		  view table highlightedIndexes collect: [ :each | (view itemAt: each) name ] ]
]

{ #category : 'running' }
ClySpMorphicBrowserDriver >> inUIProcess: aBlock [
	"A click runs in the UI process, and Calypso updates its browsers there too. So aBlock runs there, and I wait until it is done. Run from the test's own process, it would clash with those updates."

	| call |
	self isInUIProcess ifTrue: [ ^ aBlock value ].
	call := ClySpUIProcessCall of: aBlock.
	self currentWorld defer: [ call run ].
	^ call waitForResult
]

{ #category : 'running' }
ClySpMorphicBrowserDriver >> isInUIProcess [

	^ Processor activeProcess == MorphicUIManager uiProcess
]

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> openOnClass: aClass [

	self inUIProcess: [ browser := ClyFullBrowserMorph openOnClass: aClass ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectClass: aClass [
	"Clicks the class in the class pane: the table selection changes first, as for a click. The browser's own selectClass: navigates instead: it may change the package and leave hierarchy mode."

	self inUIProcess: [
		| items |
		items := browser classView findItemsWith: { aClass }.
		items ifEmpty: [ self error: aClass name , ' is not shown in the class pane' ].
		browser classView table selectIndexes: (items collect: [ :each | each globalPosition ] as: Array) ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectMethod: aMethod [

	self inUIProcess: [ browser selectMethod: aMethod ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectPackage: aPackage [

	self inUIProcess: [ browser selectPackage: aPackage ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectProtocolNamed: aString [

	self inUIProcess: [ browser selectMethodGroupNamed: aString ]
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectTabTitled: aString [
	"Clicks the tab: its selector changes first, as for a click"

	self inUIProcess: [
		| notebook index |
		notebook := browser tabManager tabMorph.
		index := notebook pages findFirst: [ :each | each label = aString ].
		index = 0 ifTrue: [ self error: 'No tab titled ' , aString ].
		notebook tabSelectorMorph selectedIndex: index ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedClasses [

	^ self inUIProcess: [ browser classSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedMethods [

	^ self inUIProcess: [ browser methodSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedPackages [

	^ self inUIProcess: [ browser packageSelection actualObjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedProtocolNames [

	^ self inUIProcess: [ browser methodGroupSelection items collect: [ :each | each name ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedTabTitle [
	"The tab of the tool shown: after going back, the tab selector's index is not kept up to date"

	^ self inUIProcess: [ browser tabManager tabMorph page containerTab label ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownClasses [

	^ self inUIProcess: [ browser classView dataSource allElements collect: [ :each | each actualObject ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownMethods [

	^ self inUIProcess: [ browser methodView dataSource allElements collect: [ :each | each actualObject ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownProtocolNames [

	^ self inUIProcess: [ browser methodGroupView dataSource allElements collect: [ :each | each name ] ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> showsClassSide [

	^ self inUIProcess: [ browser metaLevelScope = ClyClassSideScope ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToClassSide [

	self inUIProcess: [ browser switchToMetaLevelScope: ClyClassSideScope ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToFullHierarchy [

	self inUIProcess: [ browser switchToFullClassHierarchy ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToInstanceSide [

	self inUIProcess: [ browser switchToMetaLevelScope: ClyInstanceSideScope ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToPackages [

	self inUIProcess: [ browser switchToPackages ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToProjects [

	self inUIProcess: [ browser switchToProjects ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> tabTitles [

	^ self inUIProcess: [ browser tabManager tabMorph pages collect: [ :each | each label ] ]
]
