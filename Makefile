init: 
	bash -c "bash <(curl -Ls https://install.tuist.io)"
	tuist up

gen: 
	tuist generate
	open Routine.xcworkspace