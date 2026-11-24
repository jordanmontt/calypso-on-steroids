"
I am a scenario of a feature sheet, with the test it links to when it has one (Class>>selector).
"
Class {
	#name : 'CosScenario',
	#superclass : 'Object',
	#instVars : [
		'id',
		'testReference'
	],
	#category : 'CalypsoOnSteroids-Inventory',
	#package : 'CalypsoOnSteroids-Inventory'
}

{ #category : 'instance creation' }
CosScenario class >> id: aString testReference: aReference [

	^ self new setId: aString testReference: aReference
]

{ #category : 'accessing' }
CosScenario >> featureId [

	^ id copyUpToLast: $.
]

{ #category : 'accessing' }
CosScenario >> hasLink [

	^ testReference isNotNil
]

{ #category : 'accessing' }
CosScenario >> hasTest [

	| parts testClass |
	self hasLink ifFalse: [ ^ false ].
	parts := testReference splitOn: '>>'.
	testClass := Smalltalk globals classNamed: parts first.
	^ testClass isNotNil and: [ testClass includesSelector: parts second asSymbol ]
]

{ #category : 'accessing' }
CosScenario >> id [

	^ id
]

{ #category : 'accessing' }
CosScenario >> setId: aString testReference: aReference [

	id := aString.
	testReference := aReference
]

{ #category : 'accessing' }
CosScenario >> testReference [

	^ testReference
]
