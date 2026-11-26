"
I check going back and forward through what the user looked at, like in a web browser.
"
Class {
	#name : 'ClySpNavigationHistoryTest',
	#superclass : 'ClySpBrowserTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpNavigationHistoryTest class >> isAbstract [

	^ self == ClySpNavigationHistoryTest
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

{ #category : 'tests - Back and forward' }
ClySpNavigationHistoryTest >> testBackAndForwardBetweenTwoClasses [

	browser openOnClass: ClyClass1FromP1Mock.
	browser selectClass: ClyClass2FromP1Mock.

	browser goBack.
	self assert: browser selectedClasses equals: { ClyClass1FromP1Mock }.

	browser goForward.
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
