"
I check going back and forward through what the user looked at, like in a web browser.
"
Class {
	#name : 'ClySpNavigationHistoryTest',
	#superclass : 'ClySpBrowserTest',
	#instVars : [
		'spawned'
	],
	#category : 'Calypso-Spec-Tests-Acceptance',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Acceptance'
}

{ #category : 'testing' }
ClySpNavigationHistoryTest class >> isAbstract [

	^ self == ClySpNavigationHistoryTest
]

{ #category : 'running' }
ClySpNavigationHistoryTest >> tearDown [

	spawned ifNotNil: [ spawned close ].
	super tearDown
]

{ #category : 'tests - What is a step' }
ClySpNavigationHistoryTest >> testAClickedTabIsAStep [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectTabTitled: 'Comment'.
	browser selectTabTitled: 'ClyClass1FromP1Mock'.

	browser goBack.

	self assert: browser selectedTabTitle equals: 'Comment'
]

{ #category : 'tests - Back and forward' }
ClySpNavigationHistoryTest >> testANewStepClearsForward [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectClass: ClyClass2FromP1Mock.
	browser goBack.
	self assert: browser selectedClasses equals: { ClyClass1FromP1Mock }.

	browser selectClass: ClySubclassN1OfClass1FromP1Mock.
	browser goForward.

	self assert: browser selectedClasses equals: { ClySubclassN1OfClass1FromP1Mock }
]

{ #category : 'tests - What is a step' }
ClySpNavigationHistoryTest >> testASystemChangeIsNoStep [

	| classA classB |
	classA := factory newClass.
	classB := factory newClass.
	browser openOnClass: classA.
	browser selectClass: classB.

	classB compile: 'z ^ nil'.
	self assert: (browser shownMethods includes: classB >> #z).
	browser goBack.

	self assert: browser selectedClasses equals: { classA }
]

{ #category : 'tests - Back and forward' }
ClySpNavigationHistoryTest >> testBackAndForwardBetweenTwoClasses [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectClass: ClyClass2FromP1Mock.

	browser goBack.
	self assert: browser selectedClasses equals: { ClyClass1FromP1Mock }.

	browser goForward.
	self assert: browser selectedClasses equals: { ClyClass2FromP1Mock }
]

{ #category : 'tests - Across windows' }
ClySpNavigationHistoryTest >> testBackDoesNothingWhenTheOriginalChangedSince [
	"Going back would return to the original browser as it was when this one was opened. The user changed the original since, so Calypso does nothing rather than undo that change."

	browser openOnClass: ClyClass1FromP1Mock.
	spawned := browser spawnBrowser.
	browser selectClass: ClyClass2FromP1Mock.

	spawned goBack.
	spawned goBack.

	self assert: spawned isOpen.
	self assert: browser selectedClasses equals: { ClyClass2FromP1Mock }
]

{ #category : 'tests - Across windows' }
ClySpNavigationHistoryTest >> testBackInASpawnedBrowserClosesIt [

	browser openOnClass: ClyClass1FromP1Mock.
	spawned := browser spawnBrowser.
	self assert: spawned isOpen.

	spawned goBack.

	self deny: spawned isOpen.
	self assert: browser isOpen
]

{ #category : 'tests - Across windows' }
ClySpNavigationHistoryTest >> testBackInASpawnedBrowserReopensTheClosedOriginal [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectClass: ClyClass2FromP1Mock.
	spawned := browser spawnBrowser.
	browser close.
	self deny: browser isOpen.

	spawned goBack.

	self assert: browser isOpen.
	self assert: browser selectedClasses equals: { ClyClass2FromP1Mock }
]

{ #category : 'tests - Back and forward' }
ClySpNavigationHistoryTest >> testBackReturnsToTheInstanceSide [

	browser openOnClass: ClyClass1FromP1Mock.
	browser switchToClassSide.
	self assert: browser showsClassSide.

	browser goBack.

	self deny: browser showsClassSide
]

{ #category : 'tests - Back and forward' }
ClySpNavigationHistoryTest >> testBackShowsTheEditorOfThePreviousMethod [

	browser openOnClass: ClySubclassN1OfClass1FromP1Mock.
	browser selectMethod: ClySubclassN1OfClass1FromP1Mock >> #tag1Method1.
	browser selectMethod: ClySubclassN1OfClass1FromP1Mock >> #tag1Method2.

	browser goBack.

	self assert: browser selectedMethods equals: { (ClySubclassN1OfClass1FromP1Mock >> #tag1Method1) }.
	self assert: browser editedMethod equals: ClySubclassN1OfClass1FromP1Mock >> #tag1Method1
]

{ #category : 'tests - States hold no query results' }
ClySpNavigationHistoryTest >> testBackShowsTheSystemAsItIsNow [

	| classA classB |
	classA := self newClassWithMethods: #( #x ).
	classB := factory newClass.
	browser openOnClass: classA.
	browser selectClass: classB.

	classA compile: 'y ^ nil'.
	browser goBack.

	self assert: browser selectedClasses equals: { classA }.
	self assert: (browser shownMethods includes: classA >> #y)
]

{ #category : 'tests - What is a step' }
ClySpNavigationHistoryTest >> testSelectingTheSameClassAgainIsNoStep [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectClass: ClyClass2FromP1Mock.

	browser selectClass: ClyClass2FromP1Mock.
	browser goBack.

	self assert: browser selectedClasses equals: { ClyClass1FromP1Mock }
]
