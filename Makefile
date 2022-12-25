init: 
	bundle install
	bash -c "bash <(curl -Ls https://install.tuist.io)"
	tuist up

gen:
	tuist generate -n
