.PHONY: all test clean archive test_archive

all:
	@ dune build

test:
	@ dune runtest

clean:
	@ git clean -fdX

# By default, $(NAME) is your login name.
# Change it to <lastname>-<firstname> if desired.
NAME=$(shell whoami)

archive:
	@ rm -f $(NAME).tar.gz
	@ if [ -n "$$(git status --porcelain)" ] ; then \
	    echo "Error: please commit all changes before creating an archive." ; \
	    exit 1 ; \
	  fi
	@ git archive --format=tar.gz --prefix $(NAME)/ -o $(NAME).tar.gz HEAD
	@ tar tvfz $(NAME).tar.gz

test_archive:
	@ echo "Copying $(NAME).tar.gz into /tmp..."
	@ cp -f $(NAME).tar.gz /tmp
	@ echo "Decompressing..."
	@ cd /tmp && tar xvfz $(NAME).tar.gz
	@ echo "Compiling."
	@ if ! make -C /tmp/$(NAME) all ; then echo "Compilation failed!" ; fi
	@ echo "Testing."
	@ if ! make -C /tmp/$(NAME) test ; then echo "Testing failed!" ; fi
	@ echo "Success."
	@ echo "Cleaning up."
	@ rm -rf /tmp/$(NAME) /tmp/$(NAME).tar.gz

