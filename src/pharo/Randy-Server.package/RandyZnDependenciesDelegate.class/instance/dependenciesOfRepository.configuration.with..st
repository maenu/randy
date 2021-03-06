as yet unclassified
dependenciesOfRepository: aString configuration: anotherString with: aHypervisor
	| block response start end |
	block := [ :repository :configuration :startMarker :endMarker | 
	| project simplifier json |
	project := RandyProject repository: repository configuration: configuration.
	simplifier := RandyProjectSimplifier project: project.
	json := simplifier asJson.
	Transcript show: startMarker , json , endMarker ].
	response := aHypervisor run: block sourceNode formattedCode , ' value: ''' , aString , ''' value: ''' , anotherString , ''' value: ''' , StartMarker , ''' value: ''' , EndMarker , ''''.
	start := response findString: StartMarker.
	end := response findString: EndMarker startingAt: start + StartMarker size.
	(start < end and: start >= 0)
		ifFalse: [ self error: response ].
	^ response copyFrom: start + StartMarker size to: end - 1