FileName: csslint.vim

Version: 0.2

Desc: Vim plugin for csslint

Depand: Python > 2.6

Install: Copy file into $VIM/plugin/, need Python

History:

2011.11.25 基本完工
2012.2.1 增加了 g:CSSLint_errors 和 g:CSSLint_warnings 来达到 csslint 的 errors 和 warnings 选项的效果，顺便增加了高亮的错误的等级过滤


Credit [jslint.vim](https://github.com/hallettj/jslint.vim) and [csslint](http://csslint.net/)

I am not sure it could work well in Windows.

I will update this plugin in [GitHub](https://github.com/bolasblack/csslint), but not in vim.org.

need nodejs:

    sudo pacman -S nodejs (archlinux)
    sudo apt-get install nodejs (ubuntu, debian)

need npm:

    yaourt nodejs-npm (archlinux)
    curl http://npmjs.org/install.sh | sh (other)

need csslint:

    sudo npm install -g csslint

csslint.vim will be actived if file is css or less default, you can config it in .vimrc:

    let g:CSSLint_FileTypeList = ['css', 'less', 'sess']

you can deactivate it:

    let g:CSSLint_HighlightErrorLine = 0

can add rules as options of csslint (csslint --warnings=...):

    let g:CSSLint_errors = ['empty-rules']
    let g:CSSLint_warnings = []

can filter message:

    let g:CSSLint_HighlightLevel = ['error']
