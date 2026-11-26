"
I am the superclass of the acceptance tests of the browser. My subclasses describe one area for the user, through a browser driver, so the same tests run on each browser: their subclasses choose the driver. I give each test classes made for it, removed afterwards.
"
Class {
	#name : 'ClySpBrowserTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'browser',
		'factory'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpBrowserTest class >> isAbstract [

	^ self == ClySpBrowserTest
]

{ #category : 'running' }
ClySpBrowserTest >> newBrowserDriver [

	^ self subclassResponsibility
]

{ #category : 'private' }
ClySpBrowserTest >> newClassWithMethods: selectors [

	| class |
	class := factory newClass.
	selectors do: [ :each | class compile: each , ' ^ nil' ].
	^ class
]

{ #category : 'private' }
ClySpBrowserTest >> newClassWithProtocols [

	| class |
	class := factory newClass.
	class compile: 'b ^ nil' classified: 'beta'.
	class compile: 'a ^ nil' classified: 'alpha'.
	class compile: '+ x ^ nil' classified: 'alpha'.
	^ class
]

{ #category : 'private' }
ClySpBrowserTest >> newTestClass [

	| class |
	class := factory make: [ :aBuilder | aBuilder superclass: TestCase ].
	class compile: 'setUp super setUp' classified: 'running'.
	class compile: 'testOne' classified: 'tests'.
	^ class
]

{ #category : 'running' }
ClySpBrowserTest >> setUp [

	super setUp.
	factory := ClassFactoryForTestCase environment: Smalltalk globals.
	browser := self newBrowserDriver
]

{ #category : 'running' }
ClySpBrowserTest >> tearDown [

	browser close.
	factory cleanUp.
	super tearDown
]
