redmine
=======
.. module:: redmine
:synopsis: Redmine on Nginx with Phusion Passanger.

.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

Module
++++++

:Description: TODO.

:Dependencies: - ruby
               - nginx-phusion-passenger
               - apt:python
               - apt:libmariadbclient-dev
               - apt:imagemagick
               - apt:libmagickwand-dev
               - apt:libcurl4-openssl-dev

Variables
+++++++++

.. envvar:: NGINX_PASSANGER_ENABLED

   :default: true

           Whether the passanger module is enabled.