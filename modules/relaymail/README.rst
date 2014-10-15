Relay Mail
=================
.. module:: relaymail
   :synopsis: Mail relay system.
.. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>

Module
++++++

:Description: TODO

:Dependencies: - apt:ssmtp

Variables
+++++++++

.. envvar:: LOCAL_HOSTNAME

   This hostname.

.. envvar:: RELAYMAIL_HOST

   The email server host for relaying the messages.

.. envvar:: RELAYMAIL_ROOTMAIL

   :default: postmaster

   The user to whom root mail will go to.

.. envvar:: RELAYMAIL_TEST_EMAIL

   An email address used for testing.
