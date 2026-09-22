FROM perl:5.40-trixie

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		vim \
		inkscape \
	; \
	apt-get dist-clean

ENV PERL_CPANM_OPT --verbose --mirror https://cpan.metacpan.org

RUN cpanm Digest::SHA Module::Signature

RUN cpanm App::cpanminus

RUN cpanm Mojolicious@8.35

RUN cpanm EV
RUN cpanm IO::Socket::IP
RUN cpanm --notest IO::Socket::SSL

RUN cpanm Term::UI

ENV LANG C.UTF-8

RUN mkdir ~/.vim ~/.vim/bundle ~/.vim/autoload
RUN set -x \
	&& git clone https://github.com/tpope/vim-pathogen.git ~/.vim/bundle/pathogen \
	&& ln -s ../bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload/
RUN git clone https://github.com/jtratner/vim-flavored-markdown.git ~/.vim/bundle/ghmarkdown
RUN git clone https://github.com/nanotech/jellybeans.vim.git ~/.vim/bundle/jellybeans

RUN { \
		echo 'scriptencoding utf-8'; \
		echo 'execute pathogen#infect()'; \
		echo 'syntax on'; \
		echo 'filetype plugin indent on'; \
		echo 'set list listchars=tab:»·,nbsp:_,extends:¬ noet ts=4 sw=4 nobackup noswapfile'; \
		echo 'set background=dark'; \
		echo 'colorscheme jellybeans'; \
		echo 'au FilterWritePre * if &diff | setlocal wrap< | endif'; \
		echo 'au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown'; \
	} > ~/.vimrc

COPY . /usr/src/docker-library-docs
WORKDIR /usr/src/docker-library-docs

CMD ["./push.pl"]
