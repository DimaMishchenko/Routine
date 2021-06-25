init: 
	bash -c "bash <(curl -Ls https://install.tuist.io)"
	tuist up

gen: 
	tuist dependencies update
	tuist generate