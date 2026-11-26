"
I check which tools the browser shows as tabs for what the user selects, and which tab is selected.
"
Class {
	#name : 'ClySpTabsTest',
	#superclass : 'ClySpBrowserTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpTabsTest class >> isAbstract [

	^ self == ClySpTabsTest
]

{ #category : 'tests - Tabs chosen from the selection' }
ClySpTabsTest >> testAClassShowsItsDefinitionCommentAndMethodCreation [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: factory newClass.

	browser selectClass: class.

	self assert: (browser tabTitles includesAll: {
		 class name.
		 'Comment'.
		 'Inst. side method' }).
	self deny: (browser tabTitles includesAny: #( 'a' 'b' '+' ))
]

{ #category : 'tests - Tabs chosen from the selection' }
ClySpTabsTest >> testAMethodAddsItsEditor [

	| class classTabs |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	classTabs := browser tabTitles asArray.

	browser selectMethod: class >> #a.

	self assert: (browser tabTitles includes: 'a').
	self assert: (browser tabTitles copyWithout: 'a') asArray equals: classTabs.
	self assert: browser editedMethod equals: class >> #a
]

{ #category : 'tests - Tabs chosen from the selection' }
ClySpTabsTest >> testAPackageShowsItsOwnTabs [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: ClyClass1FromP1Mock.

	browser selectPackage: class package.

	self assert: browser tabTitles asSet equals: #( 'Comment' 'Dependencies' 'New class' ) asSet
]

{ #category : 'tests - Tabs chosen from the selection' }
ClySpTabsTest >> testATestClassShowsItsSetUp [

	| testClass |
	testClass := self newTestClass.
	browser openOnClass: factory newClass.

	browser selectClass: testClass.
	self assert: (browser tabTitles includes: 'setUp').

	browser selectMethod: testClass >> #testOne.
	self assert: (browser tabTitles includesAll: #( 'setUp' 'testOne' )).

	browser selectMethod: testClass >> #setUp.
	self assert: (browser tabTitles count: [ :each | each = 'setUp' ]) equals: 1.
	self assert: browser editedMethod equals: testClass >> #setUp
]

{ #category : 'tests - Tabs chosen from the selection' }
ClySpTabsTest >> testTwoMethodsAddADiff [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.

	browser selectMethods: {
		(class >> #a).
		(class >> #b) }.

	self assert: (browser tabTitles includes: 'Diff')
]
