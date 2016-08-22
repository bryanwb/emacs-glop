Emacs GLOP
-----------


Opens a browser window with the current file or selection highlighted


Depends on emacs-gitlab

useful methods

* `glop-glop` displays the current file in gitlab's web interface
* `glop-glap` determines url for current file and inserts it into the kill ring

I like to use glop with the key-chord mode like this


```elisp
(setq key-chord-two-keys-delay 1)
(key-seq-define-global "glop" 'glop-glop)
(key-seq-define-global "glap" 'glop-glap)
```


LICENSE - MIT

Copyright 2016 Bryan W. Berry <bryan.berry@gmail.com>

