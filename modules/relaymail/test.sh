cat <<- EOF > /tmp/mail.test
To: $RELAYMAIL_TEST_EMAIL
Subject: Put a subject here
From: test

Of cause, here's the place to put the body
EOF

sendmail -vt < /tmp/mail.test
rm /tmp/mail.test
