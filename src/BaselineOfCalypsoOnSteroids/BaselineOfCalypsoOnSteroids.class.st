"
Loads the Spec version of Calypso. It is empty until the first package exists: a package is added here in the commit that creates its first class.
"
Class {
	#name : 'BaselineOfCalypsoOnSteroids',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCalypsoOnSteroids',
	#package : 'BaselineOfCalypsoOnSteroids'
}

{ #category : 'baselines' }
BaselineOfCalypsoOnSteroids >> baseline: spec [

	<baseline>
	spec for: #common do: [ ]
]
