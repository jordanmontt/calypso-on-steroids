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
			package: 'Calypso-Spec-Spike-Tests' with: [ spec requires: #( 'Calypso-Spec-Tests' ) ];
			package: 'CalypsoOnSteroids-Inventory';
			package: 'CalypsoOnSteroids-Inventory-Tests' with: [ spec requires: #( 'CalypsoOnSteroids-Inventory' ) ].
		"The dev group adds the tools that help build the browser; they never ship with it"
		spec
			group: 'default' with: #( 'Calypso-Spec-Tests' 'Calypso-Spec-Spike-Tests' );
			group: 'dev' with: #( 'default' 'CalypsoOnSteroids-Inventory' 'CalypsoOnSteroids-Inventory-Tests' ) ]
]
