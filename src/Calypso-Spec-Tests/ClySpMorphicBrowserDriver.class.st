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

	self inUIProcess: [ browser selectClass: aClass ]
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
ClySpMorphicBrowserDriver >> shownMethods [

	^ self inUIProcess: [ browser methodView dataSource allElements collect: [ :each | each actualObject ] ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToClassSide [

	self inUIProcess: [ browser switchToMetaLevelScope: ClyClassSideScope ]
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
