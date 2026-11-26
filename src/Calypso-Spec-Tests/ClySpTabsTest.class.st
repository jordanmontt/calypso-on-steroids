"
I check which tools the browser shows as tabs for what the user selects, and which tab is selected.
"
Class {
	#name : 'ClySpTabsTest',
	#superclass : 'ClySpBrowserTest',
	#category : 'Calypso-Spec-Tests-Acceptance',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Acceptance'
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

{ #category : 'tests - Which tab is selected' }
ClySpTabsTest >> testAClickedTabStaysSelectedForTheNextClass [
	"The user's choice of tab wins over the default one"

	| classA classB |
	classA := factory newClass.
	classB := factory newClass.
	browser openOnClass: classA.
	browser selectTabTitled: classA name.
	self assert: browser selectedTabTitle equals: classA name.

	browser selectClass: classB.

	self assert: browser selectedTabTitle equals: classB name
]

{ #category : 'tests - Tabs close when their model is removed' }
ClySpTabsTest >> testADirtyEditorStaysMarkedDirtyWhenItsClassIsRemoved [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	browser typeInSelectedTab: ' ^ 1'.

	browser changeSystemBy: [ factory delete: class ].

	self assert: (browser tabTitles includes: '*a')
]

{ #category : 'tests - Tabs close when their model is removed' }
ClySpTabsTest >> testADirtyEditorStaysWhenItsClassIsRemoved [
	"The user would lose their edits otherwise"

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	browser typeInSelectedTab: ' ^ 1'.

	browser changeSystemBy: [ factory delete: class ].

	self assert: (browser tabTitles includes: 'a').
	self assert: (browser isTabOutOfContext: 'a').
	self assert: ((browser textOfTabTitled: 'a') includesSubstring: ' ^ 1')
]

{ #category : 'tests - Dirty tabs stay' }
ClySpTabsTest >> testADirtyEditorStaysWhenSelectingAnotherMethod [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	browser typeInSelectedTab: ' ^ 1'.

	browser selectMethod: class >> #b.

	self assert: (browser tabTitles includesAll: #( '*a' 'b' )).
	self assert: (browser isTabOutOfContext: '*a').
	self assert: browser selectedTabTitle equals: 'b'
]

{ #category : 'tests - Dirty tabs stay' }
ClySpTabsTest >> testADirtyTabStaysWhenIRefuseToDiscardItsEdits [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	browser typeInSelectedTab: ' ^ 1'.

	browser closeTabTitled: '*a' answeringDiscard: false.

	self assert: (browser tabTitles includes: '*a')
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

{ #category : 'tests - Similar tabs are reused' }
ClySpTabsTest >> testAMethodEditorIsReusedAcrossProtocols [

	| class editor |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	editor := browser toolTitled: 'a'.

	browser selectProtocolNamed: 'alpha'.
	browser selectMethod: class >> #a.

	self assert: (browser toolTitled: 'a') identicalTo: editor
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

{ #category : 'tests - Tabs close when their model is removed' }
ClySpTabsTest >> testAnEditorClosesWhenItsMethodOrClassIsRemoved [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.

	browser changeSystemBy: [ class removeSelector: #a ].
	self deny: (browser tabTitles includes: 'a').

	browser selectMethod: class >> #b.
	browser changeSystemBy: [ factory delete: class ].
	self deny: (browser tabTitles includes: 'b')
]

{ #category : 'tests - Tabs are live' }
ClySpTabsTest >> testAnEditorShowsTheNewSourceOfItsMethod [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.

	browser changeSystemBy: [ class compile: 'a ^ 2' classified: 'alpha' ].

	self assert: browser editorText equals: 'a ^ 2'
]

{ #category : 'tests - Tabs close when their model is removed' }
ClySpTabsTest >> testAnEditorStaysWhenItsMethodIsRecompiled [

	| class editor |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	editor := browser toolTitled: 'a'.

	browser changeSystemBy: [ class compile: 'a ^ 2' classified: 'alpha' ].

	self assert: (browser toolTitled: 'a') identicalTo: editor
]

{ #category : 'tests - Which tab is selected' }
ClySpTabsTest >> testSelectingAClassSelectsItsComment [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: factory newClass.

	browser selectClass: class.

	self assert: browser selectedTabTitle equals: 'Comment'
]

{ #category : 'tests - Which tab is selected' }
ClySpTabsTest >> testSelectingAMethodSelectsItsEditor [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.

	browser selectMethod: class >> #a.

	self assert: browser selectedTabTitle equals: 'a'
]

{ #category : 'tests - Which tab is selected' }
ClySpTabsTest >> testSelectingAProtocolSelectsMethodCreation [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.

	browser selectProtocolNamed: 'beta'.

	self assert: browser selectedTabTitle equals: 'Inst. side method'
]

{ #category : 'tests - Dirty tabs stay' }
ClySpTabsTest >> testSelectingTheDirtyMethodAgainDropsTheOtherEditor [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.
	browser typeInSelectedTab: ' ^ 1'.
	browser selectMethod: class >> #b.

	browser selectMethod: class >> #a.

	self deny: (browser tabTitles includes: 'b').
	self deny: (browser isTabOutOfContext: '*a')
]

{ #category : 'tests - Similar tabs are reused' }
ClySpTabsTest >> testTheClassDefinitionIsReusedForItsMethods [

	| class definition |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	definition := browser toolTitled: class name.

	browser selectMethod: class >> #a.

	self assert: (browser toolTitled: class name) identicalTo: definition
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

{ #category : 'tests - Dirty tabs stay' }
ClySpTabsTest >> testTypingMarksTheEditorDirty [

	| class |
	class := self newClassWithProtocols.
	browser openOnClass: class.
	browser selectMethod: class >> #a.

	browser typeInSelectedTab: ' ^ 1'.

	self assert: browser selectedTabTitle equals: '*a'
]
