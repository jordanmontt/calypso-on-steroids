"
I find out what a test can drive in a Spec presenter like the future browser: a tree table with Commander2 commands as its context menu and shortcuts. I am a spike, to be removed once the browser drivers exist.
"
Class {
	#name : 'ClySpSpecSpikeTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'presenter'
	],
	#category : 'Calypso-Spec-Spike-Tests',
	#package : 'Calypso-Spec-Spike-Tests'
}

{ #category : 'running' }
ClySpSpecSpikeTest >> setUp [

	super setUp.
	presenter := ClySpSpikePresenter new
]

{ #category : 'running' }
ClySpSpecSpikeTest >> tearDown [

	presenter withWindowDo: [ :window | window close ].
	super tearDown
]

{ #category : 'tests' }
ClySpSpecSpikeTest >> testReadsTheRowsTheTableShows [

	presenter open.
	self assert: presenter tree adapter widget dataSource numberOfRows equals: 2.
	presenter tree expandPath: #( 2 ).
	self assert: presenter tree adapter widget dataSource numberOfRows equals: 4
]

{ #category : 'tests' }
ClySpSpecSpikeTest >> testRecordInTheMenuOfARowRecordsIt [

	| menu recordEntry |
	presenter open.
	presenter tree selectPath: #( 2 ).
	menu := presenter tree adapter widget dataSource menuColumn: nil row: 2.
	recordEntry := menu items detect: [ :each | each contents asString = 'Record' ].
	recordEntry doButtonAction.
	self assert: presenter recorded asArray equals: #( 2 )
]

{ #category : 'tests' }
ClySpSpecSpikeTest >> testRunsACommandWithoutTheUI [

	presenter tree selectPath: #( 1 ).
	(presenter tree actions allCommands detect: [ :each | each name = 'Record' ]) execute.
	self assert: presenter recorded asArray equals: #( 1 )
]

{ #category : 'tests' }
ClySpSpecSpikeTest >> testRunsAShortcut [

	presenter open.
	presenter tree selectPath: #( 2 ).
	presenter tree adapter
		keyDown: $r
		shift: false
		meta: true
		control: false
		option: false.
	self assert: presenter recorded asArray equals: #( 2 )
]

{ #category : 'tests' }
ClySpSpecSpikeTest >> testSelectsAPathWithoutOpening [

	presenter tree selectPath: #( 2 1 ).
	self assert: presenter tree selectedItem equals: 21
]
