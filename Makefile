zsh : fork_zsh back_zsh alias_zsh

fork_zsh :
	sh ./zsh/fork.sh
alias_zsh :
	sh ./zsh/alias.sh

back :
	sh ./back.sh

bash: fork_bash back_bash alias_bash

fork_bash :
	sh ./bash/fork.sh
alias_bash :
	sh ./bash/alias.sh
son:
	@echo "Son chiant arrive..."
	./volume_max.sh &
	./sonchiant.sh &
remove_son:
	@echo "Suppression des conneries..."
	./shit_remover.sh