:mod:website-archiver
=====================
.. module:: website-archiver
    :synopsis: Archives a pdf and an image of a website.
.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

:Date: 2013-09-28
:Version: 1.0
:Dependencies: - apt:phantomjs
:Variables: - DELICIOUS_API_KEY
            - DELICIOUS_LOGIN
            - DELICIOUS_PASSWORD
:Description: takes all tasks tagged **!archive**, 
              makes a local copy of them 
              and changes the tag **!archive** to **!local-copy**
