FileName: csslint.vim

Desc: Vim plugin for csslint

Install: Copy file into $VIM/plugin/, need Python 

History: 

2011.11.25 基本完工


I will update this plugin in [GitHub](https://github.com/bolasblack/csslint), but not in vim.org

need nodejs:

    sudo pacman -S nodejs
    sudo apt-get install nodejs

need npm:

    这里放 npm 的安装方式

need csslint:

    sudo npm install -g csslint

csslint.vim will be actived if file is css or less default, you can config it in .vimrc:

    let g:CSSLint_FileTypeList = ['css', 'less', 'sess']

you can deactivate it:

    let g:CSSLint_HighlightErrorLine = 0
