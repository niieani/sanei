echo "To: $RELAYMAIL_TEST_EMAIL" > /tmp/mail.test
cat <<EOM >> /tmp/mail.test
Subject: Put a subject here
From: test

Of cause, here's the place to put the body
EOM

sendmail -vt < /tmp/mail.test
rm /tmp/mail.test
