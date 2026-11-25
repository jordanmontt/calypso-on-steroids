"
I check what the browser selects while the user navigates: what it keeps, what it restores and what it drops. My subclasses run my tests on one browser each, through its driver.
"
Class {
	#name : 'ClySpSelectionTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'browser'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpSelectionTest class >> isAbstract [

	^ self == ClySpSelectionTest
]

{ #category : 'running' }
ClySpSelectionTest >> newBrowserDriver [

	^ self subclassResponsibility
]

{ #category : 'running' }
ClySpSelectionTest >> setUp [

	super setUp.
	browser := self newBrowserDriver
]

{ #category : 'running' }
ClySpSelectionTest >> tearDown [

	browser close.
	super tearDown
]

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testMethodComesBackAfterARoundTripToTheClassSide [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	browser switchToClassSide.
	browser switchToInstanceSide.

	self assert: browser selectedMethods equals: { (ClyClass1FromP1Mock >> #tag1Method1) }
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

{ #category : 'tests - Desired selection' }
ClySpSelectionTest >> testSameSelectorStaysSelectedWhenChangingClass [
	"Lets the user compare the implementations of one selector along a hierarchy"

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectMethod: ClyClass1FromP1Mock >> #tag1Method1.

	browser selectClass: ClySubclassN1OfClass1FromP1Mock.

	self assert: browser selectedMethods equals: { (ClySubclassN1OfClass1FromP1Mock >> #tag1Method1) }
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
