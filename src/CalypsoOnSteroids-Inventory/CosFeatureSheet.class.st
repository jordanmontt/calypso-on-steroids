"
I am a feature sheet read from its Markdown: its review status, the scenarios of each feature and the state of each feature's manual check.
"
Class {
	#name : 'CosFeatureSheet',
	#superclass : 'Object',
	#instVars : [
		'status',
		'scenarios',
		'manualChecks'
	],
	#category : 'CalypsoOnSteroids-Inventory',
	#package : 'CalypsoOnSteroids-Inventory'
}

{ #category : 'instance creation' }
CosFeatureSheet class >> fromText: aString [

	^ self new parse: aString
]

{ #category : 'parsing' }
CosFeatureSheet >> manualCheckIn: aLine [

	| text |
	text := (aLine allButFirst: '**Manual check.**' size) trimBoth.
	(text beginsWith: 'None') ifTrue: [ ^ #none ].
	^ (text includesSubstring: 'hecked 20')
		  ifTrue: [ #done ]
		  ifFalse: [ #toDo ]
]

{ #category : 'accessing' }
CosFeatureSheet >> manualCheckOf: aFeatureId [

	^ manualChecks at: aFeatureId ifAbsent: [ #none ]
]

{ #category : 'parsing' }
CosFeatureSheet >> parse: aString [

	| feature reviewed featureHeading scenarioLine |
	status := 'draft'.
	scenarios := OrderedCollection new.
	manualChecks := Dictionary new.
	reviewed := '^Status\: \*\*reviewed\*\* (\d\d\d\d-\d\d-\d\d)' asRegex.
	featureHeading := '^## ([A-Z]+-\d+)\: ' asRegex.
	scenarioLine := '^- `([A-Z]+-\d+\.[a-z]+)`' asRegex.
	aString lines do: [ :line |
		(reviewed search: line) ifTrue: [ status := 'reviewed ' , (reviewed subexpression: 2) ].
		(featureHeading search: line) ifTrue: [ feature := featureHeading subexpression: 2 ].
		(scenarioLine search: line) ifTrue: [
			scenarios add: (CosScenario id: (scenarioLine subexpression: 2) testReference: (self testReferenceIn: line)) ].
		(line beginsWith: '**Manual check.**') ifTrue: [ manualChecks at: feature put: (self manualCheckIn: line) ] ]
]

{ #category : 'accessing' }
CosFeatureSheet >> scenarios [

	^ scenarios
]

{ #category : 'accessing' }
CosFeatureSheet >> scenariosOf: aFeatureId [

	^ scenarios select: [ :each | each featureId = aFeatureId ]
]

{ #category : 'accessing' }
CosFeatureSheet >> status [

	^ status
]

{ #category : 'parsing' }
CosFeatureSheet >> testReferenceIn: aLine [

	| last |
	(aLine endsWith: '`') ifFalse: [ ^ nil ].
	last := (aLine substrings: '`') last.
	^ (last includesSubstring: '>>')
		  ifTrue: [ last ]
		  ifFalse: [ nil ]
]
