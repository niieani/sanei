phpmyadmin
==========
.. module:: phpMyAdmin
:synopsis: phpMyAdmin on Nginx.

.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

Module
++++++

:Description: TODO.

:Dependencies: - php+mysql
               - nginx-ssl
               - apt:mariadb-client

Variables
+++++++++

.. envvar:: PMA_PORT

   :default: 9000

           Sets the port under which PMA will be available.

.. envvar:: PMA_HOSTNAME

   :default: pma.local

           Sets the hostname under PMA will be available.