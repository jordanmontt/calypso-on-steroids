"
I check what the browser selects while the user navigates: what it keeps, what it restores and what it drops. My subclasses run my tests on one browser each, through its driver.
"
Class {
	#name : 'ClySpSelectionTest',
	#superclass : 'ClySpBrowserTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpSelectionTest class >> isAbstract [

	^ self == ClySpSelectionTest
]

{ #category : 'tests - Selection drives the panes to its right' }
ClySpSelectionTest >> testClassPaneListsTheClassesOfTheSelectedPackage [

	| classA classB |
	classA := factory newClass.
	classB := factory newClass.
	browser openOnClass: ClyClass1FromP1Mock.

	browser selectPackage: classA package.

	self assert: browser shownClasses asSet equals: {
		classA.
		classB } asSet
]

{ #category : 'tests - Deselection' }
ClySpSelectionTest >> testDeselectingTheProtocolShowsAllMethods [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectProtocolNamed: 'beta'.
	self assert: browser shownMethods asArray equals: { (class >> #b) }.

	browser deselectProtocol.

	self assert: browser selectedProtocolNames isEmpty.
	self assert: browser shownMethods asArray equals: {
		(class >> #+).
		(class >> #a).
		(class >> #b) }
]

{ #category : 'tests - Selection drives the panes to its right' }
ClySpSelectionTest >> testGroupAndMethodPanesShowTheSelectedClass [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: factory newClass.

	browser selectClass: class.

	self assert: (browser shownProtocolNames includesAll: #( 'alpha' 'beta' )).
	self assert: browser shownMethods asArray equals: {
		(class >> #+).
		(class >> #a).
		(class >> #b) }
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testMethodComesBackAfterARoundTripToTheClassSide [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	browser switchToClassSide.
	browser switchToInstanceSide.

	self assert: browser selectedMethods equals: { (ClyClass1FromP1Mock >> #tag1Method1) }
]

{ #category : 'tests - Selection drives the panes to its right' }
ClySpSelectionTest >> testMethodPaneShowsOnlyTheMethodsOfTheSelectedProtocol [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.

	browser selectProtocolNamed: 'beta'.

	self assert: browser shownMethods asArray equals: { (class >> #b) }
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testPackageComesBackAfterProjectsMode [

	| package |
	package := ClyClass1FromP1Mock package.
	browser openOnClass: ClyClass1FromP1Mock.
	browser selectPackage: package.

	browser switchToProjects.
	self assert: browser selectedPackages isEmpty.

	browser switchToPackages.
	self assert: browser selectedPackages equals: { package }
]

{ #category : 'tests - Silent selection' }
ClySpSelectionTest >> testPackageOfAClassFollowsInHierarchyMode [

	browser openOnClass: ClyClass1FromP1Mock.
	browser switchToFullHierarchy.

	browser selectClass: ClySubclassMOfClass1FromP2Mock.

	self assert: browser selectedPackages equals: { ClySubclassMOfClass1FromP2Mock package }.
	self assert: (browser shownClasses includes: ProtoObject)
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testProtocolIsDroppedWhenChangingClass [
	"Unlike the other panes, the protocol pane never restores the user's selection"

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectProtocolNamed: 'tag1'.
	self assert: browser selectedProtocolNames asArray equals: #( 'tag1' ).

	browser selectClass: ClySubclassN1OfClass1FromP1Mock.

	self assert: browser selectedProtocolNames isEmpty.
	self assert: browser shownMethods asSet equals: ClySubclassN1OfClass1FromP1Mock methods asSet
]

{ #category : 'tests - Highlighting' }
ClySpSelectionTest >> testProtocolOfTheSelectedMethodIsHighlighted [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	self assert: (browser highlightedProtocolNames includes: 'tag1').
	self assert: browser selectedProtocolNames isEmpty
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testSameSelectorStaysSelectedWhenChangingClass [
	"Lets the user compare the implementations of one selector along a hierarchy"

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	browser selectClass: ClySubclassN1OfClass1FromP1Mock.

	self assert: browser selectedMethods equals: { (ClySubclassN1OfClass1FromP1Mock >> #tag1Method1) }
]

{ #category : 'tests - Selection survives item changes' }
ClySpSelectionTest >> testSelectionComesBackWhenTheMethodIsCompiledAgain [
	"The browser keeps what the user chose even while it is gone"

	| class |
	class := self newClassWithMethods: #( #x #y ).
	browser openOnClass: class.
	browser selectMethod: class >> #x.
	class removeSelector: #x.
	self assert: browser selectedMethods isEmpty.

	class compile: 'x ^ nil'.

	self assert: browser selectedMethods equals: { (class >> #x) }
]

{ #category : 'tests - Selection survives item changes' }
ClySpSelectionTest >> testSelectionIsDroppedWhenTheMethodIsRemovedElsewhere [

	| class |
	class := self newClassWithMethods: #( #x #y ).
	browser openOnClass: class.
	browser selectMethod: class >> #x.

	class removeSelector: #x.

	self assert: browser shownMethods equals: { (class >> #y) }.
	self assert: browser selectedMethods isEmpty
]

{ #category : 'tests - Selection survives item changes' }
ClySpSelectionTest >> testSelectionSurvivesAMethodAddedElsewhere [

	| class |
	class := self newClassWithMethods: #( #x #y ).
	browser openOnClass: class.
	browser selectMethod: class >> #x.

	class compile: 'z ^ nil'.

	self assert: (browser shownMethods includes: class >> #z).
	self assert: browser selectedMethods equals: { (class >> #x) }
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testSelectorComesBackAfterAClassWithoutIt [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	"Unselects the class"
	browser selectClass: ClyClass2FromP1Mock.
	self assert: browser selectedMethods isEmpty.

	browser selectClass: ClySubclassN1OfClass1FromP1Mock.
	self assert: browser selectedMethods equals: { (ClySubclassN1OfClass1FromP1Mock >> #tag1Method1) }
]
