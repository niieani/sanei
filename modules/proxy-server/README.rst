Proxy Server
=================
.. module:: proxy.server
   :synopsis: Proxy.
.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

Module
++++++

:Description: Based on:
              http://devmash.net/setup-dante-server-with-virtual-user-accounts-on-ubuntu/
              https://coderwall.com/p/zvvgna

:Dependencies: - apt:dante-server
               - apt:libpam-pwdfile
               - apt:whois

Variables
+++++++++

.. envvar:: DANTE_SERVER_PORT

   :default: 44556

   Desired port.

.. envvar:: DANTE_SERVER_LOGIN

   :default: dante

   Your login.

.. envvar:: DANTE_SERVER_PASSWORD

   Desired password.
