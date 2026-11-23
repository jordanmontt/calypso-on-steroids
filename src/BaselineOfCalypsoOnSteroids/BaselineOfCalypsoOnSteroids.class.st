"
Loads the Spec version of Calypso.
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
	spec for: #common do: [
		spec
			package: 'Calypso-Spec-Tests';
			package: 'Calypso-Spec-Spike-Tests' with: [ spec requires: #( 'Calypso-Spec-Tests' ) ] ]
]
