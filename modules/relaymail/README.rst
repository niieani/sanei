Relay Mail
=================
.. module:: relaymail
   :synopsis: Mail relay system.
   :platform: raring
.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

Module
++++++

:Description: TODO

:Dependencies: - apt:ssmtp

Variables
+++++++++

.. envvar:: HOSTNAME

   This hostname.

.. envvar:: RELAYMAIL_HOST

   The email server host for relaying the messages.

.. envvar:: RELAYMAIL_ROOTMAIL

   :default: postmaster

   The user to whom root mail will go to. (TODO: implement this)
